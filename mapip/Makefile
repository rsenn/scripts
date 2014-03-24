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

clean:
	$(RM) zpipe.o zpipe$(EXEEXT)

install:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	@for PROGRAM in $(PROGRAMS); do \
		cmd="$(INSTALL) -m 755 $$PROGRAM $(DESTDIR)$(bindir)/$(program_prefix)$$PROGRAM"; \
		echo "$$cmd" 1>&2; \
		eval "$$cmd"; \
  done
	$(INSTALL) -m 755 zpipe$(EXEEXT) $(DESTDIR)$(bindir)
