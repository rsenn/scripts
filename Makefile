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

ifeq ($(OS),Msys)
LN_S = false
else
LN_S = ln -sf
endif

ifneq ($(LN_S),false)
define symlink_script
	L=$2; $(RM) $$L; $(INSTALL) -d $${L%/*}; $(LN_S) -v $1 $$L; : echo "Link '$2' -> '$1'" 1>&2
endef
else
define symlink_script
	L=$2; $(RM) $$L; $(INSTALL) -d $${L%/*}; echo -e '#!/bin/sh\n$(if $3,$3,exec -a '$${L##*/}') env MYNAME="'`basename "$$L" .sh`'" "$$(dirname "$$0")/'$1'" "$$@"' >$$L; chmod a+x $$L; echo "Link '$2' -> '$1'" 1>&2
endef
endif

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
	$(SHELL) sh/functions-assemble.sh $@ && chmod 644 "$@"

PROFILE = $(wildcard profile/*.sh profile/*.zsh profile/*.bash)
SCRIPTS = $(AWK_SCRIPTS) $(BASH_SCRIPTS) $(FONTFORGE_SCRIPTS) $(PL_SCRIPTS) $(RB_SCRIPTS) $(SH_SCRIPTS)
AWK_SCRIPTS = $(wildcard awk/*.awk)
BASH_SCRIPTS = $(wildcard bash/*.bash)
FONTFORGE_SCRIPTS = $(wildcard fontforge/*.fontforge)
PL_SCRIPTS = $(wildcard pl/*.pl)
PY_SCRIPTS = $(wildcard py/*.py)
RB_SCRIPTS = $(wildcard rb/*.rb)
#SH_SCRIPTS = $(wildcard *.sh)
SH_SCRIPTS = $(wildcard sh/*.sh)
LINKS = find-audio.sh find-archives.sh find-books.sh find-fonts.sh find-images.sh find-incomplete.sh find-music.sh find-packages.sh find-scripts.sh find-software.sh find-sources.sh find-videos.sh find-vmdisk.sh find-project.sh grep-archives.sh grep-audio.sh grep-books.sh grep-fonts.sh grep-images.sh grep-music.sh grep-packages.sh grep-scripts.sh grep-software.sh grep-sources.sh grep-videos.sh grep-vmdisk.sh
#SH_SCRIPTS = $(shell ls -t -- *.sh)

install: $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(RM) $(DESTDIR)$(bindir)/bash_{functions,profile}.sh
	$(foreach NAME,bash_profile bash_functions,\
	    $(INSTALL) -m 755 bash/$(NAME).bash $(DESTDIR)$(bindir)/; \
	    $(LN_S) $(NAME).bash $(DESTDIR)$(bindir)/$(NAME).sh || \
            (cd $(DESTDIR)$(bindir) && junction $(NAME).sh $(NAME).bash) || \
	    cp -v -f -- $(DESTDIR)$(bindir)/$(NAME).bash $(DESTDIR)$(bindir)/$(NAME).sh; \
	)
#	$(foreach NAME,bash_profile bash_functions,\
#	    $(call symlink_script,$(NAME).bash,$(DESTDIR)$(bindir)/$(NAME).sh,.)\
#	)
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
		A=$${1%-*}; \
		$(call symlink_script,$$A-filename.sh,$(DESTDIR)$(bindir)/$$1); \
	    fi; \
	  [ $$# -lt $$N ] && break; shift $$N; \
	done
	$(INSTALL) -d $(DESTDIR)$(datadir)/compiletrace
	$(INSTALL) -m 755 compiletrace/compiletrace.sh $(DESTDIR)$(datadir)/compiletrace
	$(INSTALL) -d $(DESTDIR)$(datadir)/compiletrace/bin
	for PROG in ar as cc dlltool g++ gcc ld nm objcopy objdump ranlib strip; do \
	  $(call symlink_script,../compiletrace.sh,$(DESTDIR)$(datadir)/compiletrace/bin/$$PROG); \
	done
	$(call symlink_script,../share/compiletrace/compiletrace.sh,$(DESTDIR)$(bindir)/compiletrace)
