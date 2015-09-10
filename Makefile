OS := $(shell uname -o 2>/dev/null || uname)

ifeq ($(OS),Darwin)
prefix = /usr/local
else
prefix = /usr
endif
bindir = ${prefix}/bin
sysconfdir = /etc
profiledir = ${sysconfdir}/profile.d

INSTALL = install

all:

install-profile: $(PROFILE)
	$(INSTALL) -d $(DESTDIR)$(profiledir)
	$(INSTALL) -m 644 $(PROFILE) $(DESTDIR)$(profiledir)/

uninstall:
	@for SCRIPT in $(SCRIPTS); do \
	  FILE="$(DESTDIR)$(bindir)/$$SCRIPT"; test ! -e "$$FILE" || { echo "$(RM) $$FILE" 1>&2; eval "$(RM) $$FILE"; }; \
	done



slackpkg: 
slackpkg: $(SCRIPTS) 
	@set -x; distdir="_inst"; rm -rf $$distdir; mkdir -p $$distdir/$(bindir) $$distdir/root; \
		$(INSTALL) -m 755 $(SCRIPTS) $$distdir/$(bindir)/; \
		bash cp-bash-scripts.bash $$distdir/root/; \
		tar -cJf scripts-`date +%Y%m%d`-slackware.txz -C $$distdir .; \
		rm -rf $$distdir


inst-slackpkg: slackpkg
	for x in /m*/*/pmagic/pmodules/; do \
		rm -vf "$$x"/scripts-*.txz; \
		cp -vf scripts-`date +%Y%m%d`-slackware.txz "$$x"; \
  done

PROFILE = $(wildcard profile/*.sh profile/*.zsh profile/*.bash)
SCRIPTS = $(wildcard *.awk *.bash *.fontforge *.pl *.rb *.sh)

install: $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 histogram.awk $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ftrace.bash git-config.bash cp-bash-scripts.bash $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 otf2ttf.fontforge $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 colortable256.pl c256.pl fastroll.pl geteltorito.pl rtf2doc.pl $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 am2cmake.rb gencmake.rb image-anim.rb png-analyze.rb pdfcompress.rb $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 colorgcc.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 parse-build-log.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 vimpager.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 aaview.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 adb-screenshot.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 aliases.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any23gp.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2amr-wb.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2avi.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2cdda.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2divx.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2dvd.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2flac.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2m4a.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2mp2.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2mp3.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2mp4.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2ogg.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2vcd.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2wav.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2wma.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2x264.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2xvid.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 any2yuv.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ape2wav.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 arp-scan.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 autogen.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 avi2vob.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 bash_functions.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 bash_profile.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 bcmm-dump.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 bin-dep.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 binary-subst.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 bridge-setup.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 browser-history.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 cdhook.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 cerberus-dump.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 check-symlinks.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 checkpassword-test.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 chroot.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 clear-all-svlogd-logs.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 color-attr-table.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 color-html-table.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 color-syllables.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 colorgrep.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 colors.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 colortable16.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 conf.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 cpio2tar.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 curl-upload.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 cyginst.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 cygpath.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 daemontools-conf.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 decode-ls-lR.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dir-stats.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 distcc-discover.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dlynx.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 do-check.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 download-files.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 download-latest.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dpkg-install.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dpkg-not-found.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dpkg-reinstall.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dump-compiler-defines.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dump-eagle-script.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dump-reg-script.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 dump.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 efi-files.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 enable-ip-forward.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 enable-proxy-arp.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 episodes.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 eps2svg.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 eth-adhoc-vinylz.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 eth-colobern.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ethernet-connect.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 extract-includes.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 extract-pmagic-system.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 extract-urls.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 fetch-urls.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 file-hoster-urls.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 filecrop.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 filename-to-lower.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 filename-tolower.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 fileshare-urls.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 fileshut.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 filestube.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 filezilla-server-entry.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-archives.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-audio.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-books.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-broken-archives.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-file.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-fonts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-hfs-start.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-images.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-incomplete.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-media.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-music.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-not-pmagic-files.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-nvidia-kernel.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-packages.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-required-pmagic-files.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-scripts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-software.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-sources.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-videos.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 find-vmdisk.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 flush-iptables.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 fnsed.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 functions-assemble.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 functions-dump.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 functions.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 fuse-directives.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 gen-implibs.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 gendvdimage.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 generate-rule-declarations.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 generate-rule-ids.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 generate-rule-names.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 get-alive.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 get-cygwin-ports-repositories.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 get-names.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 get-ubuntuupdates-ppas.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 getopts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 git-big-file-finder.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 git-pull.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 google.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-archives.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-audio.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-books.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-colors.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-fileclass.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-fonts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-images.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-incomplete.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-music.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-packages.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-scripts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-software.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-sources.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-videos.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grep-vmdisk.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 grub-files-find.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 hashstash.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 hhv-search.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 home-cleanup.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 impgen.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 install-alternatives-entry.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 isodate.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 isotime.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 iterate-pages.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 jadmaker.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 jd.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 killall.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 list-elf-binaries.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 list-ftp.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 list-only-latest.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 list-open-wlans.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 list-rule-names.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 list-static-vars.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 list-w32-binaries.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-archives.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-audio.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-books.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-fonts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-images.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-incomplete.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-music.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-packages.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-scripts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-software.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-sources.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-videos.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate-vmdisk.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locate32.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 locks.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 logrun.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ls.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 lsof.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 lvm-mount-all.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 maildirfix.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 make-archive.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 make-m3u.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 make-wine-wrapper.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 media-mnt-find.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 messages.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mingw-build.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mingwvars.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mk-list-index.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mk-mingw-vars.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mk-msvc-vars-cmd.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mk-pkg-lists.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mkcrt.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mkcsr.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mkkeys.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mkloglinks.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mkrunlinks.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mkv2avi.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 modarchive.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mount-4shared.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mount-any.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mount-cifs.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mount-iso.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mpc-listall-by-size.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mpd-gen-playlist.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 msvc.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mysql-example.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 mysql-functions.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 newfile.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 otf2ttf.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 pack-dir.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 package-search.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 pdfopt.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 program-paths.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 prompt.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 proxy-list.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 proxy-server.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ps2tiff.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ptrace.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 putty-sessions.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 qemu-bridge.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 qemu-system-macosx.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 rcat.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 reg-generic.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 require.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 rmsem.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 rsed.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 rsync.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 runtest.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 rxvt.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 scan-open-wlans.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 scriptlist.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 search-fileshare.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 search-sc.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 search-soundcloud.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 set-toolchain.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 sets.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 shflags.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 shopts.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 shrinkpdf.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 slackpkg-archive.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ssh-agent-takeover.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 svmigrate.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 svnbuild.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 svnpath.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 svtail.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 t.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 test.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 test_function_declaration.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 tokextract.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 tokgrep.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 toksubst.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 tor-change-exitnode.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 torrent-finder.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 torrent-info.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 total-uninst-decode.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 ttf2otf.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 udiff.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 unpack-and-remove.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 unpack-each-in-own-folder.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 urlcoding.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 vbox-sdl.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 vcvars.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 vzlist-dummy.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 warn-auto.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-connect.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-digitall.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-hotel-flora.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-linksys.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-neversil.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-polygonstr.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-projekt-mbs.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-restart.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-tmwnet.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 wlan-vinylz.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 x11.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 x2x-ssh-fuse.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 xterm-256color.sh $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 diff-all-versions.sh $(DESTDIR)$(bindir)/
