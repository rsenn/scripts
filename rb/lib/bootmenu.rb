require_relative 'enum'

""" BootMenu -------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """

def is_nonempty_string(*args)
  if args.length == 0 then return false end
  args.each do |s|
    if not s.is_a? String then return false end
    if s.size == 0 then return false end
  end
  return true
end

def canonicalize_str(s)
  if not s.is_a? String then s = '' end
  s = s.split(/[^-._A-Za-z0-9]+/).join('_')
  s = s.downcase
  s
end

class BootMenu
  attr_accessor :config_type, :file, :content
  attr_accessor :data, :lineno
  attr_accessor :entries

  class MenuType < Enum
    enum_attr :syslinux, 1
    enum_attr :grub4dos, 2
    enum_attr :grub2, 3
  end
 
  class EntryType < Enum
    enum_attr :undef, 0
    enum_attr :boot_sector, 1
    enum_attr :linux16, 2
    enum_attr :linux, 3
    enum_attr :linuxefi, 4
    enum_attr :config_file, 5
    enum_attr :com32, 6
  end
  
  class Entry
    attr_accessor :file, :lines
    attr_accessor :shortname, :name, :type, :arg, :params, :initrd
    def initialize(data)
	  @shortname = data.shortname
	  @name = data.name
	  @type = data.type
	  @arg = data.arg
	  @params = data.params
	  @initrd = data.initrd
    end
    def line_range(from, to)
      #$stderr.puts "line_range(#{from}, #{to})"
      @lines = Range.new(from ? from : 0, to)
    end
    def get(key)
      key = key.to_s.gsub(/^[:@]*/, '@')
      self.instance_variable_get(key)
    end
  end
 
  class ParseData
    attr_accessor :file, :line
    attr_accessor :filename
    attr_accessor :shortname, :name, :type, :arg, :params, :initrd

    def initialize
      @type = :undef
    end

    def type
      return @type
    end

    def make_abspath(fn)
      if not fn.match(/\//) then
        fn = File.expand_path(fn, File.dirname(self.get(:file)))
      end
      return fn
    end

    def set(key, value)
      key = key.to_s
       case key
         when 'file'
           if not is_nonempty_string(@file) then @file = value end
         when 'line'
           if not is_nonempty_string(@line) then @line = value end
         when 'shortname'
           @shortname = value
         when 'name'
           @name = value
         when 'type'
           @type = value
         when 'arg'
           #if not is_nonempty_string(@arg) then @arg = value end
           @arg = value
         when 'params'
           if not is_nonempty_string(@params) then @params = value end
         when 'initrd'
           if not is_nonempty_string(@initrd) then @initrd = value end
       end
       #$stdout.puts "Setting key=#{key}, value=#{value}"
    end

    def notset(key)
      key = key.to_s.gsub(/^[:@]*/, '@')
      if not self.instance_variable_defined?(key) then return true  end
      v = self.instance_variable_get(key)
      if v === nil then return true end
      if v == '' then return true end
      return false
    end
    
    def isset(key)
      return !self.notset(key)
    end

    def get(key)
      key = key.to_s.gsub(/^[:@]*/, '@')
      return self.instance_variable_get(key)
    end

    def clear
      @file = ''
      @line = -1
      #self.remove_instance_variable('@file')
      @name = ''
      @type = :undef
      @arg = ''
      @params = ''
      @initrd  = ''
    end

    def is_complete
      #if not is_nonempty_string @name then return false end
      case @type.to_sym
        when :linux16, :linux, :linuxefi
          return is_nonempty_string @arg, @initrd
          #return is_nonempty_string(@arg,  @params)
        when :com32, :boot_sector, :config_file
          return is_nonempty_string @arg
        when :undef
          return false
      end
      return false
    end

#    def to_hash
#      h = Hash.new
#      self.instance_variables.each do |v|
#        h[v] = self.instance_variable_get(v)
#      end
#      return h
#    end

    def to_s
      out = Array.new
      out.push "file='#{@file}'"
      out.push "line='#{@line}'"
      out.push "name='#{@name}'"
      out.push "arg='#{@arg}'"
      out.push "params='#{@params}'"
      out.push "initrd='#{@initrd}'"
      out.push "type='#{@type}'"
      return out.join(", ")
    end
  end

  def initialize(type = nil, arg = '')
    @config_type = type
    if arg.is_a? Array then
      @entries = arg
    else
      if File.exists? arg then
        @file = File.open arg
        @filename = File.absolute_path(@file.path)
      end
      @entries = Array.new
    end
    @data = ParseData.new
    @content = ''
  end

  def dup(type = nil)
    if type === nil then
      type = @type
    end
    obj = nil
    case type
      when :syslinux
        obj = SyslinuxMenu.new @entries.dup
      when :grub4dos
        obj = Grub4dosMenu.new @entries.dup
      when :grub2
        obj = Grub2Menu.new @entries.dup
    end
    return obj
  end

  def read
    @content = '' 
    @lineno = 0
    @data.line = @lineno
    @data.file = @filename
    @file.each do |line|
      @lineno += 1
      parse_line line, @lineno
      if @data.is_complete then
        #$stdout.puts "Data: #{@data.to_s}"
        ent =  Entry.new(@data)
        ent.file = @filename
        ent.line_range(@data.line, @lineno)
        @entries.push ent
        @data.clear
        @data.line = @lineno + 1
        @data.file = @filename
      end
      @content += "#{line}\n"
    end
    @data.clear
  end

  def write(stream = $stdout)
    i = 0
    @entries.each do |e|
      i += 1
      #$stderr.puts "Entry ##{i}: #{e.lines}"
      output(stream, e)
    end
  end

  protected
  
  def output(stream = $stdout, data = nil)
    raise "SYSTEM ERROR: method missing"
  end

  def parse_line(line = '')
    raise "SYSTEM ERROR: method missing"
  end

end

require_relative 'bootmenu/syslinux.rb'
require_relative 'bootmenu/grub4dos.rb'
require_relative 'bootmenu/grub2.rb'

def BootMenuParser(type, arg)
  o = nil
  case type.to_sym
  when :grub2
    o = Grub2Menu.new(arg)
  when :grub4dos
    o = Grub4dosMenu.new(arg)
  when :syslinux
    o = SyslinuxMenu.new(arg)
  end
  return o
end
