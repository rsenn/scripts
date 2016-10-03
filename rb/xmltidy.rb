#!/usr/bin/env ruby

require 'nokogiri-pretty'
require 'optparse'
require 'pp'

options = {
  :inplace => false,
  :indent => 2,
  :charset => "UTF-8",
}

begin
  myname = File.basename($0)

  OptionParser.new do |opts|
    opts.banner = "Usage: #{myname} [options] [file]"
    opts.separator ""
    opts.separator "Specific options:"
    opts.on("-i", "--inplace", "In place") do |i|  options[:inplace] = i   end
    opts.on("-n", "--indent N", Integer, "Indentation depth") do |n| options[:indent] = n  end
    opts.on("-c", "--charset N", String, "Character encoding") do |c| options[:charset] = c  end
    
    # No argument, shows at tail.  This will print an options summary.
    # Try it and see!
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end

  end.parse!

  pp options
  file_name = ARGV.shift
  
  doc = Nokogiri::XML(if file_name != nil
    open(file_name) else $stdin
  end) do |cfg|
	cfg.options = Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::NONET | Nokogiri::XML::ParseOptions::NOERROR
  end

  output_file = if options[:inplace]
    File.open(file_name, File::CREAT|File::TRUNC|File::WRONLY, 0644)
  else
    $stdout
  end
	  
  output_file.write doc.to_xml :indent => options[:indent], :encoding => options[:charset]
#  output_file.write doc.human
  output_file.close
  

end