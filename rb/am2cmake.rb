#!/usr/bin/env ruby


NoTarget   = 0
Executable = 1
StaticLib  = 2
SharedLib  = 3
Part       = 4
KDEInit    = 5

BuildNoKDE=0
BuildKDE3=1
BuildKDE4=2

$withConv=false


$buildType=BuildKDE4

$allTargets=Array.new

LibMappingKDE3 = {
   "$(LIB_QT3SUPPORT)"  => "${QT_QT3SUPPORT_LIBRARY}",
   "$(DCOP_LIB)"        => "DCOP",
   "$(LIB_KDEUI)"       => "kdeui",
   "$(LIB_KIO)"         => "kio",
   "$(LIB_KDEPRINT)"    => "kdeprint",
   "$(LIB_KPARTS)"      => "kparts",
   "$(LIB_KSPELL2)"     => "kspell2",
   "$(LIB_KDE3SUPPORT)" => "kde3support",
   "$(LIB_KJS)"         => "kjs",
   "$(LIB_KHTML)"       => "khtml",
   "$(LIB_KNEWSTUFF)"   => "knewstuff",
   "$(LIB_KDEPIM)"      => "kdepim",
   "$(LIB_KDNSSD)"      => "kdnssd",
   "$(LIB_KIMPROXY)"    => "kimproxy",
   "$(LIB_KUTILS)"      => "kutils",
   "$(LIB_KSYCOCA)"     => "kio"
}

LibMappingKDE4 = {
   "$(LIB_QT3SUPPORT)"  => "${QT_QT3SUPPORT_LIBRARY}",
   "$(LIB_KDEUI)"       => "${KDE4_KDEUI_LIBS}",
   "$(LIB_KIO)"         => "${KDE4_KIO_LIBS}",
   "$(LIB_KDEPRINT)"    => "kdeprint",
   "$(LIB_KPARTS)"      => "${KDE4_KPARTS_LIBS}",
   "$(LIB_KSPELL2)"     => "${KDE4_KSPELL2_LIBS}",
   "$(LIB_KDE3SUPPORT)" => "${KDE4_KDE3SUPPORT_LIBS}",
   "$(LIB_KJS)"         => "${KDE4_KJS_LIBS}",
   "$(LIB_KHTML)"       => "${KDE4_KHTML_LIBS}",
   "$(LIB_KNEWSTUFF)"   => "knewstuff",
   "$(LIB_KDNSSD)"      => "${KDE4_KDNSSD_LIBS}",
   "$(LIB_KDEPIM)"      => "kdepim",
   "$(LIB_KIMPROXY)"    => "kimproxy",
   "$(LIB_KUTILS)"      => "${KDE4_KUTILS_LIBS}",
   "$(LIB_KSYCOCA)"     => "${KDE4_KIO_LIBS}",
   "$(LIB_KOFFICEUI)"    => "kofficeui",
   "$(LIB_KOFFICECORE)"    => "kofficecore",
   "$(LIB_KSTORE)"        => "kstore",
   "$(LIB_KOTEXT)"        => "kotext",
   "$(LIB_KOPAINTER)"    => "kopainter",
   "$(LIB_KOPALETTE)"    => "kopalette",
   "$(LIB_KWMF)"        => "kwmf",
   "$(LIB_KOWMF)"        => "kowmf",
   "$(LIB_KFORMULA)"    => "kformulalib",
   "$(LIB_KOPROPERTY)"    => "koproperty",
   "$(LIB_KROSS_API)"    => "krossapi",
   "$(LIB_KROSS_MAIN)"    => "krossmain"
}

$libMapping=LibMappingKDE3

InstallDirsKDE3 = {
   "kde_apps"     => "share/applnk",
   "kde_conf"     => "share/config",
   "kde_data"     => "share/apps",
   "kde_html"     => "share/doc/HTML",
   "kde_icon"     => "share/icons",
   "kde_kcfg"     => "share/config.kcfg",
   "kde_libs_html"=> "share/doc/HTML",
   "kde_locale"   => "share/locale",
   "kde_mime"     => "share/mimelink",
   "kde_services" => "share/services",
   "kde_servicetypes" => "share/servicetypes",
   "kde_sound"    => "share/sounds",
   "kde_templates"=> "share/templates",
   "kde_wallpaper"=> "share/wallpapers",
   "xdg_apps"     => "share/applications/kde",
   "xdg_directory"=> "share/desktop-directories",
   "data"         => "share",
   "include"      => "include"
}

InstallDirsKDE4 = {
   "kde_apps"     => "${APPLNK_INSTALL_DIR}",
   "kde_conf"     => "${CONFIG_INSTALL_DIR}",
   "kde_data"     => "${DATA_INSTALL_DIR}",
   "kde_html"     => "${HTML_INSTALL_DIR}",
   "kde_icon"     => "${KDE4_ICON_DIR}",
   "kde_kcfg"     => "${KCFG_INSTALL_DIR}",
   "kde_libs_html"=> "${LIBS_HTML_INSTALL_DIR}",
   "kde_locale"   => "${LOCALE_INSTALL_DIR}",
   "kde_mime"     => "${MIME_INSTALL_DIR}",
   "kde_services" => "${SERVICES_INSTALL_DIR}",
   "kde_servicetypes" => "${SERVICETYPES_INSTALL_DIR}",
   "kde_sound"    => "${SOUND_INSTALL_DIR}",
   "kde_templates"=> "${TEMPLATES_INSTALL_DIR}",
   "kde_wallpaper"=> "${WALLPAPER_INSTALL_DIR}",
   "xdg_apps"     => "${XDG_APPS_INSTALL_DIR}",
   "xdg_directory"=> "${XDG_DIRECTORY_INSTALL_DIR}",
   "data"         => "${DATA_INSTALL_DIR}",
   "include"      => "${INCLUDE_INSTALL_DIR}"
}

$installDirs=InstallDirsKDE3

class InstallTarget
   def initialize
      @files=""
      @location=""
   end
   def addFiles(files)
      @files=@files+" "+files
   end
   def setLocation(location)
      @location=location
   end
   attr_reader :location, :files
end

class BuildTarget
   def initialize(name, type, withStdPrefix=true, install=true, test=false)
      @name=name
      @type=type
      @sources=Array.new
      @ui3s=Array.new # for ui3 files in a kde4 build
      @uis=Array.new
      @skels=Array.new
      @stubs=Array.new
      @kcfgs=Array.new
      @qrcs=Array.new
      @am=Array.new
      @stdPrefix=withStdPrefix
      @install=install
      @test=test
      @libs=Array.new
      @versionNumberMajor=1
      @versionNumberMinor=0
      @versionNumberPatch=0

      if $buildType==BuildKDE4
         @libs.push("${KDE4_KDECORE_LIBS}")
      elsif $buildType==BuildKDE3
         @libs.push("${QT_AND_KDECORE_LIBS}")
      end
      $allTargets.push(self)
   end

   def addSourceFiles(files)
      files.split.each do |currentSource|
         if currentSource =~ /^\S+\.ui$/
            @uis.push(currentSource)
         elsif currentSource =~ /^(\S+)\.ui4$/
            @uis.push(currentSource)
         elsif currentSource =~ /^(\S+)\.ui3$/  #Qt3 ui file in a KDE 4 build
            @ui3s.push(currentSource)
         elsif currentSource =~ /^(\S+)\.skel$/
            @skels.push($1+".h")
         elsif currentSource =~ /^(\S+)\.stub$/
            @stubs.push($1+".h")
         elsif currentSource =~ /^(\S+)\.kcfgc$/
            @kcfgs.push(currentSource)
         elsif currentSource =~ /^(\S+)\.qrc$/
            @qrcs.push(currentSource)
         else
            @sources.push(currentSource)
         end
      end
   end

   def addLibs(libs)
      lib=""
      previousWasVersionInfo=false
      libs.split.each do |currentLib|
         if $libMapping.has_key?(currentLib)
            lib=$libMapping[currentLib]
         else
            if currentLib =~ /^-l(\S+)$/
               lib=$1
            elsif currentLib =~ /^(.+\/)?lib(\w+)\.la$/
               lib=$2
            elsif currentLib =~ /^(.+\/)?lib(\w+)\.a$/
               lib=$2
            else
               lib=""
            end
         end

         if !lib.empty?
            @libs.push(lib)
         end

         #handle libtool version info, not sure it is correct
         if previousWasVersionInfo
            if currentLib =~ /^(\d+):(\d+):(\d+)$/
               @versionNumberMajor=$1.to_i-$3.to_i
               @versionNumberMinor=$3.to_i
               @versionNumberPatch=$2.to_i
            elsif previousWasVersionInfo && currentLib =~ /^(\d+):(\d+)$/
               @versionNumberMajor=$1.to_i
               @versionNumberMinor=$2.to_i
               @versionNumberPatch=0
            end
         end
         previousWasVersionInfo= (currentLib == "-version-info")

      end

   end


   attr_reader :name, :type, :sources, :uis, :ui3s, :skels, :stdPrefix, :stubs, :kcfgs, :install, :test, :libs, :qrcs
   attr_reader :versionNumberMajor, :versionNumberMinor, :versionNumberPatch

end

class CMakeFile
   def initialize(amFile)
      printf("converting #{amFile}\n")
      @amFile=amFile
      amFile =~ /(.*)Makefile.am/
      @path=$1
      @listsFile=@path+"CMakeLists.txt"
      @iconDir="hicolor"
      @installIcons=false
      @installDoc=false

      @createDoxygenDocs=false
      @doxygenRecursive=false
      @doxygenInternalDocs=false
      @doxygenReferences=Array.new
      @doxygenExcludes=Array.new

      @targets=Array.new
      @installs=Hash.new

      @includeDirs=Array.new
      @subDirs=Array.new
      @skippedSubDirs=Array.new

      @configHeaders=Array.new
      $configHeaders.each do  |header|
         @configHeaders.push($1) if header=~ Regexp.new("^"+@path+"([^\\/]+\\.h)\\.in")
      end

      parseFile

      if $buildType==BuildKDE3
          @includeDirs.push("${CMAKE_CURRENT_SOURCE_DIR}")
          @includeDirs.push("${CMAKE_CURRENT_BINARY_DIR}")
          @includeDirs.push("${KDE3_INCLUDE_DIR}")
          @includeDirs.push("${QT_INCLUDE_DIR}")
      elsif $buildType==BuildKDE4
          @includeDirs.push("${KDE4_INCLUDES}")
          @includeDirs.push("${KDE4_INCLUDE_DIR}")
          @includeDirs.push("${QT_INCLUDES}")
      end
   end

   def parseFile
      @lines=IO.readlines(@amFile)
      cummLine=""
      appendNextLine=false
      for line in @lines do
         if line.include?("#")
            line=line[0, line.index("#")]
         end
         if line.length<2
            next
         end

         appendNextLine=(line[line.length-2, 1]=='\\')

         if appendNextLine
            cummLine+=" "+line[0, line.length-2]
         else
            cummLine+=" "+line.chomp #[0, line.length-1]
            if not cummLine.empty?
               parseLine(cummLine)
               cummLine=""
            end
         end
      end
   end

   def findTarget(line)
      type=SharedLib
      if line =~ /^\s*lib(\S+)_la_\S+\s*=\s*\S+.*$/
         targetName=$1
#         type=SharedLib
      elsif line =~ /^\s*(\S+)_la_\S+\s*=\s*\S+.*$/
         targetName=$1
#         type=Executable
      elsif line =~ /^\s*lib(\S+)_a_\S+\s*=\s*\S+.*$/
         targetName=$1
#         type=StaticLib
      elsif line =~ /^\s*(\S+)_\S+\s*=\s*\S+.*$/
         targetName=$1
#         type=Executable
      end
      
      @targets.each do |buildTarget|
         amBuildTargetName=buildTarget.name.gsub(/\./, "_")
#         printf("- %s [%s]\n", amBuildTargetName, targetName)
         if (amBuildTargetName==targetName)
            return buildTarget
         end
      end

      return BuildTarget.new("Dummy", NoTarget)
   end

   def addTarget(line)
      type=NoTarget
      targets=""
      installTarget=true
      testTarget=false

      if line =~ /^\s*lib_LTLIBRARIES\s*=\s*(\S+.*)/
         targets=$1
         type=SharedLib
#         printf("shared: %s\n", $1)
      elsif line =~ /^\s*noinst_LTLIBRARIES\s*=\s*(\S+.*)/
         targets=$1
         type=StaticLib
#         printf("static: %s\n", $1)
      elsif line =~ /^\s*noinst_LIBRARIES\s*=\s*(\S+.*)/
         targets=$1
         type=StaticLib
#         printf("static: %s\n", $1)
      elsif line =~ /^\s*kde_module_LTLIBRARIES\s*=\s*(\S+.*)/
#         printf("part: %s\n", $1)
         targets=$1
         type=Part
      elsif line =~ /^\s*kde_style_LTLIBRARIES\s*=\s*(\S+.*)/
#         printf("style: %s\n", $1)
         targets=$1
         type=Part
      elsif line =~ /^\s*kde_widget_LTLIBRARIES\s*=\s*(\S+.*)/
#         printf("style: %s\n", $1)
         targets=$1
         type=Part
      elsif line =~ /^\s*kdeinit_LTLIBRARIES\s*=\s*(\S+.*)/
#         printf("kdeinitpart: %s\n", $1)
         targets=$1
         type=KDEInit
      elsif line =~ /^\s*bin_PROGRAMS\s*=\s*(\S+.*)$/
         targets=$1
#         printf("exec: %s\n", $1)
         type=Executable
      elsif line =~ /^\s*noinst_PROGRAMS\s*=\s*(\S+.*)$/
         targets=$1
         installTarget=false
#         printf("exec: %s\n", $1)
         type=Executable
      elsif line =~ /^\s*check_PROGRAMS\s*=\s*(\S+.*)$/
         targets=$1
         installTarget=false
         testTarget=true

#         printf("exec: %s\n", $1)
         type=Executable
      elsif line =~ /^\s*EXTRA_PROGRAMS\s*=\s*(\S+.*)$/
         targets=$1
         installTarget=false
         testTarget=true
#         printf("exec: %s\n", $1)
         type=Executable
      else
         return false
      end

      if type==Executable
         targets.split.each{ |current| @targets.push(BuildTarget.new(current, type, true, installTarget, testTarget)) }
      else
         targets.split.each do |current|
            if current =~ /lib(\S+)\.la/
#                printf("adding target with \"lib\": -%s-\n", $1)
               @targets.push(BuildTarget.new($1, type))
             elsif current =~ /\s*(\S+)\.la/
#                    printf("adding target without \"lib\": -%s-\n", $1)
                  @targets.push(BuildTarget.new($1, type, false))
             elsif current =~ /lib(\S+)\.a/
                @targets.push(BuildTarget.new($1, type))
             elsif current =~ /\s*(\S+)\.a/
                @targets.push(BuildTarget.new($1, type, false))
             end
         end
      end
      return true
   end

   def addSourcesToTarget(line)
#      printf("sources: %s\n", line)
      buildTarget=findTarget(line)
      if buildTarget.type==NoTarget
         $stderr.printf("%s PROBLEM: target not found: %s\n", @amFile, line)
         return
      end

      if line =~ /^\s*(lib)?\S+(_la)?_SOURCES\s*=\s*(\S+.*)$/
        buildTarget.addSourceFiles($3)
      elsif line =~ /^\s*(lib)?\S+(_a)?_SOURCES\s*=\s*(\S+.*)$/
        buildTarget.addSourceFiles($3)
      end
   end

   def addIncludeDirectories(includeDirs)
      includeDirs.split.each do |dir|
         if dir =~ /^\s*-I\$\(top_srcdir\)(\S+)/
            @includeDirs.push("${CMAKE_SOURCE_DIR}"+$1)
         end
      end
   end

   def addInstallFiles(key, files)
      if @installs.has_key?(key)
         inst=@installs[key]
      else
         inst=InstallTarget.new
      end
      inst.addFiles(files)
      if $installDirs.has_key?(key)
         inst.setLocation($installDirs[key])
      end
      @installs[key]=inst
   end

   def addInstallLocation(key, location)
#      printf("adding loc: %s \n", location)
      if @installs.has_key?(key)
         inst=@installs[key]
      else
         inst=InstallTarget.new
      end

      if location =~ /\$\((\S+)dir\)(\/?\S*)/
         baseDir=$1
         subDir=$2
         if $installDirs.has_key?(baseDir)
            inst.setLocation($installDirs[baseDir]+subDir)
            @installs[key]=inst
         end
         if baseDir=="kde_icon"
            @iconDir=key
         end
      end
   end

   def parseDoxygenSettings(line)
      if line.include?("Doxyfile.am")
         @createDoxygenDocs=true
      elsif line =~ /^\s*DOXYGEN_SET_INTERNAL_DOCS\s*=\sYES.*/
         @doxygenInternalDocs = true
      elsif line =~ /^\s*DOXYGEN_SET_RECURSIVE\s*=\sYES.*/
         @doxygenRecursive = true
      elsif line =~ /^\s*DOXYGEN_REFERENCES\s*=\s*(\S+.*)$/
         ($1).split.each { |ref| @doxygenReferences.push(ref) }
      elsif line =~ /^\s*DOXYGEN_EXCLUDE\s*=\s*(\S+.*)$/
         ($1).split.each { |exclude| @doxygenExcludes.push(exclude) }
      end
   end

   def parseLine(line)
      if line =~ /^\s*METASOURCES\s*=\s*AUTO\s*$/
         @automoc=true
         return
      end

      if addTarget(line)
         return
      end


      if line.include?("Doxyfile.am") || line.include?("DOXYGEN")
         parseDoxygenSettings(line)
      end

      if line =~ /^\s*KDE_ICON\s*=/
         @installIcons=true
         return
      end

      if line =~ /^\s*KDE_DOCS\s*=/
     @installDoc=true
     return
      end

      if (line =~ /^\s*\S+_SOURCES\s*=/)
         addSourcesToTarget(line)
         return
      end

      if (line =~ /^\s*(\S+)_LDFLAGS\s*=\s*(\S+.*)$/) ||
         (line =~ /^\s*(\S+)_LIBADD\s*=\s*(\S+.*)$/) ||
         (line =~ /^\s*(\S+)_LDADD\s*=\s*(\S+.*)$/)

         if $1 != "AM"
            buildTarget=findTarget(line)
            if buildTarget.type==NoTarget
               $stderr.printf("%s PROBLEM: target %s not found: %s\n", @amFile, $1, line)
               return
            end

#            $stderr.printf("target: #{buildTarget.name} lib: #{$2} line: #{line} d1: #{$1}\n")
            buildTarget.addLibs($2)
         end
         return
      end
      
      if (line =~ /^\s*INCLUDES\s*=\s*(\S+.*)$/)
         addIncludeDirectories($1)
         return
      end

      if line =~ /^\s*(\S+)dir\s*=\s*(\S+.*)$/
         addInstallLocation($1, $2)
         return
      end
      if line =~ /^\s*(\S+)_DATA\s*=\s*(\S+.*)$/
         addInstallFiles($1, $2)
         return
      end
      if line =~ /^\s*(\S+)_SCRIPTS\s*=\s*(\S+.*)$/
         addInstallFiles($1, $2)
         return
      end
      if line =~ /^\s*(\w*include)_HEADERS\s*=\s*(\S+.*)$/
         addInstallFiles($1, $2)
         return
      end

      if line =~ /^\s*SUBDIRS\s*=\s*(\S+.*)$/ || line =~ /^\s*COMPILE_FIRST\s*=\s*(\S+.*)$/
         ($1).split.each do |dir|
            if dir =~ /\$\(.+\)/
               @skippedSubDirs.push(dir)
            else
               @subDirs.push(dir) if dir!="."
            end
         end
      end
   end
   

   def createKDE3ListsFile

      file=File.new(@listsFile, "w+");
      if @amFile=="Makefile.am" && $buildType == BuildKDE3   # the toplevel Makefile.am
          file.printf("find_package(KDE3 REQUIRED)\n\n")
          file.printf("set(CMAKE_VERBOSE_MAKEFILE ON)\n\n")
          file.printf("add_definitions(${QT_DEFINITIONS} ${KDE3_DEFINITIONS})\n\n")
          file.printf("link_directories(${KDE3_LIB_DIR})\n\n")

      end

      if !@configHeaders.empty?
         @configHeaders.each{ |header| file.printf("configure_file(${CMAKE_CURRENT_SOURCE_DIR}/#{header}.cmake ${CMAKE_CURRENT_BINARY_DIR}/#{header})\n\n") }
      end

      if not @subDirs.empty?
         @subDirs.each{ |dir| file.printf("add_subdirectory(%s)\n", dir)}
         file.printf("\n")
      end
      if not @skippedSubDirs.empty?
         @skippedSubDirs.each{ |dir| file.printf("message(STATUS \"${CMAKE_CURRENT_SOURCE_DIR}: skipped subdir %s\")\n", dir)}
      end


      if not @includeDirs.empty?
         file.printf("include_directories(")
         @includeDirs.each{ |dir| file.printf("%s ", dir) }
         file.printf(")\n\n")
      end
      @targets.each do |buildTarget|
         file.printf("\n########### next target ###############\n\n")
#         printf("target name: %s\n", buildTarget.name)

         if buildTarget.type==SharedLib
            srcsName=buildTarget.name+"_LIB_SRCS"
         elsif buildTarget.type==StaticLib
            srcsName=buildTarget.name+"_STAT_SRCS"
         elsif buildTarget.type==Part
            srcsName=buildTarget.name+"_PART_SRCS"
         elsif buildTarget.type==KDEInit
            srcsName=buildTarget.name+"_KDEINIT_SRCS"
         else
            srcsName=buildTarget.name+"_SRCS"
         end
         uisName=buildTarget.name+"_UI"
         skelsName=buildTarget.name+"_DCOP_SKEL_SRCS"
         stubsName=buildTarget.name+"_DCOP_STUB_SRCS"
         kcfgsName=buildTarget.name+"_KCFG_SRCS"

         if buildTarget.sources.empty?
            buildTarget.sources.push("dummy.cpp")
         end

         if not buildTarget.sources.empty?
            file.printf("SET(%s\n", srcsName)
            needToCreateDummyFile=false
            buildTarget.sources.each do |currentFile|
               file.printf("   %s\n", currentFile)
               if currentFile=="dummy.cpp"

                  needToCreateDummyFile=true if not FileTest.exists?(@path+"/dummy.cpp")
               end
            end
            file.printf(")\n\n")
            
            if $buildType == BuildKDE3
               file.printf("kde3_automoc(${%s})\n\n", srcsName)
            end

            if needToCreateDummyFile
#                  printf("creating dummy file in #{@path} ________\n")
               file.printf("file(WRITE dummy.cpp \"//autogenerated file by cmake\\n\")\n")
            end
         end

         if not buildTarget.uis.empty?
            file.printf("set(%s\n", uisName)
            buildTarget.uis.each{ |currentFile| file.printf("    %s\n", currentFile)}
            file.printf(")\n\n")
            file.printf("kde3_add_ui_files(%s ${%s})\n\n", srcsName, uisName)
         end

         if not buildTarget.skels.empty?
            file.printf("set(%s\n", skelsName)
            buildTarget.skels.each{ |currentFile| file.printf("    %s\n", currentFile)}
            file.printf(")\n\n")

            file.printf("kde3_add_dcop_skels(%s ${%s})\n\n", srcsName, skelsName)
         end

         if not buildTarget.stubs.empty?
            file.printf("set(%s\n", stubsName)
            buildTarget.stubs.each{ |currentFile| file.printf("    %s\n", currentFile)}
            file.printf(")\n\n")

            file.printf("kde3_add_dcop_stubs(%s ${%s})\n\n", srcsName, stubsName)
         end

         if not buildTarget.kcfgs.empty?
            file.printf("set(%s\n", kcfgsName)
            buildTarget.kcfgs.each{ |currentFile| file.printf("    %s\n", currentFile)}
            file.printf(")\n\n")

            file.printf("kde3_add_kcfg_files(%s ${%s})\n\n", srcsName, kcfgsName)
         end

         if buildTarget.type==SharedLib
            file.printf("add_library(%s SHARED ${%s})\n\n", buildTarget.name, srcsName)
            file.printf("target_link_libraries(%s", buildTarget.name)
            buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
            file.printf(")\n\n")

            file.printf("set_target_properties(%s PROPERTIES VERSION 4.2.0 SOVERSION 4)\n", buildTarget.name)
            file.printf("install(TARGETS %s DESTINATION lib)\n\n", buildTarget.name)
         elsif buildTarget.type==StaticLib
            file.printf("add_library(%s STATIC ${%s})\n\n", buildTarget.name, srcsName)
         elsif buildTarget.type==Part
            if buildTarget.stdPrefix
               file.printf("kde3_add_kpart(%s WITH_PREFIX ${%s})\n\n", buildTarget.name, srcsName)
            else
               file.printf("kde3_add_kpart(%s ${%s})\n\n", buildTarget.name, srcsName)
            end
            file.printf("target_link_libraries(%s", buildTarget.name)
            buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
            file.printf(")\n\n")

            file.printf("install(TARGETS %s DESTINATION lib/kde3)\n\n", buildTarget.name)
         elsif buildTarget.type==KDEInit
            file.printf("kde3_add_kdeinit_executable(%s ${%s})\n\n", buildTarget.name, srcsName)

            file.printf("target_link_libraries(kdeinit_%s", buildTarget.name)
            buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
            file.printf(")\n\n")

            file.printf("install(TARGETS kdeinit_%s DESTINATION lib)\n\n", buildTarget.name)

            file.printf("target_link_libraries(%s kdeinit_%s)\n", buildTarget.name, buildTarget.name)

            file.printf("install(TARGETS %s DESTINATION bin)\n", buildTarget.name)

         else  #executable
            if $buildType == BuildNoKDE

               file.printf("add_executable(%s ${%s})\n\n", buildTarget.name, srcsName)

               file.printf("target_link_libraries(%s", buildTarget.name)
               buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
               file.printf(")\n\n")

               if buildTarget.install
                  file.printf("install(TARGETS %s DESTINATION bin)\n\n", buildTarget.name)
               end

            else
               if buildTarget.test
                  file.printf("if(KDE3_BUILD_TESTS)\n\n")
               end

               file.printf("kde3_add_executable(%s ${%s})\n\n", buildTarget.name, srcsName)

               file.printf("target_link_libraries(%s", buildTarget.name)
               buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
               file.printf(")\n\n")

               if buildTarget.install
                  file.printf("install(TARGETS %s DESTINATION bin)\n\n", buildTarget.name)
               end

               if buildTarget.test
                  file.printf("endif(KDE3_BUILD_TESTS)\n")
               end

            end

         end

      end

      file.printf("\n########### install files ###############\n\n")

      @installs.each do |key, install|
         file.printf("install(FILES %s DESTINATION %s)\n", install.files, install.location)
      end
      file.printf("\n")

      if @installIcons
         file.printf("kde3_install_icons(%s)\n\n", @iconDir)
      end

      file.printf("\n\n#original Makefile.am contents follow:\n\n")
      @lines.each{ |line| file.printf("#%s", line)}
   end


   def createKDE4ListsFile
      file=File.new(@listsFile, "w+");
      file.printf("\n")

      if @amFile=="Makefile.am"          # the toplevel Makefile.am
          file.printf("find_package(KDE4 REQUIRED)\n\n")
          file.printf("add_definitions(${QT_DEFINITIONS} ${KDE4_DEFINITIONS})\n\n")
          file.printf("include(KDE4Defaults)\n\n")
          file.printf("include(MacroLibrary)\n\n")
          file.printf("include(ConvenienceLibs.cmake)\n\n")
          file.printf("include(ManualStuff.cmake)\n\n")
          file.printf("include(ConfigureChecks.cmake)\n\n")
      end

      if not @includeDirs.empty?
         file.printf("include_directories(")
         @includeDirs.each{ |dir| file.printf("%s ", dir) }
         file.printf(")\n\n")
      end


      if !@configHeaders.empty?
         @configHeaders.each{ |header| file.printf("configure_file(${CMAKE_CURRENT_SOURCE_DIR}/#{header}.cmake ${CMAKE_CURRENT_BINARY_DIR}/#{header})\n\n") }
      end

      if not @subDirs.empty?
         @subDirs.each{ |dir| file.printf("add_subdirectory(%s)\n", dir)}
         file.printf("\n")
      end
      if not @skippedSubDirs.empty?
         @skippedSubDirs.each{ |dir| file.printf("message(STATUS \"${CMAKE_CURRENT_SOURCE_DIR}: skipped subdir %s\")\n", dir)}
      end

      @targets.each do |buildTarget|
         file.printf("\n########### next target ###############\n\n")
#         printf("target name: %s\n", buildTarget.name)

         if buildTarget.type==SharedLib
            srcsName=buildTarget.name+"_LIB_SRCS"
         elsif buildTarget.type==StaticLib
            srcsName=buildTarget.name+"_STAT_SRCS"
#</porting info for libtool convenience libs>
         elsif buildTarget.type==Part
            srcsName=buildTarget.name+"_PART_SRCS"
         elsif buildTarget.type==KDEInit
            srcsName=buildTarget.name+"_KDEINIT_SRCS"
         else
            srcsName=buildTarget.name+"_SRCS"
         end
         uisName=buildTarget.name+"_UI"
         ui3sName=buildTarget.name+"_UI3"
         skelsName=buildTarget.name+"_DCOP_SKEL_SRCS"
         stubsName=buildTarget.name+"_DCOP_STUB_SRCS"
         kcfgsName=buildTarget.name+"_KCFG_SRCS"
         qrcsName=buildTarget.name+"_QRC"


         if buildTarget.type==StaticLib && $withConvLibs
#<porting info for libtool convenience libs>
            $convFile.printf("# %s: %s\n\n", @amFile, buildTarget.name)

            if buildTarget.sources.empty?
               $convFile.printf("set(%s\n", srcsName)
               buildTarget.sources.each { |currentFile| $convFile.printf("    ${CMAKE_SOURCE_DIR}/%s%s\n", @path, currentFile) }
               $convFile.printf(")\n\n", srcsName)
            end
            if not buildTarget.uis.empty?
               $convFile.printf("set(%s\n", uisName)
               buildTarget.uis.each{ |currentFile| $convFile.printf("%s\n", currentFile)}
               $convFile.printf(")\n\n")
            end
            if not buildTarget.ui3s.empty?
               $convFile.printf("set(%s\n", ui3sName)
               buildTarget.ui3s.each{ |currentFile| $convFile.printf("%s\n", currentFile)}
               $convFile.printf(")\n\n")
            end
            if not buildTarget.qrcs.empty?
               $convFile.printf("set(%s\n", qrcsName)
               buildTarget.qrcs.each{ |currentFile| $convFile.printf("%s\n", currentFile)}
               $convFile.printf(")\n\n")
            end
            if not buildTarget.skels.empty?
               $convFile.printf("set(%s\n", skelsName)
               buildTarget.skels.each{ |currentFile| $convFile.printf("%s\n", currentFile)}
               $convFile.printf(")\n\n")
            end
            if not buildTarget.stubs.empty?
               $convFile.printf("set(%s\n", stubsName)
               buildTarget.stubs.each{ |currentFile| $convFile.printf("%s\n", currentFile)}
               $convFile.printf(")\n\n")
            end
            if not buildTarget.kcfgs.empty?
               $convFile.printf("set(%s\n", kcfgsName)
               buildTarget.kcfgs.each{ |currentFile| $convFile.printf("%s\n", currentFile)}
               $convFile.printf(")\n\n")
            end
            next # do nothing else for static libs
         end

         if buildTarget.sources.empty?
            buildTarget.sources.push("${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp")
         end

         if not buildTarget.sources.empty?
            file.printf("set(%s", srcsName)
            needToCreateDummyFile=false
            buildTarget.sources.each do |currentFile|
               # if there are more than 3 files, print each of them on its own line
               file.printf("\n   ") if buildTarget.sources.size>3
               file.printf(" %s", currentFile)
               if currentFile=="dummy.cpp"

                  needToCreateDummyFile=true if not FileTest.exists?(@path+"/dummy.cpp")
               end
            end
            file.printf(")\n\n")

            if needToCreateDummyFile
#                  printf("creating dummy file in #{@path} ________\n")
               file.printf("file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp \"//autogenerated file by cmake\\n\")\n")
            end
         end

         if not buildTarget.uis.empty?
            file.printf("kde4_add_ui_files(%s", srcsName)
            buildTarget.uis.each do |currentFile| 
               # if there are more than 3 files, print each of them on its own line
               file.printf("\n   ") if buildTarget.uis.size>3
               file.printf(" %s", currentFile)
            end
            file.printf(")\n\n")
         end

         if not buildTarget.ui3s.empty?
            file.printf("kde4_add_ui3_files(%s", srcsName)
            buildTarget.ui3s.each do |currentFile| 
               # if there are more than 3 files, print each of them on its own line
               file.printf("\n   ") if buildTarget.ui3s.size>3
               file.printf(" %s", currentFile)
            end
            file.printf(")\n\n")
         end

         if not buildTarget.qrcs.empty?
            file.printf("qt4_add_resources(%s", srcsName)
            buildTarget.qrcs.each do |currentFile| 
               # if there are more than 3 files, print each of them on its own line
               file.printf("\n   ") if buildTarget.qrcs.size>3
               file.printf(" %s", currentFile)
            end
            file.printf(")\n\n")
         end

         if not buildTarget.skels.empty?
            file.printf("message(STATUS \"DCOP has been removed in KDE 4; port code to D-Bus. kde4_add_dcop_skels macro does not exist anymore. We keep it just to remember to port to D-Bus.\")\n")
            file.printf("#kde4_add_dcop_skels(%s\n", srcsName)
            buildTarget.skels.each do |currentFile| 
               # if there are more than 3 files, print each of them on its own line
               file.printf("\n#   ") if buildTarget.skels.size>3
               file.printf("%s ", currentFile)
            end
            file.printf(")\n\n")
         end

         if not buildTarget.stubs.empty?
            file.printf("message(STATUS \"DCOP has been removed in KDE 4; port code to D-Bus. kde4_add_dcop_skels macro does not exist anymore. We keep it just to remember to port to D-Bus.\")\n")
            file.printf("#kde4_add_dcop_stubs(%s\n", srcsName)
            buildTarget.stubs.each do |currentFile| 
               # if there are more than 3 files, print each of them on its own line
               file.printf("\n#   ") if buildTarget.stubs.size>3
               file.printf(" %s", currentFile)
            end
            file.printf(")\n\n")
         end

         if not buildTarget.kcfgs.empty?
            file.printf("kde4_add_kcfg_files(%s", srcsName)
            buildTarget.kcfgs.each do |currentFile| 
               # if there are more than 3 files, print each of them on its own line
               file.printf("\n   ") if buildTarget.kcfgs.size>3
               file.printf(" %s", currentFile)
            end
            file.printf(")\n\n")
         end

         if buildTarget.type==SharedLib
            file.printf("kde4_add_library(%s SHARED ${%s})\n\n", buildTarget.name, srcsName)
            file.printf("target_link_libraries(%s", buildTarget.name)
            buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
            file.printf(")\n\n")

            file.printf("set_target_properties(%s PROPERTIES VERSION %d.%d.%d SOVERSION %d)\n", buildTarget.name, buildTarget.versionNumberMajor, buildTarget.versionNumberMinor, buildTarget.versionNumberPatch, buildTarget.versionNumberMajor)
            file.printf("install(TARGETS %s ${INSTALL_TARGETS_DEFAULT_ARGS})\n\n", buildTarget.name)

         elsif buildTarget.type==StaticLib
            file.printf("kde4_add_library(%s STATIC ${%s})\n\n", buildTarget.name, srcsName)

         elsif buildTarget.type==Part
            if buildTarget.stdPrefix
               file.printf("kde4_add_plugin(%s WITH_PREFIX ${%s})\n\n", buildTarget.name, srcsName)
            else
               file.printf("kde4_add_plugin(%s ${%s})\n\n", buildTarget.name, srcsName)
            end
            file.printf("target_link_libraries(%s", buildTarget.name)
            buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
            file.printf(")\n\n")

            file.printf("install(TARGETS %s DESTINATION ${PLUGIN_INSTALL_DIR})\n\n", buildTarget.name)
         elsif buildTarget.type==KDEInit
            file.printf("kde4_add_kdeinit_executable(%s ${%s})\n\n", buildTarget.name, srcsName)

            file.printf("target_link_libraries(kdeinit_%s", buildTarget.name)
            buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
            file.printf(")\n\n")

            file.printf("install(TARGETS kdeinit_%s DESTINATION ${LIB_INSTALL_DIR})\n\n", buildTarget.name)

            file.printf("target_link_libraries(%s kdeinit_%s)\n", buildTarget.name, buildTarget.name)

            file.printf("install(TARGETS %s ${INSTALL_TARGETS_DEFAULT_ARGS})\n", buildTarget.name)

         else  #executable
            if buildTarget.test
               file.printf("if(KDE4_BUILD_TESTS)\n\n")
            end

            file.printf("kde4_add_executable(%s ${%s})\n\n", buildTarget.name, srcsName)

            file.printf("target_link_libraries(%s", buildTarget.name)
            buildTarget.libs.each { |currentLib| file.printf(" %s", currentLib) }
            file.printf(")\n\n")

            if buildTarget.install
               file.printf("install(TARGETS %s ${INSTALL_TARGETS_DEFAULT_ARGS})\n\n", buildTarget.name)
            end

            if buildTarget.test
               file.printf("endif(KDE4_BUILD_TESTS)\n")
            end

         end

      end

      file.printf("\n########### install files ###############\n\n")

      @installs.each do |key, install|
         file.printf("install(FILES %s DESTINATION %s)\n", install.files, install.location)
      end
      file.printf("\n")

      if @installIcons
         file.printf("kde4_install_icons(${ICON_INSTALL_DIR})\n\n")
      end
      
      if @installDoc
             file.printf("kde4_create_handbook(index.docbook INSTALL_DESTINATION ${HTML_INSTALL_DIR}/en)\n\n")
      end
      #if @createDoxygenDocs
      #   file.printf("kde4_create_doxygen_docs( ")

      #   if @doxygenRecursive
      #      file.printf("RECURSIVE ")
      #   end

      #   if @doxygenInternalDocs
      #      file.printf("INTERNAL_DOCS ")
      #   end

       #  if not @doxygenReferences.empty?
      #      file.printf("REFERENCES ")
      #      @doxygenReferences.each { |ref| file.printf("%s ", ref) }
      #   end
      #   if not @doxygenExcludes.empty?
      #      file.printf("EXCLUDE ")
      #      @doxygenExcludes.each { |exclude| file.printf("%s ", exclude) }
      #   end

      #   file.printf(" )\n\n")
      #end

      file.printf("\n\n#original Makefile.am contents follow:\n\n")
      @lines.each{ |line| file.printf("#%s", line)}

   end
end

def convertAmFile(amFile)
   cmake=CMakeFile.new(amFile)
   if $buildType==BuildKDE4
      cmake.createKDE4ListsFile
   else
      cmake.createKDE3ListsFile
   end
end

if (ARGV.length==1)
   if ARGV[0]=="--no-kde"
      $buildType=BuildNoKDE
      printf("*** no KDE\n")
   elsif ARGV[0]=="--kde3"
      $buildType=BuildKDE3
      printf("*** KDE3\n")
   elsif ARGV[0]=="--kde4"
      $buildType=BuildKDE4
      $withConvLibs=true
      $installDirs=InstallDirsKDE4
      $libMapping=LibMappingKDE4
      printf("*** KDE4\n")
   elsif ARGV[0]=="--help"
      printf("--help\t print this help text\n")
      printf("--version\t print version information\n")
      printf("--no-kde\t disable special KDE application support\n")
      printf("--kde3\t create cmake files from KDE 3 automake files\n")
      printf("--kde4\t create cmake files from KDE 4 automake/unsermake files\n")
      exit
   elsif ARGV[0]=="--version"
      printf("am2cmake (C) 2005-2008, Alexander Neundorf\n")
      printf("am2cmake (C) 2005-2008, Laurent Montel\n")
      printf("Version 0.4, June 9th, 2008\n");
      exit
   else
      printf("Invalid argument, try --help\n")
      exit
   end
end

if $withConvLibs
   $convFile=File.new("ConvenienceLibs.cmake", "w+")
   $convFile.printf("\n#former libtool convenience libraries:\n\n")
end


$configHeaders=Dir["**/*.h.in"]
$configInIns=Dir["**/*.in.in"]

infoFile=File.new("AdditionalInfo.txt", "w+")
infoFile.printf(".h.in-Files\n")
$configHeaders.each{|inFile| infoFile.printf("%s\n", inFile)}
infoFile.printf("\n.in.in-Files\n")
$configInIns.each{|inFile| infoFile.printf("%s\n", inFile)}

Dir["**/Makefile.am"].each{ |currentFile| convertAmFile(currentFile)}
