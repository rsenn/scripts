#!/usr/bin/env ruby
require 'pp'
require 'optparse'
require 'bootmenu.rb'

options = Hash.new

OptionParser.new do |parser|
  parser.banner = "Usage: convert-boot-menu.rb [options] <file(s)...>"
  parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  parser.on("-fFROM", "--from=FROM", "From type") do |from|
     options[:from] = from
  end
  parser.on("-fTO", "--to=TO", "To type") do |to|
     options[:to] = to
  end
end.parse!

from_type = options[:from] ? options[:from].to_sym : nil
to_type = options[:to] ? options[:to].to_sym : nil

ARGV.each do |arg|
  file_name = arg
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
  to = m.dup(to_type)
  pp m.class
  pp to.class
  to.write($stdout)
end
