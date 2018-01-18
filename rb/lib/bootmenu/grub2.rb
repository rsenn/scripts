class Grub2Menu < BootMenu

  def initialize(filename = '')
     super(:grub2, filename)
  end

  def parse_line(line = '', lineno = -1)
    toks = line.lstrip.split(/\s+/)
    cmd = toks.shift
    args = toks.join ' '
      
    if not cmd.is_a? String then return end
    cmd = cmd.downcase

    arga = args.split(/\s+/)


    case cmd
	  when 'menuentry'
        if args[0] == '"' then
          args = args.split(/"/)[1]
        end
        if args[0] == "'" then
          args = args.split(/'/)[1]
        end
        @data.set :name, args
#    $stderr.puts "Parsed: #{cmd} #{args}, data=#{@data}"
	  when 'linux16', 'linux', 'linuxefi'
        @data.set :type, cmd.to_sym
        @data.set :arg, @data.make_abspath(args)
	  when 'initrd16', 'initrd', 'initrdefi'
        @data.set :initrd, @data.make_abspath(args)
	end 
  end

  def output(stream = $stdout, data = nil)

    params = data.get(:params)

    stream.puts "menuentry '#{data.name}' {"

    case  data.type
      when :linux16, :linux, :linuxefi, :com32
        stream.puts "kernel #{data.arg} #{params}"
      when :boot_sector
        stream.puts "chainloader #{data.arg}"

      when :config_file
        stream.puts "configfile #{data.arg}"
    end
    stream.puts "}" 
  end
end
