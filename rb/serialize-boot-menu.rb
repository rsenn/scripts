#!/usr/bin/env ruby

require 'yaml'
require 'pp'
require 'optparse'
require_relative 'lib/bootmenu.rb'

options = Hash.new

p = OptionParser.new do |parser|
  parser.banner = "Usage: serialize-boot-menu.rb [options] <file(s)...>"
  parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  parser.on("-fFROM", "--from=FROM", "From type") do |from|
     options[:from] = from
  end
  parser.on("-tTO", "--to=TO", "To type") do |to|
     options[:to] = to
  end
end

p.parse!

from_type = options[:from] ? options[:from].to_sym : nil
to_type = options[:to] ? options[:to].to_sym : nil


if ARGV.length == 0 then
 $stdout.puts p.help
end

ARGV.each do |arg|
  file_name = arg
  if from_type then
	$stderr.puts "From type: #{from_type}"
	$stderr.puts "BootMenuParser(#{from_type}, #{file_name})"
	m = BootMenuParser(from_type, file_name)
  else
	m =  SyslinuxMenu.new file_name
  end
  if to_type then
	to_type = to_type.to_sym
	$stderr.puts "To type: #{to_type}"
  else
	to_type = :grub4dos
  end
  m.read
  $stdout.puts m.serialize(YAML)
#  to = m.dup(to_type)
#  pp m.class, $stderr
#  pp to.class, $stderr
#  to.write($stdout)
end 
