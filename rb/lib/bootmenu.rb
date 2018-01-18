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

class BootMenu
  class MenuType < Enum
    enum_attr :syslinux, 1
    enum_attr :grub4dos, 2
    enum_attr :grub2, 3
  end
  class EntryType < Enum
    enum_attr :undef, 0
    enum_attr :boot_sector, 1
    enum_attr :linux_16, 2
    enum_attr :linux, 3
    enum_attr :linux_efi, 4
    enum_attr :config_file, 5
    enum_attr :com32, 6
  end
  class ParseData
    attr_accessor :file, :line
    attr_accessor :filename
    attr_accessor  :name, :type, :arg, :params, :initrd


    def type
      return @type
    end

    def set(key, value)
      key = key.to_s
       case key
         when 'file'
           if not is_nonempty_string(@file) then @file = value end
         when 'line'
           if not is_nonempty_string(@line) then @line = value end
         when 'name'
           if not is_nonempty_string(@name) then @name = value end
         when 'type'
           if not is_nonempty_string(@type) then @type = value end
         when 'arg'
           if not is_nonempty_string(@arg) then @arg = value end
         when 'params'
           if not is_nonempty_string(@params) then @params = value end
         when 'initrd'
           if not is_nonempty_string(@initrd) then @initrd = value end
       end
       #$stdout.puts "Setting key=#{key}, value=#{value}"
    end

    def clear
      @name = ''
      @type = :undef
      @arg = ''
      @params = ''
      @initrd  = ''
    end

    def is_complete
      if not is_nonempty_string @name then return false end
      case @type
        when  :linux_16, :linux, :linux_efi
          return is_nonempty_string(@arg, @initrd, @params)
        when :com32, :boot_sector, :config_file
          return is_nonempty_string @arg
        when :undef
          return false
      end
      return false
    end

    def to_hash
      return self.instance_variables
    end

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

  attr_accessor :config_type, :file
  attr_accessor :data, :lineno

  def initialize(type = nil, filename = '')
    @config_type = type
    
    if File.exists? filename then
      @file = File.open filename
     
      @filename = File.absolute_path(@file.path)
    end

    @data = ParseData.new
  end

  def read
    @lineno = 0
    @file.each do |line|
      @lineno += 1
      parse_line line, @lineno
      if @data.is_complete then
        $stdout.puts "Data: #{@data.to_s}"
        @data.clear
      end
    end
  end

  def output(stream = $stdout, data = nil)
    raise "SYSTEM ERROR: method missing"
  end

  protected
  
  def parse_line(line = '')
    raise "SYSTEM ERROR: method missing"
  end

end

require_relative 'bootmenu/syslinux.rb'
