require_relative 'buildfile.rb'

""" CMakeLists --------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """
class CMakeLists < BuildFile

  attr_accessor :variables, :targets

  class CMakeListsTarget
    attr_accessor :deps, :body

    def initialize(body = "", deps = "")
    end
  end

  def self.clone(other)
    #if not other.instance_of? BuildFile then raise "other not an instance of <BuildFile>"  end
    compile_flags = other.compile_flags.split(/\s+/).reject{ |f| f.match /^\// }.uniq
    link_flags = other.link_flags.split(/\s+/)

    link_flags.push_unique "-static-libgcc", "-static-libstdc++"

    r = CMakeLists.new(other.project_type, other.sources, other.targets, compile_flags.join(" "), link_flags.join(" "), other.libs)
    r.defines = other.defines;
    r.configurations = other.configurations;
    r.update_properties

    r.targets = {
      "all"       => CMakeListsTarget.new("", [ "$(OBJDIR)" ]),
      "$(OBJDIR)" => CMakeListsTarget.new("mkdir -p $@"),
      # ".c.o"      => CMakeListsTarget.new("$(CC) $(DEFS) $(CFLAGS) -c -o $@ $<"),
      # ".cpp.o"    => CMakeListsTarget.new("$(CXX) $(DEFS) $(CXXFLAGS) -c -o $@ $<"),
      #{}"$(OUTDIR)/$(TARGET)" => CMakeListsTarget
    }

    r.sources.keys.each do |t|
      if r.project_type.to_sym == :library then
		    outdir = "$(LIBDIR)"
        target = "#{outdir}/lib#{t}.a"
      else
	      outdir = "$(BINDIR)"
        target = "#{outdir}/#{t}"
      end
      srcs = r.sources[t]
      objs = srcs.map { |src| 
        src = src.gsub(/(.*)\.[^.]*$/, "$(OBJDIR)/\\1.o") 
      }
      $stderr.puts "objs = #{objs}"
      #pp objs
      ccvar = srcs.any? { |s| s.match /\.c[xp][xp]$/ } ? "CXX" : "CC"
      r.targets[target.escape] = CMakeListsTarget.new("$(#{ccvar}) $(LDFLAGS) $(CFLAGS) -o $@ $^ $(LIBS)", objs)
      r.targets["all"].deps.push_unique target
    end

    return r
  end

  def write(o=$stdout)
  end

  def update_properties
  end
end
