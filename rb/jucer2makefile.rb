#!/usr/bin/env ruby

require 'rexml/document'
require 'rexml/encoding'
require 'json'
require 'pp'

require_relative 'lib/hash_array.rb'
require_relative 'lib/enum.rb'
require_relative 'lib/makefile.rb'

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

""" BuildFile -------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """
class BuildFile
  class ProjectType < Enum
    enum_attr :guiapp
    enum_attr :consoleapp
    enum_attr :library
    enum_attr :dll
    enum_attr :audioplug
  end

  attr_accessor :project_type, :configurations
  attr_accessor :sources, :targets
  attr_accessor :defines, :compile_flags, :link_flags, :libs

  def initialize(type = nil, sources = [], targets = [], compile_flags = "-g -O2 -Wall", link_flags = "-static-libgcc -static-libstdc++", libs = [])

     @project_type = ProjectType.new type
     @configurations = [ "Debug", "Release" ]
     @sources = sources
     @targets = targets
     @compile_flags = compile_flags
     @link_flags = link_flags
     @libs = libs


     update_properties
#      raise 'Doh! You are trying to instantiate an abstract class!'
  end

  def read(filename)
      raise 'Doh! You are trying to call a method on an abstract class!'
  end
  def write
      raise 'Doh! You are trying to call a method on an abstract class!'
  end

  protected

  def add_property(name, value = nil)
    instance_eval { class << self; self end }.send(:attr_accessor, name.to_s.gsub(/^@*/,""))
    if value != nil then
      self.instance_variable_set(name, value)
    end
  end


  def update_properties
  end
end

def split_and_concat_uniq(s, sep = " ") 
  if s.instance_of? Array then
    s = s.join("\n")
  end
  s.split(/\s+/).uniq.join(sep)
end 

""" JucerFile -------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """
class JucerFile < BuildFile
  attr_accessor :file

  """ initialize(filename) """
#  def initialize
#    super.initialize
#    if filename != nil then
#      read filename
#    end
#  end

  def read(filename)
    @file = REXML::Document.new File.new(filename)
  end

  def write(o=$stdout)
    @file.write(o)
    $stdout << "\n"
  end

  def targets
    @file.elements.to_a("/JUCERPROJECT").map { |e| e.attribute("name").to_s }
  end

  def project_type
    ProjectType.new @file.elements.to_a("/JUCERPROJECT")[0].attributes["projectType"]
  end

    """ Returns a list of source files """
  def sources
    h = Hash.new
    h[targets[0]] = files "@compile=1" # and @resource=0"
    return h
  end

    """ Returns a list of ressource files """
  def resources
    files "@resource=0"
  end

    """ Returns compile flags for all the exporters which match the given expression """
  def compile_flags(exporter = "*", sep = " ")
    split_and_concat_uniq attribute("extraCompilerFlags", exporter).values, sep
  end

    """ Returns link flags for all the exporters which match the given expression """
  def link_flags(exporter = "*", sep = " ")
    f = linker(exporter, sep).map do |arg|
      if not arg.match(/^[-\/][Ll]/) then
        arg
      end
    end
    f.join(" ")
  end

    """ Returns libraries for all the exporters which match the given expression """
  def libs(exporter = "*", sep = " ")
    f = linker(exporter, sep).map do |arg|
      if arg.match(/^[-\/][Ll]/) then
        arg
      end
    end
    f.join(" ")
  end

    """ Returns link flags for all the exporters which match the given expression """
  def defines(configuration = "*", exporter = "*", sep = " ", prefix = "-D")
    r = configuration_attribute("defines", exporter).select do |k,v| 
      configuration == "*" or k.match(configuration) or k == configuration
    end.values.join("\n")

    #r = split_and_concat_uniq(r.values, "\n")

    r.split(/\s+/).map { |v| prefix + v }.join(sep)
  end

    """ Returns all configuration names """
  def configurations(exporter = "*")
    r = Array.new
    export_formats(exporter).each do |f|
      REXML::XPath.each(f, "//CONFIGURATION") do |c|
        r.push_unique c.attributes["name"]
      end
    end
    r
  end

  private
    """ Returns link flags for all the exporters which match the given expression """
  def linker(exporter = "*", sep = " ")
    
    f = Array.new


    configuration_attribute("libraryPath", exporter).values.each do |libpath|
      libpath.split(/\n/).each do |p|
        p.strip!
        p.gsub!(/\/*$/, "")

#        p.gsub!(/^\${([^}]*)}/, "$(\\1)")
        if p.match(/^\$[\({].*[\)}]$/) then next end

        if p.match('[^A-Za-z0-9\\\\_/\${}\(\)]') then 
          f.push_unique "-L "+p.doublequote 
        else
          f.push_unique "-L#{p}"
        end
      end
    end

    f += attribute("extraLinkerFlags", exporter).values

    f.delete("")
    f
  end

    """ Returns a list of files """
  def files(cond="")
    r = Array.new
    REXML::XPath.each(@file, "//FILE" + (cond == "" ? "" : "["+cond+"]")) do |f|
      r.push f.attributes["file"]
    end
    return r
  end  

  def export_formats(exporter = "*")
    expr = "//EXPORTFORMATS/*"
    if exporter != "*" then
      expr += "[contains(name(),'"+exporter.gsub("*","")+"')]"
    end
    REXML::XPath.match(@file, expr)
  end

  def attribute(name, exporter = "*")
    r = Hash.new
    export_formats(exporter).each do |f|
      n = f.attributes[name]
      if n != nil then r[f.name] = n end
    end
    r
  end

  def configuration_attribute(name, exporter = "*")
    r = Hash.new
    export_formats(exporter).each do |f|
      REXML::XPath.each(f, "//CONFIGURATION") do |c|
        cfgname = c.attributes["name"]
        a = c.attributes[name]
        if a != nil then
          if r.has_key?(cfgname) then
            a = split_and_concat_uniq(r[cfgname]+"\n"+a, "\n")
          end
          r[cfgname] = a
        end
      end
    end
    r
  end

end



myfile = JucerFile.new
myfile.read "/mnt/tmpdata/Sources/ctrlr/Builds/VST/Ctrlr_Plugin_VST.jucer" #{}"/mnt/tmpdata/JuceSources/JUCE-soundradix/extras/Projucer/Projucer.jucer" #{} #

#pp myfile.attribute("extraCompilerFlags")
#pp myfile.export_formats("*LIN*")
#pp myfile.attribute("extraCompilerFlags", "*")
#pp myfile.attribute("extraLinkerFlags", "*")

makefile = MakeFile.clone myfile
makefile.write(File.new("Makefile.new", File::CREAT|File::TRUNC|File::WRONLY, 0644))

puts "sources: "+ myfile.sources.flatten
.join(" " )
puts "targets: "+ myfile.targets.join(" ")
puts "project type: " +myfile.project_type.to_s
puts "defines: "+ myfile.defines("Release", "VS*")
puts "compile flags: "+myfile.compile_flags("*LIN*")
puts "link flags: "+myfile.link_flags("*LIN*")
puts "configurations: "+myfile.configurations.join(", ")

#myfile.write($stdout)