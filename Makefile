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
SCRIPTS = $(AWK_SCRIPTS) $(BASH_SCRIPTS) $(FONTFORGE_SCRIPTS) $(PL_SCRIPTS) $(RB_SCRIPTS) $(SH_SCRIPTS)
AWK_SCRIPTS = $(wildcard *.awk)
BASH_SCRIPTS = $(wildcard *.bash)
FONTFORGE_SCRIPTS = $(wildcard *.fontforge)
PL_SCRIPTS = $(wildcard *.pl)
PY_SCRIPTS = $(wildcard *.py)
RB_SCRIPTS = $(wildcard *.rb)
#SH_SCRIPTS = $(wildcard *.sh)
SH_SCRIPTS = aaview.sh adb-screenshot.sh aliases.sh any23gp.sh any2amr-wb.sh any2avi.sh any2cdda.sh any2divx.sh any2dvd.sh any2flac.sh any2m4a.sh any2mp2.sh any2mp3.sh any2mp4.sh any2ogg.sh any2vcd.sh any2wav.sh any2wma.sh any2x264.sh any2xvid.sh any2yuv.sh ape2wav.sh arp-scan.sh autogen.sh avi2vob.sh bash_functions.sh bash_profile.sh bcmm-dump.sh bin-dep.sh binary-subst.sh bridge-setup.sh browser-history.sh cdhook.sh cerberus-dump.sh check-symlinks.sh checkpassword-test.sh chroot.sh clear-all-svlogd-logs.sh color-attr-table.sh color-html-table.sh color-syllables.sh colorgcc.sh colorgrep.sh colors.sh colortable16.sh conf.sh cpio2tar.sh cpuinfo.sh curl-upload.sh cyginst.sh cygpath.sh daemontools-conf.sh decode-ls-lR.sh diff-all-versions.sh dir-stats.sh distcc-discover.sh dlynx.sh do-check.sh download-files.sh download-latest.sh dpkg-install.sh dpkg-not-found.sh dpkg-reinstall.sh dump-compiler-defines.sh dump-eagle-script.sh dump-reg-script.sh dump.sh efi-files.sh enable-ip-forward.sh enable-proxy-arp.sh episodes.sh eps2svg.sh eth-adhoc-vinylz.sh eth-colobern.sh ethernet-connect.sh extract-includes.sh extract-pmagic-system.sh extract-urls.sh fetch-urls.sh file-hoster-urls.sh filecrop.sh filename-to-lower.sh filename-tolower.sh fileshare-urls.sh fileshut.sh filestube.sh filezilla-server-entry.sh find-broken-archives.sh find-file.sh find-filename.sh find-hfs-start.sh find-media.sh find-not-pmagic-files.sh find-nvidia-kernel.sh find-required-pmagic-files.sh fix-perms.sh flush-iptables.sh fnsed.sh functions-assemble.sh functions-dump.sh functions.sh fuse-directives.sh gen-implibs.sh gendvdimage.sh generate-rule-declarations.sh generate-rule-ids.sh generate-rule-names.sh get-alive.sh get-cygwin-ports-repositories.sh get-names.sh get-ubuntuupdates-ppas.sh getopts.sh git-big-file-finder.sh git-pull.sh google.sh grep-colors.sh grep-fileclass.sh grep-filename.sh grep-incomplete.sh grub-files-find.sh hashstash.sh hhv-search.sh home-cleanup.sh impgen.sh install-alternatives-entry.sh isodate.sh isotime.sh iterate-pages.sh jadmaker.sh jd.sh killall.sh libraries-mkcmd-vars.sh list-elf-binaries.sh list-ftp.sh list-only-latest.sh list-open-wlans.sh list-rule-names.sh list-static-vars.sh list-w32-binaries.sh locate-archives.sh locate-audio.sh locate-books.sh locate-fonts.sh locate-images.sh locate-incomplete.sh locate-music.sh locate-packages.sh locate-scripts.sh locate-software.sh locate-sources.sh locate-videos.sh locate-vmdisk.sh locate32.sh locks.sh logrun.sh ls.sh lsof.sh lvm-mount-all.sh maildirfix.sh make-archive.sh make-m3u.sh make-wine-wrapper.sh media-mnt-find.sh messages.sh mingw-build.sh mingwvars.sh mk-list-index.sh mk-mingw-vars.sh mk-msvc-vars-cmd.sh mk-pkg-lists.sh mkcrt.sh mkcsr.sh mkkeys.sh mkloglinks.sh mkrunlinks.sh mkv2avi.sh modarchive.sh mount-4shared.sh mount-any.sh mount-cifs.sh mount-iso.sh mpc-listall-by-size.sh mpd-gen-playlist.sh msvc.sh mv.sh mysql-example.sh mysql-functions.sh newfile.sh otf2ttf.sh pack-dir.sh package-search.sh parse-build-log.sh pdfopt.sh prepare-build-dir.sh program-paths.sh prompt.sh proxy-list.sh proxy-server.sh ps2tiff.sh ptrace.sh putty-sessions.sh qemu-bridge.sh qemu-system-macosx.sh rcat.sh reg-generic.sh require.sh rmsem.sh rsed.sh rsync.sh runtest.sh rxvt.sh scan-open-wlans.sh scriptlist.sh search-fileshare.sh search-sc.sh search-soundcloud.sh set-toolchain.sh sets.sh shflags.sh shopts.sh shrinkpdf.sh slackpkg-archive.sh ssh-agent-takeover.sh subst.sh svmigrate.sh svnbuild.sh svnpath.sh svtail.sh t.sh test.sh test_function_declaration.sh tokextract.sh tokgrep.sh toksubst.sh tor-change-exitnode.sh torrent-finder.sh torrent-info.sh total-uninst-decode.sh ttf2otf.sh udiff.sh unpack-and-remove.sh unpack-each-in-own-folder.sh urlcoding.sh vbox-sdl.sh vcvars.sh vimpager.sh vzlist-dummy.sh warn-auto.sh wlan-connect.sh wlan-digitall.sh wlan-hotel-flora.sh wlan-linksys.sh wlan-neversil.sh wlan-polygonstr.sh wlan-projekt-mbs.sh wlan-restart.sh wlan-tmwnet.sh wlan-vinylz.sh x11.sh x2x-ssh-fuse.sh xterm-256color.sh
LINKS = find-audio.sh find-books.sh find-fonts.sh find-images.sh find-incomplete.sh find-music.sh find-packages.sh find-scripts.sh find-software.sh find-sources.sh find-videos.sh find-vmdisk.sh grep-archives.sh grep-audio.sh grep-books.sh grep-fonts.sh grep-images.sh grep-music.sh grep-packages.sh grep-scripts.sh grep-software.sh grep-sources.sh grep-videos.sh grep-vmdisk.sh
#SH_SCRIPTS = $(shell ls -t -- *.sh)

install: $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 $(AWK_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(BASH_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(FONTFORGE_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(PL_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(PY_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(RB_SCRIPTS) $(DESTDIR)$(bindir)/
	@N=30; set -- $(SH_SCRIPTS); while :; do \
	  echo "$(INSTALL) -m 755 $${@:1:$$N} $(DESTDIR)$(bindir)/"; \
	  $(INSTALL) -m 755 $${@:1:$$N} $(DESTDIR)$(bindir)/; \
	  [ $$# -lt $$N ] && break; \
	  shift $$N; \
	done
	@N=1; set -- $(LINKS); while :; do \
		  if test -n "$$1"; then \
				echo "ln -sf "$${1%%-*}-filename.sh"  $(DESTDIR)$(bindir)/$$1"; \
				ln -sf "$${1%%-*}-filename.sh"  $(DESTDIR)$(bindir)/$$1; \
			fi; \
	  [ $$# -lt $$N ] && break; \
	  shift $$N; \
	done
