prefix = /usr
bindir = ${prefix}/bin
program_prefix = mapip-

INSTALL = install -c
PROGRAMS = ar as ld ranlib

all:

install:
	$(INSTALL) -d $(bindir)
	@for PROGRAM in $(PROGRAMS); do \
		cmd="$(INSTALL) -m 755 $$PROGRAM $(bindir)/$(program_prefix)$$PROGRAM"; \
		echo "$$cmd" 1>&2; \
		eval "$$cmd"; \
  done
