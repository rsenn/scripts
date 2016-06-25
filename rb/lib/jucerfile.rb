require 'securerandom'
require_relative 'buildfile.rb'

def randstr(size=8)
  	( ('0'..'9').to_a \
	+ ('a'..'z').to_a \
	+ ('A'..'Z').to_a ).shuffle.first(size).join
end
	


""" JucerFile -------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """
class JucerFile < BuildFile
  attr_accessor :file, :modules, :name
  """ initialize(filename) """

  def create(name, type="guiapp", modules = nil)
    @name = name
    @file = REXML::Document.new
	e = REXML::Element.new "JUCERPROJECT"
	if modules == nil then
	  @modules = [ 
		"juce_audio_basics", "juce_audio_devices", "juce_audio_formats", "juce_audio_plugin_client", "juce_audio_processors", "juce_audio_utils", "juce_box2d", "juce_core", "juce_cryptography", "juce_data_structures", "juce_events", "juce_graphics", "juce_gui_basics", "juce_gui_extra", "juce_opengl", "juce_osc", "juce_tracktion_marketplace", "juce_video"
	  ]
	else
	  @modules = modules
	end
	id = randstr
	e.add_attributes( {	"id" => id,
		"name" => name,
		"projectType" => type,
		"version" => "1.0.0",
		"buildVST" => 1,
		"buildRTAS" => 0,
		"buildAU" => 0,
		"pluginName" => "#{name}",
		"pluginDesc" => "#{name}",
		"pluginManufacturer" => "JUCE",
		"pluginManufacturerCode" => "JUCE",
		"pluginCode" => "Jcdm",
		"pluginChannelConfigs" => "{1, 1}, {2, 2}",
		"pluginIsSynth" => 0,
		"pluginWantsMidiIn" => 1,
		"pluginProducesMidiOut" => 1,
		"pluginSilenceInIsSilenceOut" => 0,
		"pluginTailLength" => 0,
		"pluginEditorRequiresKeys" => 1,
		"pluginAUExportPrefix" => "#{name}AU",
		"pluginAUViewClass" => "#{name}AU_V1",
		"pluginRTASCategory" => "",
		"bundleIdentifier" => "com.juce.#{name}",
		"aaxIdentifier" => "com.yourcompany.#{name}",
		"buildAAX" => 0,
		"pluginAAXCategory" => "AAX_ePlugInCategory_Dynamics",
		"includeBinaryInAppConfig" => 1,
		"buildVST3" => 1,
		"pluginIsMidiEffectPlugin" => 0
		})
	@file << e
	
	self.add_exporter "LINUX_MAKE"

	mlist = REXML::Element.new "MODULES"
	@modules.each do |m| 
	  me = REXML::Element.new "MODULE"
	  me.add_attributes( { "id" => m, "showAllCode" => 1, "useLocalCopy" => 0 } )
	  mlist.add_element me
	end
	e.add_element mlist
	
	jo = REXML::Element.new "JUCEOPTIONS"
	dis = "disabled"
	en = "enabled"
	jo.add_attributes({ 
		"JUCE_ALSA" => en,
		"JUCE_ASIO" => en,
		"JUCE_BUILD_ACTIVEX" => dis,
		"JUCE_BUILD_NPAPI" => dis,
		"JUCE_CHECK_MEMORY_LEAKS" => dis,
		"JUCE_DIRECTSHOW" => en,
		"JUCE_DIRECTSOUND" => en,
		"JUCE_ENABLE_LIVE_CONSTANT_EDITOR" => dis,
		"JUCE_ENABLE_REPAINT_DEBUGGING" => dis,
		"JUCE_FORCE_DEBUG" => dis,
		"JUCE_INCLUDE_ZLIB_CODE" => en,
		"JUCE_JACK" => en,
		"JUCE_LOG_ASSERTIONS" => dis,
		"JUCE_MEDIAFOUNDATION" => en,
		"JUCE_ONLY_BUILD_CORE_LIBRARY" => dis,
		"JUCE_OPENGL" => en,
		"JUCE_PLUGINHOST_AU" => dis,
		"JUCE_PLUGINHOST_VST" => en,
		"JUCE_PLUGINHOST_VST3" => en,
		"JUCE_QUICKTIME" => en,
		"JUCE_SUPPORT_CARBON" => en,
		"JUCE_USE_ANDROID_OPENSLES" => en,
		"JUCE_USE_CAMERA" => en,
		"JUCE_USE_CDBURNER" => en,
		"JUCE_USE_CDREADER" => en,
		"JUCE_USE_COREIMAGE_LOADER" => dis,
		"JUCE_USE_CURL" => en,
		"JUCE_USE_DIRECTWRITE" => en,
		"JUCE_USE_FLAC" => en,
		"JUCE_USE_LAME_AUDIO_FORMAT" => en,
		"JUCE_USE_MP3AUDIOFORMAT" => en,
		"JUCE_USE_OGGVORBIS" => en,
		"JUCE_USE_WINDOWS_MEDIA_FORMAT" => en,
		"JUCE_USE_XCURSOR" => en,
		"JUCE_USE_XINERAMA" => en,
		"JUCE_USE_XRENDER" => en,
		"JUCE_USE_XSHM" => en,
		"JUCE_WASAPI" => en,
		"JUCE_WASAPI_EXCLUSIVE" => dis,
		"JUCE_WEB_BROWSER" => dis,
	})
	e.add_element jo
  end
  
  def add_exporter(name)
    ef = @file.elements.to_a("/JUCERPROJECT/EXPORTFORMATS")[0]

    if not ef.is_a? REXML::Element then 
	  ef = REXML::Element.new("EXPORTFORMATS")
	  @file.root << ef
	end	

	exp = REXML::Element.new name
	builddir = name.gsub(/[^[:alnum:]]*Make.*/i, "").capitalize
	exp.add_attributes({
      "targetFolder" => "Builds/#{builddir}",
      "vstFolder" => "",
      "rtasFolder" => "~/SDKs/PT_80_SDK",
      "vst3Folder" => "",
      "packages" => "freetype2",
	})
	
	ctr = REXML::Element.new "CONFIGURATIONS"
	ef.add_element exp
	exp.add_element ctr
	[ "Debug", "Release" ].each do |s|
	  cfg = REXML::Element.new "CONFIGURATION"
	  is_dbg = (s == "Debug")
	  opt = is_dbg ? 0 : 1
	  cfg.add_attributes( {
		 "name" => s, 
		 "isDebug" => is_dbg, 
		 "optimisation" => opt, 
		 "targetName" => "#{@name}", 
		 "libraryPath" => "",
	  })
	  ctr.add_element cfg
	end
	
	ctr = REXML::Element.new "MODULEPATHS"
	exp.add_element ctr
	@modules.each do |m|
	  mp = REXML::Element.new "MODULEPATH"
	  mp.add_attributes( { "id" => m, "path" => "../../modules" } )
	  ctr << mp
	end
  end
	
  def read(filename)
    @file = REXML::Document.new File.new(filename)
  end

  def write(o=$stdout)
    @file.write \
		:output => o, 
		:indent => 2, 
		:transtive => true, 
		:encoding =>  'UTF-8'
    o << "\n"
  end
  
  def main_group
      mg = @file.elements.to_a("/JUCERPROJECT/MAINGROUP)")[0]
	 if not mg.is_a? REXML::Element then
		mg = REXML::Element.new "MAINGROUP"
		mg.add_attributes( { "id" =>  randstr , "name" => @name  })
		@file.root << mg
	 end
	 return mg
  end
  
  def create_source_group(path="",parent_group=nil)
  #$stderr.print "source_group: #{path}\n"
    if parent_group == nil then
	  parent_group = main_group
	end
	path.split(/[\/\\]/).each do |p|
	   if p == "." then next end
	   ge = REXML::XPath.each(parent_group, "//GROUP[@name='#{p}']").to_a[0]
	   if not ge.is_a? REXML::Element then
	     ge = REXML::Element.new("GROUP")
		 ge.add_attributes({ "id" => randstr, "name" => p})
	     parent_group.add_element ge
	   end
	   parent_group = ge
	end
	return parent_group
  end
  
  def set_configuration_path(name="header",header_path=[])
	h = header_path.map { |hp| "../../"+hp }.join("\n")
	n = name + "Path"
    REXML::XPath.each(@file, "//CONFIGURATION") do |e|
			 e.add_attribute(n, h)
	end
  end

  
  def add_sources(s=[]) 
    
	 s.each do |sf|
	    if sf.start_with? "./" then
		  sf = sf.slice(2, sf.size - 2)
		end
		sn = sf
		if sn.include? "src/" then sn = sn.gsub(/src\//, "") end
		if sn.include? "Source/" then  sn = sn.gsub(/Source\//, "") end
	    g = create_source_group File.dirname(sn)
		
		fe = REXML::Element.new "FILE"
		compile = /\.c/.match(File.extname sf) ? 1 : 0
		fe.add_attributes( { "id" => randstr, "name" => File.basename(sf), "file" => sf, "compile" => compile, "resource" => 0 })
		g.add_element fe
	end
  end

  def save(filename)
	f = File.open(filename, "w", 0644)
    ret = self.write f
	f.close
	return ret
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
    h[targets[0]] = files "@compile=1" # or @resource=1"
	if header[:includeBinaryInAppConfig] == "1" then
	  h[targets[0]].push_unique "JuceLibraryCode/BinaryData.cpp"
	end
    modulepaths.each do |id,path|
      s = "#{path}/#{id}/#{id}.cpp"
      h[targets[0]].push_unique s
    end
    return h
  end

  """ Returns a list of ressource files """
  def resources
    files "@resource=0"
  end

  """ Returns compile flags for all the exporters which match the given expression """
  def compile_flags(exporter = "*", sep = " ") 
    r = attribute("extraCompilerFlags", exporter).values.join(" ").split(/\s+/)
    r += modulepaths.values.uniq.map { |p| "-I#{p}" }
    r.push_unique "-I."
  r.push_unique "-I JuceLibraryCode"
    attribute("packages", exporter).each do |e,p|
      r.push_unique "$(shell $(CROSS_COMPILE)pkg-config --cflags #{p})"
    end
    [ "-Wint-conversion",  "-Wshorten-64-to-32", "-Wconstant-conversion", "-Wconversion", "-Woverloaded-virtual", "-Wshadow", "-Wsign-conversion" ].each do |flag|
      r.delete flag
    end
    split_and_concat_uniq r, sep
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
    attribute("packages", exporter).each do |e,p|
      f.push_unique "$(shell $(CROSS_COMPILE)pkg-config --libs #{p})"
    end
    f.join(" ")
  end
  
  """ Returns link flags for all the exporters which match the given expression """
  def defines(configuration = "*", exporter = "*", sep = " ", prefix = "-D")
    r = []
    if header.has_key? :defines then
        r = header[:defines].split(/[ \n]+/)
    end
    r += configuration_attribute("defines", exporter).select { |k,v| 
      configuration == "*" or k.match(configuration) or k == configuration
    }.values
    r += options
    r.delete("")
    clean_list(r).map { |v| prefix + v.gsub(/\"/, '\\\"').gsub(/^([^=]*)=(.+)/, '\\1="\\2"') }.join(sep)
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

  def header
    r = Hash.new
    file.elements.to_a("/JUCERPROJECT")[0].attributes.to_a.each do |a|
      name = a.name.to_sym
      r[name] = a.value
    end
    r
  end

  def options
    r = Array.new
    file.elements.to_a("/JUCERPROJECT/JUCEOPTIONS)")[0].attributes.to_a.map do |a|
      opt = a.name
      opt += "="
      opt += (a.value=="disabled") ? "0" : "1"
      r.push_unique opt
    end
    r
  end
  private
      """ Returns link flags for all the exporters which match the given expression """

  def linker(exporter = "*", sep = " ")
    f = Array.new
    configuration_attribute("libraryPath", exporter).values.each do |libpath|
      libpath.split(/\n/).each do |p|
        p.gsub!('\\', '/')
        p.strip!
        p.gsub!(/\/*$/, "")
        if p.match(/^\$[\({].*[\)}]$/) then next end
        if p.match('[^-.A-Za-z0-9\\\\_/\${}\(\)]') then 
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
  public

  def modulepaths(exporter = "*")
    r = Hash.new
    export_formats(exporter).each do |f|
      REXML::XPath.each(f, "//MODULEPATH") do |m|
        id = m.attributes["id"]
        path = m.attributes["path"]
        if id.size > 0 and path.size > 0 then
          r[id] = path
        end
      end
    end
    r
  end

  def modules
    r = Array.new
    REXML::XPath.each(@file, "/JUCERPROJECT/MODULES/MODULES") do |e|
      r.push e.attributes["id"]
    end
    r
  end
end
