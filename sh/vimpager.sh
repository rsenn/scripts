#!/bin/sh

# Script for using ViM as a PAGER.
# Based on Bram's less.sh.
# Version 1.3

file="$@"
if [ -z "$file" ]; then file="-"; fi

if uname -s | ${GREP-grep -a --line-buffered --color=auto} -iq cygwin; then
    cygwin=1
elif uname -s | ${GREP-grep -a --line-buffered --color=auto} -iq linux; then
    linux=1
elif uname -s | ${GREP-grep -a --line-buffered --color=auto} -iq sunos; then
    solaris=1
else
    bsd=1
fi

less_vim() {
    vim -R \
    -c 'let no_plugin_maps = 1' \
    -c 'set scrolloff=999' \
    -c 'runtime! macros/less.vim' \
    -c 'set foldlevel=999' \
    -c 'set mouse=h' \
    -c 'set nonu' \
    -c 'nmap <ESC>u :nohlsearch<cr>' \
    "$@"
}

do_ps() {
    if [ $solaris ]; then
        ps -u `id -u` -o pid,comm=
    elif [ $bsd ]; then
        ps -U `id -u` -o pid,comm=
    else
        ps fuxw
    fi
}

pproc() {
    if [ $linux ]; then
        ps -p $1 -o comm=
    elif [ $cygwin ]; then
        ps -p $1 | ${SED-sed} -e 's/^I/ /' | ${GREP-grep -a --line-buffered --color=auto} -v PID
    else
        ps -p $1 -o comm= | ${GREP-grep -a --line-buffered --color=auto} -v PID
    fi
}

ppid() {
    if [ $linux ]; then
        ps -p $1 -o ppid=
    elif [ $cygwin ]; then
        ps -p $1 | ${SED-sed} -e 's/^I/ /' | ${GREP-grep -a --line-buffered --color=auto} -v PID | awk '{print $2}'
    else
        ps -p $1 -o ppid= | ${GREP-grep -a --line-buffered --color=auto} -v PID
    fi
}

# Check if called from man, perldoc or pydoc
if do_ps | ${GREP-grep -a --line-buffered --color=auto} -q '\(py\(thon\|doc\)\|man\|perl\(doc\)\?\([0-9.]*\)\?\)\>'; then
    proc=$$
    while next_parent=`ppid $proc` && [ $next_parent != 1 ]; do
        if pproc $next_parent | ${GREP-grep -a --line-buffered --color=auto} -q 'man\>'; then
            cat $file | ${SED-sed} -e 's/\[[^m]*m//g' | ${SED-sed} -e 's/.//g' | less_vim -c 'set ft=man' -; exit
        elif pproc $next_parent | ${GREP-grep -a --line-buffered --color=auto} -q 'py\(thon\|doc\)\>'; then
            cat $file | ${SED-sed} -e 's/\[[^m]*m//g' | ${SED-sed} -e 's/.//g' | less_vim -c 'set ft=man' -; exit
        elif pproc $next_parent | ${GREP-grep -a --line-buffered --color=auto} -q 'perl\(doc\)\?\([0-9.]*\)\?\>'; then
            cat $file | ${SED-sed} -e 's/.//g' | less_vim -c 'set ft=man' -; exit
        fi
        proc=$next_parent
    done
fi

less_vim "$file"

# CONTRIBUTORS:
#
# Rafael Kitover
# Antonio Ospite
# Jean-Marie Gaillourdet
# Perry Hargrave
# Koen Smits
