require_relative 'buildfile.rb'

""" MakeFile --------------------------------------------------------------- """
""" ------------------------------------------------------------------------ """
class MakeFile < BuildFile

  attr_accessor :variables, :targets

  class MakeFileTarget
    attr_accessor :deps, :body

    def initialize(body = "", deps = "")
     #     @name = name
      @body = body
      if not deps.instance_of? Array then
        deps = deps.split(/\s+/)
      end
      @deps = deps
    end
    def write(o=$stdout, name=nil)
      target = ""
      if name.instance_of? String then target += name end;
      target += ":"
      if deps.size > 0 then
        target +=  " " + deps.join(" ");
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

    r.targets = {
      "all"       => MakeFileTarget.new("", [ "$(OBJDIR)" ]),
      "$(OBJDIR)" => MakeFileTarget.new("mkdir -p $@"),
      # ".c.o"      => MakeFileTarget.new("$(CC) $(DEFS) $(CFLAGS) -c -o $@ $<"),
      # ".cpp.o"    => MakeFileTarget.new("$(CXX) $(DEFS) $(CXXFLAGS) -c -o $@ $<"),
      #{}"$(OUTDIR)/$(TARGET)" => MakeFileTarget
    }

    r.sources.keys.each do |t|
      if r.project_type.to_sym == :library then
        target = "lib#{t}.a"
      else
        target = t
      end
      srcs = r.sources[t]
      ccvar = srcs.any? { |s| s.match /\.c[xp][xp]$/ } ? "CXX" : "CC"
      r.targets["$(OUTDIR)/"+target] = MakeFileTarget.new("$(#{ccvar}) $(LDFLAGS) $(CFLAGS) -o $@ $^ $(LIBS)", srcs.map { |src| src.gsub(/.*\/([^\/]+)\.[^.]*$/, "$(OBJDIR)/\\1.o") })
      r.targets["all"].deps.push_unique "$(OUTDIR)/"+target
    end

    return r
  end

  def write(o=$stdout)
    o.puts "# (this disables dependency generation if multiple architectures are set)
DEPFLAGS := $(if $(word 2, $(TARGET_ARCH)), , -MMD)

ifndef CONFIG
  CONFIG=Debug
endif\n\n"

    @variables.each do |n,v|
      o.puts "#{n} = #{v}"
    end
    o.puts "\n"

o.puts "SYSTEM := $(word 2,$(subst -, ,$(CHOST)))
ifeq ($(SYSTEM),w64)
  SYSTEM := $(word 3,$(subst -, ,$(CHOST)))
endif
ifeq ($(SYSTEM),pc)
  SYSTEM := $(word 3,$(subst -, ,$(CHOST)))
endif\n\n"

    o.puts "$(info CHOST: $(CHOST))\n"
    o.puts "$(info SYSTEM: $(SYSTEM))\n"

    o.puts "ifeq ($(CONFIG),Debug)
  OUTDIR := $(CHOST)
  BINDIR := $(OUTDIR)
  LIBDIR := $(OUTDIR)
  OBJDIR := $(OUTDIR)/intermediate/Debug
  DEFS += -DDEBUG=1 -D_DEBUG=1 -UNDEBUG
  CFLAGS += -g -ggdb -O0
endif\n\n"

    o.puts "ifeq ($(CONFIG),Release)
  OUTDIR := $(CHOST)
  BINDIR := $(OUTDIR)
  LIBDIR := $(OUTDIR)
  OBJDIR := $(OUTDIR)/intermediate/Release
  DEFS += -UDEBUG -DNDEBUG=1
  CFLAGS += -g -Wall -O3
endif\n\n"

    o.puts "ifeq ($(SYSTEM),mingw32)
  DEFS += __MINGW__=1 JUCE_MINGW=1  
  LIBS +=  -lcomdlg32 -lgdi32 -lgdiplus -limm32 -lole32 -loleaut32 -lshell32 -lshlwapi -luuid -lversion -lwininet -lwinmm -lws2_32 -lwsock32 -lopengl32
endif\n\n"

    o.puts "ifeq ($(SYSTEM),linux)
  DEFS += -DLINUX=1
endif\n\n"

#  @variables["VPATH"]  = "$(OBJDIR)"
#    @targets["$(OBJDIR)/%.o"] = MakeFileTarget.new("$(CXX) $(DEFS) $(CXXFLAGS) -c -o $@ $<", "%/%.cpp")

    @sources.each do |name,s|
      deps = Array.new
      s.each do |src|
        obj = src.gsub(/.*\/([^\/]+)\.[^.]*$/, "$(OBJDIR)/\\1.o")
        deps.push_unique obj;
        @targets[obj] = MakeFileTarget.new("$(CXX) $(DEFS) $(CXXFLAGS) -c -o $@ $<", src)
#        @targets[obj] = MakeFileTarget.new( "", src)
      end

      o.puts "#{name.canonicalize}_OBJECTS = "+deps.join(" ")
    end

    o.puts "\n"

    @targets.each do |name,t|
      t.write(o, name)
    end
  end

  def update_properties
    add_property :@variables, { 
       "CC" => "gcc",
       "CXX" => "g++",
       "CHOST" => "$(shell $(CROSS_COMPILE)$(CC) -dumpmachine)",
       "CFLAGS" => @compile_flags,
       "CXXFLAGS" => "$(CFLAGS)",
       "LDFLAGS" => @link_flags,
       "LIBS" => @libs,
       "DEFS" => @defines,
    }
#    @sources.keys.each do |t|
#      @variables[t.canonicalize+"_OBJECTS"] = @sources[t].map { |s| s.gsub(/.*\/([^\/]+)\.[^.]*$/, "$(OBJDIR)/\\1.o") }.join(" ");
#    end
  end
end
