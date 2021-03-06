OS := $(shell uname -o 2>/dev/null || uname)
ECHO ?= $(shell which echo || echo echo)

ifeq ($(OS),Darwin)
prefix ?= /usr/local
else
prefix ?= /usr
endif
bindir = ${prefix}/bin
sbindir = ${prefix}/sbin
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
	L=$2; $(RM) $$L; $(INSTALL) -d $${L%/*}; $(LN_S) -v $1 $$L; : $(ECHO) "Link '$2' -> '$1'" 1>&2
endef
else
define symlink_script
	L=$2; $(RM) $$L; $(INSTALL) -d $${L%/*}; $(ECHO) -e '#!/bin/sh\n$(if $3,$3,exec -a '$${L##*/}') env MYNAME="'`basename "$$L" .sh`'" "$$(dirname "$$0")/'$1'" "$$@"' >$$L; chmod a+x $$L; $(ECHO) "Link '$2' -> '$1'" 1>&2
endef
endif

INSTALL = install

all: bash/bash_functions.bash

install-profile: $(PROFILE)
	$(INSTALL) -d $(DESTDIR)$(profiledir)
	$(INSTALL) -m 644 $(PROFILE) $(DESTDIR)$(profiledir)/

uninstall:
	@for SCRIPT in $(SCRIPTS); do \
	  FILE="$(DESTDIR)$(bindir)/$$SCRIPT"; test ! -e "$$FILE" || { $(ECHO) "$(RM) $$FILE" 1>&2; eval "$(RM) $$FILE"; }; \
	done



slackpkg: 
slackpkg: $(SCRIPTS) 
	@set -x; distdir="_inst"; rm -rf $$distdir; mkdir -p $$distdir/$(bindir) $$distdir/root; \
		$(MAKE) install DESTDIR="$$distdir"; \
		bash cp-bash-scripts.sh $$distdir/root/; \
		tar -cJf scripts-`date +%Y%m%d`-slackware.txz -C $$distdir .; \
		rm -rf $$distdir


inst-slackpkg: slackpkg
	for x in /m*/*/pmagic/pmodules/; do \
		rm -vf "$$x"/scripts-*.txz; \
		cp -vf scripts-`date +%Y%m%d`-slackware.txz "$$x"; \
  done

bash/bash_functions.bash: $(wildcard sh/functions/*.sh) sh/functions-assemble.sh
	(bash sh/functions-assemble.sh $@ || $(SHELL) sh/functions-assemble.sh $@) && chmod 644 "$@"

#PROFILE = $(wildcard profile/*.sh profile/*.zsh profile/*.bash)
PROFILE = \
  profile/00-path.sh \
  profile/00-pathmunge.sh \
  profile/256term.sh \
  profile/colorgrep.sh \
  profile/diet.sh \
  profile/dircolors.sh \
  profile/grep-colors.sh \
  profile/history.sh \
  profile/juce.sh \
  profile/ssh-agent-takeover.sh \
  profile/xterm-256color.sh

SCRIPTS := $(AWK_SCRIPTS) $(BASH_SCRIPTS) $(FONTFORGE_SCRIPTS) $(PL_SCRIPTS) $(RB_SCRIPTS) $(SH_SCRIPTS)
AWK_SCRIPTS := $(wildcard awk/*.awk)
BASH_SCRIPTS := $(wildcard bash/*.bash)
FONTFORGE_SCRIPTS := $(wildcard fontforge/*.fontforge)
PL_SCRIPTS := $(wildcard pl/*.pl)
PY_SCRIPTS := $(wildcard py/*.py)
RB_SCRIPTS := $(wildcard rb/*.rb)
#RB_LIBDIR := $(shell ruby -e 'puts $$:' | sort | head -n1)
RB_LIBDIR := ${prefix}/lib/ruby/site_ruby

$(info RB_LIBDIR: $(RB_LIBDIR))
RB_LIBFILES := $(shell cd rb/lib && find * -type f)

#SH_SCRIPTS = $(wildcard *.sh)
SH_SCRIPTS = $(wildcard sh/*.sh)
TYPE_CLASSES =  archives audio books documents eda fonts images incomplete music packages project scripts software sources spice videos vmdisk bin proteus
FN_LINKS = \
					 $(patsubst %,find-%.sh,$(TYPE_CLASSES)) \
					 $(patsubst %,grep-%.sh,$(TYPE_CLASSES)) \
					 $(patsubst %,locate-%.sh,$(TYPE_CLASSES))

CMD_LINKS = git-pull.sh git-push.sh git-commit.sh git-fetch.sh
#SH_SCRIPTS = $(shell ls -t -- *.sh)

install: all $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(RM) $(DESTDIR)$(bindir)/bash_profile.sh
	$(RM) $(DESTDIR)$(bindir)/bash_functions.sh
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
	for F in $(RB_LIBFILES); do \
	  D=$$(dirname "$$F"); \
	  $(ECHO) "$(INSTALL) -d $(DESTDIR)$(RB_LIBDIR)/$$D"; \
	  $(ECHO) "$(INSTALL) -m 644 rb/lib/$$F $(DESTDIR)$(RB_LIBDIR)/$$D"; \
	  $(INSTALL) -d $(DESTDIR)$(RB_LIBDIR)/$$D; \
	  $(INSTALL) -m 644 rb/lib/$$F $(DESTDIR)$(RB_LIBDIR)/$$D; \
	done


	@N=30; set -- $(SH_SCRIPTS); while :; do \
	  $(ECHO) "$(INSTALL) -m 755 `$(ECHO) "$$*" | head -n$$N` $(DESTDIR)$(bindir)/"; \
	  $(INSTALL) -m 755 `$(ECHO) "$$*" | head -n$$N` $(DESTDIR)$(bindir)/; \
	  [ $$# -lt $$N ] && break; \
	  shift $$N; \
	done
	@N=1; set -- $(FN_LINKS); while :; do \
	    if test -n "$$1"; then \
		A=$${1%-*}; \
		$(call symlink_script,$$A-filename.sh,$(DESTDIR)$(bindir)/$$1); \
	    fi; \
	  [ $$# -lt $$N ] && break; shift $$N; \
	done
	@N=1; set -- $(CMD_LINKS); while :; do \
	    if test -n "$$1"; then \
		A=$${1%-*}; \
		$(call symlink_script,$$A-cmd.sh,$(DESTDIR)$(bindir)/$$1); \
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
	$(call symlink_script,../bin/afuse-sshfs.sh,$(DESTDIR)$(sbindir)/mount.asshfs)
	$(call symlink_script,../bin/afuse-curlftpfs.sh,$(DESTDIR)$(sbindir)/mount.aftpfs)

clean:
	$(RM) bash/bash_functions.bash
