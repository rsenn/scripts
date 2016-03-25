#!/usr/bin/env ruby

require 'rexml/document'
require 'pp'

class JucerProject < REXML::Document

	@@quote = "\""

	attr_accessor :project, :options, :files, :modules, :modulepaths, :configurations

	  def self.quote
			  @@quote
					  end

  def load
		@project = get_element("jucerproject")
		@options = get_element("juceoptions")
		@files = get_elements("file")
		@modules = get_elements("module")
		@modulepaths = get_elements("modulepath")
		@configurations = get_elements("configuration")
	end

	def JucerProject.hash2str(h, name="")
			"{{" + (name != "" ? "<"+name+">" : "") + h.map { |k,v| k.to_s + "=" + @@quote + v.to_s + @@quote }.join(",") + "}}"
	end

	""" Convert a REXML Elements List to a List of Hashes """
	def JucerProject.elements2hashes(elems) 
		elems.map { |e|	JucerHash.new(e) }.delete_if { |h| h.size == 0 }
	end

	""" Output a debug message """
	def JucerProject.debug(o)
		STDOUT.puts o.to_s
	end

  class JucerHash < Hash
		@tagname = ''
	  attr_accessor :tagname
		def initialize(elem=REXML::Element.new,name="")
			super({})
			if elem.is_a? REXML::Element then
				elem.attributes.each do |n,a|
					self.store(n, a.to_s)
				end
        @tagname = elem.name
			elsif elem.is_a? Hash then
				self.merge!(elem)
				@tagname = name
			end
		end
		def to_s(name=@tagname)
			name + " { " + self.map { |k,v| k + "=" + JucerProject.quote + v + JucerProject.quote }.join(", ") + " }"
		end
	end

  class HashArray < Array
		@tagname = ''
	  attr_accessor :tagname
		def initialize(elems)
			if elems.size > 0 and elems.first.is_a? REXML::Element then
				super JucerProject.elements2hashes(elems) 
				@tagname = String(elems.first.name)
			elsif elems.is_a? HashArray or (elems.size > 0 and elems.first.is_a? JucerHash) then
				super elems
				@tagname = elems.is_a?(HashArray) ? elems.tagname : elems.first.tagname
			else
				super []
			  @tagname = ""
			end
		end
		def to_s
      arr = self
		  self.tagname + "[[\n " + self.map { |h| 
				i = arr.find_index(h)
			 if not h.is_a? JucerHash then h = JucerHash.new h end
			 if h.is_a? JucerHash then
				 h.to_s( (h.tagname != "" ? h.tagname : self.tagname) + i.to_s )
			else
         JucerProject.hash2str(h, self.tagname)
			 end
			}.join(",\n ") + "\n]]"
		end
		def merge_all
			ret = JucerHash.new
			self.each { |h|
				ret = h.merge ret
			}
			return ret
		end
		def map_cond(name, value=nil) 
			HashArray.new(self.map { |h| 
				if (value != nil and h[name] != value) or (value == nil and !h.has_key?(name)) then
					h = nil
				else
				  JucerHash.new h
				end
			}.delete_if { |h| h == nil })
		end
	end
             
	def get_elements(s)
   HashArray.new self.elements.to_a("//" + s.upcase)
	end

	def get_element(s)
    get_elements(s).merge_all
	end
	
end

 filename = ARGV[0]
file = File.new filename

JucerProject.debug "Opening document #{filename}"
doc = JucerProject.new file

doc.load
#jucerproject = doc.get_elements("jucerproject")
#juceoptions = doc.get_elements("juceoptions")
#files = doc.get_elements("FILE")
#modules = doc.get_elements("MODULES")

JucerProject.debug doc.files.map_cond("compile", "1") 

JucerProject.debug doc.project
JucerProject.debug doc.options
#JucerProject.debug juceoptions
#JucerProject.debug modules 

