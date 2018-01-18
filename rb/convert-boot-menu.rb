require 'pp'
require_relative 'lib/bootmenu.rb'


file_type = nil

if ARGV.length > 0 then
  file_name = ARGV[0]

  if ARGV.length > 1 then
    file_type = ARGV[1].to_sym
  end
else
  file_name = '/mnt/PHILIPS-16G/multibootusb/syslinux.cfg'
end

if file_type then
  m = BootMenuParser(file_type, file_name)
else
  m =  SyslinuxMenu.new file_name
end

m.read
#pp m

g4d = m.dup(:grub4dos)


g4d.write($stdout)

