class Grub4dosMenu < BootMenu


  def initialize(filename = '')
     super(:syslinux, filename)
  end

  def new_cmd(file, line, name, args)
      cmds = @data.instance_variable_get("@cmds")
    cmds.push Grub4dosCommand.new(file, line, name, args)
  end

  
  def parse_line(line = '', lineno = -1)
    toks = line.lstrip.split(/\s+/)
    cmd = toks.shift
    args = toks.join ' '
      
    if not cmd.is_a? String then return end
    cmd = cmd.downcase


    @data.set :file, @filename
    @data.set :line, lineno

    #$stderr.puts "Parsing cmd='#{cmd}'"

    arga = args.split(/\s+/)

    case cmd
	  when 'title'
        @data.set :name, args
	  when 'kernel'
        @data.set :type, :linux
        @data.set :arg, @data.make_abspath(args)
	  when 'initrd'
        @data.set :initrd, @data.make_abspath(args)
	end 
  end

  def output(stream = $stdout, data = nil)

    h = data.to_hash
    params = data.get(:params)

    stream.puts "title #{data.name}"

    case  data.type
      when :linux_16, :linux, :linux_efi, :com32
        stream.puts "kernel #{data.arg} #{params}"
      when :boot_sector
        stream.puts "chainloader #{data.arg}"

      when :config_file
        stream.puts "configfile #{data.arg}"
    end
    stream.puts
  end


end
