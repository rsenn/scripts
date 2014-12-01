OS := $(shell uname -o 2>/dev/null || uname)

ifeq ($(OS),Darwin)
prefix = /usr/local
else
prefix = /usr
endif
bindir = ${prefix}/bin

INSTALL = install

all:
install: $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 $(SCRIPTS) $(DESTDIR)$(bindir)/

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

SCRIPTS = 
SCRIPTS += $(wildcard *.awk *.bash *.fontforge *.pl *.rb *.sh)
