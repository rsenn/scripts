prefix = /usr
bindir = ${prefix}/bin

INSTALL = install


all:
install: $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 $(SCRIPTS) $(DESTDIR)$(bindir)/


slackpkg: 
slackpkg: $(SCRIPTS) 
	@set -x; distdir="_inst"; rm -rf $$distdir; mkdir -p $$distdir/$(bindir) $$distdir/root; \
		$(INSTALL) -m 755 $(SCRIPTS) $$distdir/$(bindir)/; \
		bash cp-bash-scripts.bash $$distdir/root/; \
		tar -cJf scripts-`date +%Y%m%d`-slackware.txz -C $$distdir .; \
		rm -rf $$distdir

SCRIPTS =  \
	aaview.sh \
	any23gp.sh \
	any2amr-wb.sh \
	any2avi.sh \
	any2cdda.sh \
	any2divx.sh \
	any2dvd.sh \
	any2flac.sh \
	any2m4a.sh \
	any2mp2.sh \
	any2mp3.sh \
	any2mp4.sh \
	any2ogg.sh \
	any2vcd.sh \
	any2wav.sh \
	any2wma.sh \
	any2x264.sh \
	any2xvid.sh \
	any2yuv.sh \
	ape2wav.sh \
	arp-scan.sh \
	autogen.sh \
	avi2vob.sh \
	bcmm-dump.sh \
	bridge-setup.sh \
	cerberus-dump.sh \
	check-symlinks.sh \
	checkpassword-test.sh \
	chroot.sh \
	clear-all-svlogd-logs.sh \
	color-attr-table.sh \
	color-html-table.sh \
	color-syllables.sh \
	colortable16.sh \
	colortable256.pl \
	cp-bash-scripts.bash \
	cpio2tar.sh \
	curl-upload.sh \
	cyginst.sh \
	cygpath.sh \
	decode-ls-lR.sh \
	dir-stats.sh \
	distcc-discover.sh \
	dlynx.sh \
	do-check.sh \
	download-files.sh \
	download-latest.sh \
	dpkg-install.sh \
	dpkg-not-found.sh \
	dpkg-reinstall.sh \
	dump.sh \
	efi-files.sh \
	enable-ip-forward.sh \
	enable-proxy-arp.sh \
	episodes.sh \
	eth-adhoc-vinylz.sh \
	eth-colobern.sh \
	extract-urls.sh \
	fastroll.pl \
	fetch-urls.sh \
	file-hoster-urls.sh \
	filecrop.sh \
	filename-to-lower.sh \
	fileshare-urls.sh \
	fileshut.sh \
	filestube.sh \
	find-archives.sh \
	find-audio.sh \
	find-broken-archives.sh \
	find-file.sh \
	find-fonts.sh \
	find-hfs-start.sh \
	find-images.sh \
	find-incomplete.sh \
	find-media.sh \
	find-music.sh \
	find-not-pmagic-files.sh \
	find-nvidia-kernel.sh \
	find-packages.sh \
	find-required-pmagic-files.sh \
	find-scripts.sh \
	find-software.sh \
	find-sources.sh \
	find-videos.sh \
	flush-iptables.sh \
	fnsed.sh \
	functions-assemble.sh \
	functions-dump.sh \
	gendvdimage.sh \
	get-alive.sh \
	get-names.sh \
	git-config.bash \
	google.sh \
	grep-archives.sh \
	grep-audio.sh \
	grep-fonts.sh \
	grep-images.sh \
	grep-incomplete.sh \
	grep-music.sh \
	grep-packages.sh \
	grep-scripts.sh \
	grep-software.sh \
	grep-sources.sh \
	grep-videos.sh \
	grub-files-find.sh \
	hhv-search.sh \
	histogram.awk \
	home-cleanup.sh \
	image-anim.rb \
	isodate.sh \
	isotime.sh \
	jadmaker.sh \
	jd.sh \
	killall.sh \
	list-elf-binaries.sh \
	list-ftp.sh \
	list-open-wlans.sh \
	list-static-vars.sh \
	list-w32-binaries.sh \
	locate-archives.sh \
	locate-audio.sh \
	locate-fonts.sh \
	locate-images.sh \
	locate-incomplete.sh \
	locate-music.sh \
	locate-packages.sh \
	locate-scripts.sh \
	locate-software.sh \
	locate-sources.sh \
	locate-videos.sh \
	locate32.sh \
	lsof.sh \
	lvm-mount-all.sh \
	maildirfix.sh \
	make-archive.sh \
	make-wine-wrapper.sh \
	media-mnt-find.sh \
	mingwvars.sh \
	mkcrt.sh \
	mkcsr.sh \
	mkkeys.sh \
	mkloglinks.sh \
	mkrunlinks.sh \
	mkv2avi.sh \
	modarchive.sh \
	mount-4shared.sh \
	mount-any.sh \
	mount-iso.sh \
	mpc-listall-by-size.sh \
	mpd-gen-playlist.sh \
	msvc.sh \
	mysql-example.sh \
	mysql-functions.sh \
	otf2ttf.fontforge \
	otf2ttf.sh \
	pack-dir.sh \
	package-search.sh \
	program-paths.sh \
	proxy-list.sh \
	ps2tiff.sh \
	ptrace.sh \
	rcat.sh \
	require.sh \
	rmsem.sh \
	rsed.sh \
	rxvt.sh \
	scan-open-wlans.sh \
	search-files.sh \
	search-fileshare.sh \
	search-sc.sh \
	search-soundcloud.sh \
	sets.sh \
	slackpkg-archive.sh \
	svmigrate.sh \
	svnbuild.sh \
	svnpath.sh \
	svtail.sh \
	test.sh \
	tokextract.sh \
	tokgrep.sh \
	toksubst.sh \
	torrent-finder.sh \
	torrent-info.sh \
	total-uninst-decode.sh \
	ttf2otf.sh \
	udiff.sh \
	unpack-and-remove.sh \
	unpack-each-in-own-folder.sh \
	vbox-sdl.sh \
	vimpager.sh \
	vzlist-dummy.sh \
	warn-auto.sh \
	wlan-digitall.sh \
	wlan-linksys.sh \
	wlan-restart.sh \
	wlan-tmwnet.sh \
	x2x-ssh-fuse.sh

inst-slackpkg: slackpkg
	for x in /m*/*/pmagic/pmodules/; do \
		rm -vf "$$x"/scripts-*.txz; \
		cp -vf scripts-`date +%Y%m%d`-slackware.txz "$$x"; \
  done
