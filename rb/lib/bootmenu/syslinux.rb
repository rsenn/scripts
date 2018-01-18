class SyslinuxMenu < BootMenu


  class SyslinuxCommand
    attr_accessor :file, :line
    attr_accessor :name, :args

    def initialize(file, line, name, args)
      @file = file
      @line = line
      @name = name
      @args = args
    end
  end

  def initialize(filename = '')
     super(:syslinux, filename)

     @data.instance_variable_set("@cmds",  Array.new)

     def @data.clear
      @name = ''
      @type = :undef
      @arg = ''
      @params = ''
      @initrd  = ''

      cmds = self.instance_variable_get("@cmds")
      cmds.clear
      
     end
     def @data.cmds
       @data.instance_variable_get("@cmds")
    end
  end

  def new_cmd(file, line, name, args)
      cmds = @data.instance_variable_get("@cmds")
    cmds.push SyslinuxCommand.new(file, line, name, args)
  end

  
  def parse_line(line = '', lineno = -1)
    toks = line.split(/\s+/)
    cmd = toks.shift
    args = toks.join ' '
      
    if not cmd.is_a? String then return end

    c = self.new_cmd(file, lineno, cmd, args)

    @data.set :file, @filename
    @data.set :line, lineno

    case cmd
	  when 'MENU'
        cmd2 = toks.shift
        args = toks.join ' '
        if cmd2.is_a? String then cmd2 = cmd2.upcase end
        case cmd2
		  when 'LABEL'
            @data.set :name, args
		  when 'TITLE'
        end

	  when 'APPEND'
        append = Array.new
        args.split(/\s+/).each do |a|
          if a.match(/^initrd=/) then
            @data.set :initrd, a.gsub(/^[^=]*/, "")
          else
            append.push a
          end
        end
        @data.set :params, append.join(' ')
	  when 'BOOT'
        @data.set :type, :boot_sector
        @data.set :arg, args
	  when 'COM32'
        @data.set :type, :com32
        @data.set :arg, args
	  when 'CONFIG'
        @data.set :type, :config_file
        @data.set :arg, args
	  when 'DEFAULT'
        @data.set :type, :default_entry
        @data.set :arg, args
	  when 'INITRD'
        @data.set :initrd, args
	  when 'LINUX', 'KERNEL'
        @data.set :arg, args
	  when 'LABEL'
        @data.set :name, args
	  when 'LOCALBOOT'
	  when 'PROMPT'
	  when 'TEXT'
	  when 'TIMEOUT'
	  when 'UI'
	end 
  end

  def output(stream = $stdout, data = nil)
    h = data.to_hash

    case  data.type
      when :linux_16, :linux, :linux_efi
        stream.puts "KERNEL #{data.arg}"
      when :boot_sector
        stream.puts "BOOT #{data.arg}"
      when :com32
        stream.puts "COM32 #{data.arg}"
    end
  end


end
