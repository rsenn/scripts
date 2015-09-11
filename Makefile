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
RB_SCRIPTS = $(wildcard *.rb)
#SH_SCRIPTS = $(wildcard *.sh)
SH_SCRIPTS = $(shell ls -t -- *.sh)

install: $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 $(AWK_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(BASH_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(FONTFORGE_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(PL_SCRIPTS) $(DESTDIR)$(bindir)/
	$(INSTALL) -m 755 $(RB_SCRIPTS) $(DESTDIR)$(bindir)/
	@N=30; set -- $(SH_SCRIPTS); while :; do \
	  echo "$(INSTALL) -m 755 $${@:1:$$N} $(DESTDIR)$(bindir)/"; \
	  $(INSTALL) -m 755 $${@:1:$$N} $(DESTDIR)$(bindir)/; \
	  [ $$# -lt $$N ] && break; \
	  shift $$N; \
	done
