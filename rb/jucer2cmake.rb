#!/usr/bin/env ruby

require 'rexml/document'
require 'pp'

class JucerProject < REXML::Document

	@@quote = "\""

	attr_accessor :project, :options, :files, :modules, :modulepaths, :exportformats, :configurations

	  def self.quote
			  @@quote
					  end

  def load
		@project = get_element("jucerproject")
		@options = get_element("juceoptions")
		@files = get_elements("file")
		@modules = get_elements("module")
		@modulepaths = get_elements("modulepath")
		@exportformats = get_elements("exportformats/*")
		@configurations = get_elements("configuration")
	end

  def properties
		 { 
			:project => @project, 
			:options => @options,
			:files => @files.get_value("file"),
			:modules => @modules,
			:modulepaths => @modulepaths.get_hash("id","path"),
			:exportformats => @exportformats,
			:configurations => @configurations,
		}
	end

	def JucerProject.hash2str(h, name="", multiline=false)
			if multiline then
				ml_t = "\n"
				ml_s = "#{ml_t}  "
      end
	  	"{{#{ml_s}" + (name != "" ? "<"+name+">" : "") + h.map { |k,v| k.to_s + "=" + @@quote + v.to_s + @@quote }.join(",#{ml_s}") + "#{ml_t}}}"
	end

	""" Convert a REXML Elements List to a List of Hashes """
	def JucerProject.elements2hashes(elems) 
		elems.map { |e|	JucerHash.new(e) }.delete_if { |h| h.size == 0 }
	end

	""" Output a debug message """
	def JucerProject.debug(o,l="")
		if l != "" then
		  l = String(l) + ": "
		end
		STDOUT.puts l + o.to_s
	end

  class JucerHash < Hash
		@tagname = ''
		@tagpath = ''
	  attr_accessor :tagname, :tagpath
		def initialize(elem=REXML::Element.new,name="")
			super({})
			if elem.is_a? REXML::Element then
				elem.attributes.each do |n,a|
					self.store(n, a.to_s)
				end
        @tagname = elem.name
				@tagpath = elem.xpath.gsub(/^\/*[A-Z]+\//, "").downcase
			elsif elem.is_a? Hash then
				self.merge!(elem)
				@tagname = name
				@tagpath = "//"+name
			end
		end
		def to_s(multiline=false, name=@tagname)
			if @tagpath != "" then name = @tagpath end
			if multiline then
				ml_t = "\n"
				ml_s = "#{ml_t}  "
      end
		  name + " {#{ml_s}" + self.map { |k,v| k + "=" + JucerProject.quote + v + JucerProject.quote }.join(",#{ml_s}") + "#{ml_t}}"
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
		def to_s(multiline=false, name=@tagname)
      arr = self
		  name + "[[\n " + self.map { |h| 
				i = arr.find_index(h)
			 if not h.is_a? JucerHash then h = JucerHash.new h end
			 if h.is_a? JucerHash then
				 h.to_s( multiline, (h.tagname != "" ? h.tagname : self.tagname) + i.to_s )
			else
         JucerProject.hash2str(h, self.tagname, multiline)
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
		def get_hash(attr_key, attr_value) 
      r = Hash.new
			self.map { |h|
        k = h[attr_key]
        v = h[attr_value]
				r[k.to_sym] = v
			}
			return r
		end
		def get_value(name) 
			self.map { |h|
				h[name]
			}
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

JucerProject.debug doc.files.map_cond("compile", "1").get_value("file")

p = doc.properties
p.each do |k,v| 
  JucerProject.debug(v.to_s(true), "\033[1;31mproperties."+k.to_s+"\033[0m")
end

