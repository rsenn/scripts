require 'pp'
require_relative 'lib/bootmenu.rb'



m = SyslinuxMenu.new '/mnt/PHILIPS-16G/multibootusb/syslinux.cfg'
m.read
pp m

