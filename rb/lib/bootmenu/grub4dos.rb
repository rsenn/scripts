class Grub4dosMenu < BootMenu

  def initialize(filename = '')
     super(:grub4dos, filename)
  end

  def parse_line(line = '', lineno = -1)
    toks = line.lstrip.split(/\s+/)
    cmd = toks.shift
    args = toks.join ' '
      
    if not cmd.is_a? String then return end
    cmd = cmd.downcase

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

    if data.is_a? Object then
      params = data.get(:params)
    else
      params = ''
    end

    stream.puts "title #{data.name}"

    case  data.type
      when :linux16, :linux, :linuxefi, :com32
        stream.puts "kernel #{data.arg} #{params}"
      when :boot_sector
        stream.puts "chainloader #{data.arg}"

      when :config_file
        stream.puts "configfile #{data.arg}"
    end
    stream.puts
  end
end
