#!/usr/bin/env ruby
require 'rubygems'
require 'cli'
require 'pathname'
require 'rexml/document'
require 'rexml/encoding'
require 'pp'


require_relative 'lib/jucerfile.rb'

class DirNode < Hash
  def initialize(name=".",parent=nil)
     self[:name] = name
	 self[:files] = []
	 self[:subdirs] = []
	 self[:parent] = parent
  end

  def name
    return self[:name]
  end

  def index_obj(a=[])
    r = self
	if a.is_a? String then a = a.split(/\//) end
	if a.at(0) == "." then a = a.shift end
#   $stderr.print "\nindex_obj: "+a.join("/")+"\n\n"
	fn = a.pop
	$stderr.print "\n"
	a.each do |n|
		  $stderr.print r.to_s+"\n"

	  sd = r[:subdirs].select{ |d| d[:name] == n }[0]
	  if sd == nil then
	    sd = DirNode.new(n, r)
		i = r[:subdirs].size
	    r[:subdirs] = r[:subdirs] << sd
	  else
        i = r[:subdirs].index(sd)
	  end
	  r[:subdirs][i][:parent] = r;
      r = r[:subdirs][i]	 
	end
p = r[:parent	  ]
	r[:files].push fn
    return r
  end
  
  def each(&block)
    
	a = self[:subdirs]
	#a = a.unshift(self)
	a.each do |i| yield i end
  end
  
  def to_s
    r = self
	name = r[:name]
	o = "#{name}"
	p = r[:parent]
	while r = r[:parent] do
	 #if r[:name] != "." then
		o = r[:name]+"\\"+o
	 # end
	end
	o = o.gsub(/^\.[\/\\]/, "")
	o = "'#{o}'"
	if p != nil then
		o += " <parent='"+p[:name]+"'>"
	end
	entries = self[:subdirs].map{|sd| sd[:name]+"/"}+self[:files]
	if entries.size > 0 then
		o += " ['"+entries.join("','")+"']"
	end
    return o
  end
end

def get_sources 
	srcs = []
   srcs += Dir.glob(File.join("**", "*.cpp")).reject{ |e| File.directory? e }
   srcs += Dir.glob(File.join("**", "*.h")).reject{ |e| File.directory? e }
   srcs.sort.map do |s|
      if s.start_with?('./') then s.slice!(2, s.length-2) end
	  """if s.start_with?('src/') then s.slice!(4, s.length-4) end
	  if s.start_with?('Source/') then s.slice!(7, s.length-7) end"""
	  s
   end 
 end
 
def DirNode.get_tree(srcs)
   dn = DirNode.new(".", nil)
   srcs.each do |src| dn.index_obj src end   
   return dn
end

class String
	def clean_path
	  return self.gsub(/^src\//i, "").gsub(/^Source\//i, "").gsub(/\/src$/i, "").gsub(/\/include$/i, "")
	end
end

def get_dirs(srcs=[])
  srcs.map { |s| File.dirname s }.sort.uniq
end

def main
   name = File.basename Dir.pwd
   jf = JucerFile.new
   jf.create name, "audioplug", []
   
 #  jf.create_source_group "src/highlife/FluidSynth/src".clean_path
   
   sr = get_sources #.map{|s| s.clean_path}
   includes = []
   sr.each { |fn| 
     file = File.open(fn)
	 dn = File.dirname(fn)
	 s = file.grep(/.*#\s*include\s*[<"]([^>"]*)[>"].*/)
	 s.each do |s| 
		if s.include? ("<") then next end
		
		s = s.gsub(/.*["<]([^">]*)[">].*/, "\\1").strip
		
		if not File.exists? s and File.exists? s.gsub(/^\.\.\/\.\.\//, "") then		
			s = s.gsub(/^\.\.\/\.\.\//, "")
		end
		if not File.exists? s and File.exists?(dn + "/" + s) then
			s = dn + "/" + s
		end
	   includes.push s
	 end
	 
   }
   pp includes
   jf.add_sources sr
   jf.set_configuration_path("header", ["../../juce"]+get_dirs(sr) )
   jf.set_configuration_path("library", ["../../bin"])
   
#   dn = DirNode.get_tree(sr) 
#   dn.each do |d|
#    $stderr.print "DirNode("+d.to_s+")\n"
#  end
#  
   ret = jf.save "#{name}.jucer"
end
main