#!/usr/bin/env ruby

require 'rubygems'
require 'cli'
require 'pathname'
require 'rexml/document'
require 'rexml/encoding'
require 'json'
require 'pp'

require_relative 'lib/hash_array.rb'
require_relative 'lib/enum.rb'
require_relative 'lib/makefile.rb'
require_relative 'lib/jucerfile.rb'

class Array
  def push_unique(*args)
    args.each do |a|
      if self.index(a) == nil then
        self.push(a)
      end
    end
  end
end

class String
  def canonicalize
    return self.gsub(/[^_A-Za-z0-9]\+/, "_")
  end
  def doublequote
    return '"'+self+'"'
  end
end

def main
  settings = CLI.new do
    switch   :debug,       :short => :d,                     :description => 'debug messages'
    argument :input_file,  :short => :i,                     :description => 'input file' #, :default => "/mnt/tmpdata/Sources/ctrlr/Builds/VST/Ctrlr_Plugin_VST.jucer"
    argument :output_file, :short => :o, :required => false, :description => 'output file'
  end.parse! do |settings|
    fail "No such file '#{settings.input_file}'" unless File.exist? String(settings.input_file)
  end

  dir = File.dirname(settings.input_file)
  name = File.basename(settings.input_file, ".jucer")
  infile = File.basename(settings.input_file.to_s)

  if settings.output_file then
    outfile = settings.output_file.gsub(/#name/, name)
  else
    outfile = "Makefile.#{name}"
  end

  $stderr.puts "Entering directory #{dir} ..."

  Dir.chdir dir

  $stderr.puts "Reading '#{infile}' ..."

  myfile = JucerFile.new
  myfile.read infile 

  $stderr.puts "Writing '#{outfile}' ..."

  of = MakeFile.clone myfile
  of.write(File.new(dir+"/"+outfile, "r+", 0644))

  $stderr.puts "To run: make -C #{dir} -f #{outfile}"

  if settings.debug then
    $stdout.puts "sources: "+ myfile.sources.flatten.join(" ")
    $stdout.puts "targets: "+ myfile.targets.join(" ")
    $stdout.puts "project type: " +myfile.project_type.to_s
    $stdout.puts "defines: "+ myfile.defines("Release", "VS*")
    $stdout.puts "compile flags: "+myfile.compile_flags("*LIN*")
    $stdout.puts "link flags: "+myfile.link_flags("*LIN*")
    $stdout.puts "configurations: "+myfile.configurations.join(", ")

    #myfile.write($stdout)
  end
end

main