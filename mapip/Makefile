prefix = /usr
bindir = ${prefix}/bin
program_prefix = mapip-

CC = gcc
CFLAGS = -g -O2 -Wall

INSTALL = install -c
PROGRAMS = ar as ld ranlib

all: zpipe$(EXEEXT)

.c.o:
	$(CC) $(CFLAGS) -c $<

zpipe$(EXEEXT): zpipe.o
	$(CC) -o $@ $^ -lz

.PHONY: clean install install-tools install-zpipe install-both install-all

clean:
	$(RM) zpipe.o zpipe$(EXEEXT)

install: install-tools install-zpipe

install-tools:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	@for PROGRAM in $(PROGRAMS); do \
		cmd="$(INSTALL) -m 755 $$PROGRAM $(DESTDIR)$(bindir)/$(program_prefix)$$PROGRAM"; \
		echo "$$cmd" 1>&2; \
		eval "$$cmd"; \
  done

install-zpipe:
	$(INSTALL) -m 755 zpipe$(EXEEXT) $(DESTDIR)$(bindir)

install-both:
	$(MAKE) program_prefix="$(program_prefix)" prefix="$(prefix)" install-tools
	$(MAKE) program_prefix="" prefix="$(prefix)/$(program_prefix:%-=%)" install-tools

install-all: install-zpipe
	$(MAKE) program_prefix="mapip-" install-both
#	$(MAKE) program_prefix="mapip2-" install-both
