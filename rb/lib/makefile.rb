require_relative 'buildfile.rb'

""" MakeFile --------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """
class MakeFile < BuildFile

  attr_accessor :variables, :targets

  class MakeFileTarget
    attr_accessor :name, :deps, :body
    def initialize(name, body = "", deps = "")
      @name = name
      @body = body
      if deps.instance_of? Array then
        deps = deps.join(" ")
      end
      @deps = deps
    end
    def write(o=$stdout)
      target = "\n"
      target += @name + ":";
      if deps.size > 0 then
        target +=  " " + deps;
      end
      if body.size > 0 then
        target += "\n\t"+body.gsub("\n", "\n\t")+"\n"
      end
      target += "\n"
      o.puts target
    end
  end

  def self.clone(other)
    #if not other.instance_of? BuildFile then raise "other not an instance of <BuildFile>"  end
    compile_flags = other.compile_flags.split(/\s+/).reject{ |f| f.match /^\// }.uniq
    link_flags = other.link_flags.split(/\s+/)

    link_flags.push_unique "-static-libgcc", "-static-libstdc++"

    r = MakeFile.new(other.project_type, other.sources, other.targets, compile_flags.join(" "), link_flags.join(" "), other.libs)
    r.defines = other.defines;
    r.configurations = other.configurations;
    r.update_properties
    r.targets = [ 
      MakeFileTarget.new("all", "", r.targets),
      MakeFileTarget.new(".c.o", "$(CC) $(DEFINES) $(CFLAGS) -c $<"),
    ]   

    r.sources.keys.each do |t|
      ccvar = r.sources[t].any? { |s| s.match /\.c[xp][xp]$/ } ? "CXX" : "CC"
      r.targets.push MakeFileTarget.new(t, "$(#{ccvar}) $(LDFLAGS) $(CFLAGS) -o $@ $^ $(LIBS)", "$("+t.canonicalize+"_OBJECTS)")
    end

    return r
  end

  def write(o=$stdout)
    @variables.each do |n,v|
      o.puts "#{n} = #{v}"
    end
    @targets.each do |t|
      t.write o
    end
  end

  def update_properties
    add_property :@variables, { 
       "CC" => "gcc",
       "CXX" => "g++",
       "CFLAGS" => @compile_flags,
       "CXXFLAGS" => "$(CFLAGS)",
       "LDFLAGS" => @link_flags,
       "LIBS" => @libs,
       "DEFINES" => @defines,
    }
    @sources.keys.each do |t|
      #@variables[t.canonicalize+"_SOURCES"] = @sources[t].join(" ");
      @variables[t.canonicalize+"_OBJECTS"] = @sources[t].map { |s| s.gsub(/\.[^.]*$/, ".o") }.join(" ");
    end
  end
end
