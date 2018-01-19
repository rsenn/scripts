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

  def initialize(arg)

     super(:syslinux, arg)

     @data.instance_variable_set("@cmds",  Array.new)

     def @data.clear
       super

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
    toks = line.lstrip.split(/\s+/)
    cmd = toks.shift
    args = toks.join ' '
      
    if not cmd.is_a? String then return end
    cmd = cmd.upcase


    c = self.new_cmd(file, lineno, cmd, args)

    #$stderr.puts "Parsing cmd='#{cmd}'"

    if cmd != 'UI' and cmd != 'DEFAULT' and args.match(/.*\.c32.*/i) then
      cmd = "COM32"
    end

    if cmd.match(/^MENU/) then
      cmd += ' '
      cmd += toks.shift
       cmd = cmd.upcase
    end

    arga = args.split(/\s+/)

    case cmd
	  when 'LABEL'
        @data.set :shortname, args
	  when 'MENU LABEL'
        if arga[0].upcase == 'LABEL' then 
          arga.shift
          args = arga.join ' '
        end
        @data.set :name, args
	  when 'LINUX', 'KERNEL'
        @data.set :type, :linux
        @data.set :arg, @data.make_abspath(args)
	  when 'APPEND'
        @data.set :type, :linux
        append = Array.new
        args.split(/\s+/).each do |a|
          if a.match(/^initrd=/) then
            initrd = @data.make_abspath a.gsub(/^[^=]*=/, "")
            @data.set :initrd, initrd
          else
            append.push a
          end
        end
        @data.set :params, append.join(' ')
	  when 'BOOT'
        @data.set :type, :boot_sector
        @data.set :arg, @data.make_abspath(args)
	  when 'COM32'
        if arga.length > 1 then
          args = arga.shift
          @data.set :params, arga.join(' ')
        end
        @data.set :type, :com32
        @data.set :arg, @data.make_abspath(args)
	  when 'CONFIG'
        @data.set :type, :config_file
        @data.set :arg, @data.make_abspath(args)
	  when 'DEFAULT'
        @data.set :type, :default_entry
        @data.set :arg, args
	  when 'INITRD'
        #if @data.type != :undef
        @data.set :type, :linux
        @data.set :initrd, @data.make_abspath(args)
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

#    if data === nil then return end
    params = data.get(:params)




    shortname = data.shortname
    shortname = canonicalize_str(shortname)
    if shortname == '' then
      shortname = data.name
    end
    shortname = canonicalize_str(shortname)

    stream.puts "LABEL #{shortname}"
    stream.puts "MENU LABEL #{data.name}"

    case  data.type
      when :linux16, :linux, :linuxefi
        a = data.arg
        if data.params.is_a? String then
          a += ' '
          a += data.params
        end
        args = a.split(/\s+/)
        kern = args.shift
        stream.puts "KERNEL #{kern}"
        initrd = data.get :initrd 
        if initrd then
          args.push "initrd=#{initrd}"
        end
        if args.size > 0 then
          params = args.join(" ")
          stream.puts "APPEND #{params}"
        end
      when :boot_sector
        stream.puts "BOOT #{data.arg}"

      when :config_file
        stream.puts "CONFIG #{data.arg}"

      when :com32
        if params.length > 0 then
          stream.puts "KERNEL #{data.arg} #{params}"
        else
          stream.puts "COM32 #{data.arg}"
        end
    end
    stream.puts
  end


end
