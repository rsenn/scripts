#!/usr/bin/env ruby
require 'rexml/document'
require 'pp'

require_relative 'lib/hash_array.rb'
require_relative 'lib/enum.rb'

class BuildFile
	class BuildType < Enum
		enum_attr :guiapp
		enum_attr :consoleapp
		enum_attr :library
		enum_attr :dll
		enum_attr :audioplug
	end

	attr_accessor :build_type
	attr_accessor :sources, :targets
	attr_accessor :compile_flags, :link_flags

	def initialize
      raise 'Doh! You are trying to instantiate an abstract class!'
	end

	def read(filename)
      raise 'Doh! You are trying to call a method on an abstract class!'
	end
	def write
      raise 'Doh! You are trying to call a method on an abstract class!'
	end

end

class JucerFile < BuildFile

	""" initialize(filename) """
	def initialize(filename=nil)
		if filename != nil then
			read filename
		end
	end

	def read(filename)
		@file = REXML::Document.new File.new(filename)
	end

	def write(o=$stdout)
		@file.write(o)
		$stdout << "\n"
	end

	def targets
		@file.elements.to_a("/JUCERPROJECT").map { |e| e.attribute("name") }
	end

	def build_type
		BuildType.new @file.elements.to_a("/JUCERPROJECT")[0].attribute("projectType").to_s
	end

	def sources
		list = files.keep_if do |s| 
			s['resource'] != "1" && s['compile'] == "1"
		end	
		list.map do |s|
			s['file']
		end		
	end

	def compile_flags
		HashArray.get_elements("exportformats/*", @file).map { |e| e["extraCompilerFlags"] }
	end

	private

	def files
		HashArray.get_elements("file", @file)
	end	
end

myfile = JucerFile.new("/mnt/tmpdata/JuceSources/JUCE-soundradix/extras/Projucer/Projucer.jucer")

pp myfile.sources
pp myfile.targets
pp myfile.compile_flags
pp myfile.build_type
#myfile.write($stdout)