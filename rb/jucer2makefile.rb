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
  def join_quoted(sep)
    o = self.map { |s| 
      s = String(s)
      if s.include? ' ' then
        s.escape
      else
        s
      end
    }
    #pp o
    o.join(sep)
  end
end

class String
  def canonicalize
    return self.gsub(/[^_A-Za-z0-9]\+/, "_")
  end
  def doublequote
    if self.include? ' ' then
      return '"'+self+'"'
    else
      return self
    end
  end
  def escape
    self.gsub(/ /, '\\ ')
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

  $stderr.puts "Entering directory '#{dir}'"

  Dir.chdir dir

  $stderr.puts "Reading '#{dir}/#{infile}'"

  myfile = JucerFile.new
  myfile.read infile 

  $stderr.puts "Writing '#{dir}/#{outfile}'"

  of = MakeFile.clone myfile
  of.write File.new(dir+"/"+outfile, "w+", 0644)


def write_header(fn, name, version, modulepaths)
  header = File.new(fn, "w+", 0644)
  header.puts '#ifndef JUCE_HEADER_H
#define JUCE_HEADER_H

//#include "JuceLibraryCode/AppConfig.h"

#ifndef JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED
#define JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED 1
#endif


'
  modulepaths.each do |id,path|
    header.puts "#include \"#{path}/#{id}/#{id}.h\"\n"
  end

  header.puts "
#if ! DONT_SET_USING_JUCE_NAMESPACE
// If your code uses a lot of JUCE classes, then this will obviously save you
// a lot of typing, but can be disabled by setting DONT_SET_USING_JUCE_NAMESPACE.
using namespace juce;
#endif

#if ! JUCE_DONT_DECLARE_PROJECTINFO
namespace ProjectInfo
{
    const char* const  projectName    = \"#{name}\";
    const char* const  versionString  = \"#{version}\";
    const int          versionNumber  = 0;
}
#endif

#endif //JUCE_HEADER_H
"
end

def write_appconfig(fn)
    header = File.new(fn, "w+", 0644)
  header.puts '#ifndef JUCE_APPCONFIG_H
#define JUCE_APPCONFIG_H


#endif //JUCE_APPCONFIG_H
'
end

  write_header dir+"/JuceHeader.h", myfile.header[:name], myfile.header[:version], myfile.modulepaths
  write_appconfig dir+"/AppConfig.h"

  $stderr.puts "To run:\n    make -C '#{dir}' -f '#{outfile}'"

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