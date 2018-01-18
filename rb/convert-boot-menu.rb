require 'pp'
require_relative 'lib/bootmenu.rb'


from_type = nil

if ARGV.length > 0 then
  file_name = ARGV[0]

  if ARGV.length > 1 then
    from_type = ARGV[1]
    if ARGV.length > 2 then
      to_type = ARGV[2]
    end
  end
else
  file_name = '/mnt/PHILIPS-16G/multibootusb/syslinux.cfg'
end

if from_type then
  $stderr.puts "BootMenuParser(#{from_type}, #{file_name})"
  m = BootMenuParser(from_type, file_name)
else
  m =  SyslinuxMenu.new file_name
end

if to_type then
  to_type = to_type.to_sym
else
  to_type = :grub4dos
end


m.read
#pp m

to = m.dup(to_type)

pp m.class
pp to.class

to.write($stdout)

