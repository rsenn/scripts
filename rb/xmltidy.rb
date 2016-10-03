#!/usr/bin/env ruby

require 'nokogiri-pretty'
require 'optparse'

options = {
  :inplace => false,
  :indent => 2,
}

begin

  OptionParser.new do |opts|
    opts.banner = "Usage: main.rb [options]"
    opts.separator ""
    opts.separator "Specific options:"
    opts.on("-i", "--inplace", "In place") do |i|  options[:inplace] = i   end
    opts.on("-n", "--indent N", Integer, "Indentation depth") do |n| options[:indent] = n  end
    
    # No argument, shows at tail.  This will print an options summary.
    # Try it and see!
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end

  end.parse!

  p options
  file_name = ARGV.shift
  doc = Nokogiri::XML(open(file_name)) do |cfg|
	cfg.options = Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::NONET | Nokogiri::XML::ParseOptions::NOERROR
  end

  output_file = if options[:inplace]
    File.open(file_name, File::CREAT|File::TRUNC|File::WRONLY, 0644)
  else
    $stdout
  end
	  
  output_file.write( doc.to_xml :indent => options[:indent], :encoding => "UTF-8" )
  output_file.close
  #$stdout.puts doc.human

end