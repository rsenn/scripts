OS := $(shell uname -o 2>/dev/null || uname)

ifeq ($(OS),Darwin)
prefix = /usr/local
else
prefix = /usr
endif
bindir = ${prefix}/bin
sysconfdir = /etc
datadir = ${prefix}/share
profiledir = ${sysconfdir}/profile.d

INSTALL = install

all: bash/bash_functions.bash

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

bash/bash_functions.bash: $(wildcard sh/functions/*.sh) sh/functions-assemble.sh
	$(SHELL) sh/functions-assemble.sh $@

PROFILE = $(wildcard profile/*.sh profile/*.zsh profile/*.bash)
SCRIPTS = $(AWK_SCRIPTS) $(BASH_SCRIPTS) $(FONTFORGE_SCRIPTS) $(PL_SCRIPTS) $(RB_SCRIPTS) $(SH_SCRIPTS)
AWK_SCRIPTS = $(wildcard awk/*.awk)
BASH_SCRIPTS = $(wildcard bash/*.bash)
FONTFORGE_SCRIPTS = $(wildcard fontforge/*.fontforge)
PL_SCRIPTS = $(wildcard pl/*.pl)
PY_SCRIPTS = $(wildcard py/*.py)
RB_SCRIPTS = $(wildcard rb/*.rb)
#SH_SCRIPTS = $(wildcard *.sh)
SH_SCRIPTS = sh/aaview.sh sh/adb-screenshot.sh sh/aliases.sh sh/any23gp.sh sh/any2amr-wb.sh sh/any2avi.sh sh/any2cdda.sh sh/any2divx.sh sh/any2dvd.sh sh/any2flac.sh sh/any2m4a.sh sh/any2mp2.sh sh/any2mp3.sh sh/any2mp4.sh sh/any2ogg.sh sh/any2vcd.sh sh/any2wav.sh sh/any2wma.sh sh/any2x264.sh sh/any2xvid.sh sh/any2yuv.sh sh/ape2wav.sh sh/arp-scan.sh sh/autogen.sh sh/avi2vob.sh sh/bcmm-dump.sh sh/bin-dep.sh sh/binary-subst.sh sh/bridge-setup.sh sh/browser-history.sh sh/cdhook.sh sh/cerberus-dump.sh sh/check-symlinks.sh sh/checkpassword-test.sh sh/chroot.sh sh/clear-all-svlogd-logs.sh sh/color-attr-table.sh sh/color-html-table.sh sh/color-syllables.sh sh/colorgcc.sh sh/colorgrep.sh sh/colors.sh sh/colortable16.sh sh/conf.sh sh/cpio2tar.sh sh/cpuinfo.sh sh/curl-upload.sh sh/cyginst.sh sh/cygpath.sh sh/daemontools-conf.sh sh/decode-ls-lR.sh sh/diff-all-versions.sh sh/dir-stats.sh sh/distcc-discover.sh sh/dlynx.sh sh/do-check.sh sh/download-files.sh sh/download-latest.sh sh/dpkg-install.sh sh/dpkg-not-found.sh sh/dpkg-reinstall.sh sh/dump-compiler-defines.sh sh/dump-eagle-script.sh sh/dump-reg-script.sh sh/dump.sh sh/efi-files.sh sh/enable-ip-forward.sh sh/enable-proxy-arp.sh sh/episodes.sh sh/eps2svg.sh sh/eth-adhoc-vinylz.sh sh/eth-colobern.sh sh/ethernet-connect.sh sh/extract-includes.sh sh/extract-pmagic-system.sh sh/extract-urls.sh sh/fetch-urls.sh sh/file-hoster-urls.sh sh/filecrop.sh sh/filename-to-lower.sh sh/filename-tolower.sh sh/fileshare-urls.sh sh/fileshut.sh sh/filestube.sh sh/filezilla-server-entry.sh sh/find-broken-archives.sh sh/find-file.sh sh/find-filename.sh sh/find-hfs-start.sh sh/find-media.sh sh/find-not-pmagic-files.sh sh/find-nvidia-kernel.sh sh/find-required-pmagic-files.sh sh/fix-perms.sh sh/flush-iptables.sh sh/fnsed.sh sh/functions-assemble.sh sh/functions-dump.sh sh/functions.sh sh/fuse-directives.sh sh/gen-implibs.sh sh/gendvdimage.sh sh/generate-rule-declarations.sh sh/generate-rule-ids.sh sh/generate-rule-names.sh sh/get-alive.sh sh/get-cygwin-ports-repositories.sh sh/get-exts.tmp.sh sh/get-names.sh sh/get-ubuntuupdates-ppas.sh sh/getopts.sh sh/git-big-file-finder.sh sh/git-pull.sh sh/google.sh sh/grep-colors.sh sh/grep-fileclass.sh sh/grep-filename.sh sh/grep-incomplete.sh sh/grub-files-find.sh sh/hashstash.sh sh/hhv-search.sh sh/home-cleanup.sh sh/impgen.sh sh/install-alternatives-entry.sh sh/isodate.sh sh/isotime.sh sh/iterate-pages.sh sh/jadmaker.sh sh/jd.sh sh/killall.sh sh/libraries-mkcmd-vars.sh sh/list-elf-binaries.sh sh/list-ftp.sh sh/list-only-latest.sh sh/list-open-wlans.sh sh/list-rule-names.sh sh/list-static-vars.sh sh/list-w32-binaries.sh sh/locate-archives.sh sh/locate-audio.sh sh/locate-books.sh sh/locate-fonts.sh sh/locate-images.sh sh/locate-incomplete.sh sh/locate-music.sh sh/locate-packages.sh sh/locate-scripts.sh sh/locate-software.sh sh/locate-sources.sh sh/locate-videos.sh sh/locate-vmdisk.sh sh/locate32.sh sh/locks.sh sh/logrun.sh sh/ls.sh sh/lsof.sh sh/lvm-mount-all.sh sh/maildirfix.sh sh/make-archive.sh sh/make-m3u.sh sh/make-wine-wrapper.sh sh/media-mnt-find.sh sh/messages.sh sh/mingw-build.sh sh/mingwvars.sh sh/mk-list-index.sh sh/mk-mingw-vars.sh sh/mk-msvc-vars-cmd.sh sh/mk-pkg-lists.sh sh/mkcrt.sh sh/mkcsr.sh sh/mkkeys.sh sh/mkloglinks.sh sh/mkrunlinks.sh sh/mkv2avi.sh sh/modarchive.sh sh/mount-4shared.sh sh/mount-any.sh sh/mount-cifs.sh sh/mount-iso.sh sh/mpc-listall-by-size.sh sh/mpd-gen-playlist.sh sh/msvc.sh sh/mv.sh sh/mysql-example.sh sh/mysql-functions.sh sh/newfile.sh sh/otf2ttf.sh sh/pack-dir.sh sh/package-search.sh sh/parse-build-log.sh sh/pdfopt.sh sh/prepare-build-dir.sh sh/program-paths.sh sh/prompt.sh sh/proxy-list.sh sh/proxy-server.sh sh/ps2tiff.sh sh/ptrace.sh sh/putty-sessions.sh sh/qemu-bridge.sh sh/qemu-system-macosx.sh sh/rcat.sh sh/reg-generic.sh sh/require.sh sh/rmsem.sh sh/rsed.sh sh/rsync.sh sh/runtest.sh sh/rxvt.sh sh/scan-open-wlans.sh sh/scriptlist.sh sh/search-fileshare.sh sh/search-sc.sh sh/search-soundcloud.sh sh/set-toolchain.sh sh/sets.sh sh/shflags.sh sh/shopts.sh sh/shrinkpdf.sh sh/slackpkg-archive.sh sh/ssh-agent-takeover.sh sh/subst.sh sh/svmigrate.sh sh/svnbuild.sh sh/svnpath.sh sh/svtail.sh sh/t.sh sh/test.sh sh/test_function_declaration.sh sh/tokextract.sh sh/tokgrep.sh sh/toksubst.sh sh/tor-change-exitnode.sh sh/torrent-finder.sh sh/torrent-info.sh sh/total-uninst-decode.sh sh/ttf2otf.sh sh/udiff.sh sh/unpack-and-remove.sh sh/unpack-each-in-own-folder.sh sh/urlcoding.sh sh/vbox-sdl.sh sh/vcvars.sh sh/vimpager.sh sh/vzlist-dummy.sh sh/warn-auto.sh sh/wlan-connect.sh sh/wlan-digitall.sh sh/wlan-hotel-flora.sh sh/wlan-linksys.sh sh/wlan-neversil.sh sh/wlan-polygonstr.sh sh/wlan-projekt-mbs.sh sh/wlan-restart.sh sh/wlan-tmwnet.sh sh/wlan-vinylz.sh sh/x11.sh sh/x2x-ssh-fuse.sh sh/xterm-256color.sh
LINKS = find-audio.sh find-archives.sh find-books.sh find-fonts.sh find-images.sh find-incomplete.sh find-music.sh find-packages.sh find-scripts.sh find-software.sh find-sources.sh find-videos.sh find-vmdisk.sh grep-archives.sh grep-audio.sh grep-books.sh grep-fonts.sh grep-images.sh grep-music.sh grep-packages.sh grep-scripts.sh grep-software.sh grep-sources.sh grep-videos.sh grep-vmdisk.sh
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
	$(INSTALL) -d $(DESTDIR)$(datadir)/compiletrace
	$(INSTALL) -m 755 compiletrace/compiletrace.sh $(DESTDIR)$(datadir)/compiletrace
	$(INSTALL) -d $(DESTDIR)$(datadir)/compiletrace/bin
	for PROG in ar as cc dlltool g++ gcc ld nm objcopy objdump ranlib strip; do \
		ln -svf ../compiletrace.sh $(DESTDIR)$(datadir)/compiletrace/bin/$$PROG; \
	done
