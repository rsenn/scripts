(set -x; ${GREP-grep -a --line-buffered --color=auto} -q @timidity.cvs.sourceforge.net ~/.cvspass 2>/dev/null || cat <<\EOF >>~/.cvspass
\1 :pserver:anonymous@timidity.cvs.sourceforge.net:2401/cvsroot/timidity A
EOF
mkdir -p timidity-cvs
cvs -z3 -d:pserver:anonymous@timidity.cvs.sourceforge.net:/cvsroot/timidity co -d timidity-cvs -P timidity)
