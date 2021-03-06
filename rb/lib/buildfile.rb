require_relative 'enum.rb'

""" BuildFile -------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """
class BuildFile
  class ProjectType < Enum
    enum_attr :guiapp, 1
    enum_attr :consoleapp, 2
    enum_attr :library, 3
    enum_attr :dll, 4
    enum_attr :audioplug, 5
  end

  attr_accessor :project_type, :configurations
  attr_accessor :sources, :targets
  attr_accessor :defines, :compile_flags, :link_flags, :libs

  def initialize(type = nil, sources = [], targets = [], compile_flags = "-g -O2 -Wall", link_flags = "-static-libgcc -static-libstdc++", libs = [])

     @project_type = (type.instance_of? ProjectType) ? type : ProjectType.new(type)
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

def clean_list(s) 
  if s.instance_of? Array then
    s = s.join("\n")
  end
  s.split(/\s+/).uniq
end 

def split_and_concat_uniq(s, sep = " ") 
  clean_list(s).join(sep)
end 
