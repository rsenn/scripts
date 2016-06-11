
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
    r = attribute("extraCompilerFlags", exporter).values
    r += modulepaths.values.uniq.map { |p| "-I#{p}" }

    r.push_unique "-I."
  r.push_unique "-I JuceLibraryCode"
    
    attribute("packages", exporter).each do |e,p|
      r.push_unique "$(shell $(CROSS_COMPILE)pkg-config --cflags #{p})"
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
    r = header[:defines].split(/[ \n]+/)

    r += configuration_attribute("defines", exporter).select { |k,v| 
      configuration == "*" or k.match(configuration) or k == configuration
    }.values

    r += options

    clean_list(r).map { |v| prefix + v.gsub(/\"/, '\\"').gsub(/^([^=]*)=(.+)/, '\\1="\\2"') }.join(sep)
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
#        p.gsub!(/^\${([^}]*)}/, "$(\\1)")
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
