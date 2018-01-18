require 'pp'
require_relative 'lib/bootmenu.rb'



if ARGV.length > 0 then
  file_name = ARGV[0]
else
  file_name = '/mnt/PHILIPS-16G/multibootusb/syslinux.cfg'
end

m = SyslinuxMenu.new file_name
m.read


g4d = m.dup(:grub4dos)
#pp m


g4d.write($stdout)

