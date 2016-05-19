#!/bin/sh
NL="
"

#cut_ver() { cat "$@" | cut_trailver | ${SED-sed} 's,[-.]rc[[:alnum:]][^-.]*,,g ;; s,[-.]b[[:alnum:]][^-.]*,,g ;; s,[-.]git[_[:alnum:]][^-.]*,,g ;; s,[-.]svn[_[:alnum:]][^-.]*,,g ;; s,[-.]linux[^-.]*,,g ;; s,[-.]v[[:alnum:]][^-.]*,,g ;; s,[-.]beta[_[:alnum:]][^-.]*,,g ;; s,[-.]alpha[_[:alnum:]][^-.]*,,g ;; s,[-.]a[_[:alnum:]][^-.]*,,g ;; s,[-.]trunk[^-.]*,,g ;; s,[-.]release[_[:alnum:]][^-.]*,,g ;; s,[-.]GIT[^-.]*,,g ;; s,[-.]SVN[^-.]*,,g ;; s,[-.]r[_[:alnum:]][^-.]*,,g ;; s,[-.]dnh[_[:alnum:]][^-.]*,,g' | ${SED-sed} 's,[^-.]*git[_0-9][^.].,,g ;; s,[^-.]*svn[_0-9][^.].,,g ;; s,[^-.]*GIT[^.].,,g ;; s,[^-.]*SVN[^.].,,g' | ${SED-sed} 's,\.\(P\)\?[0-9][_+[:digit:]]*\.,.,g' | ${SED-sed} 's,[.-][0-9][_+[:alnum:]]*$,,g ;; s,[.-][0-9][_+[:alnum:]]*\([-.]\),\1,g' | ${SED-sed} 's,[-_.][0-9]*\(svn\)\?\(git\)\?\(P\)\?\(rc\)\?[0-9][_+[:digit:]]*\(-.\),\5,g' | ${SED-sed} 's,-[0-9][._+[:digit:]]*$,, ;;  s,-[0-9][._+[:digit:]]*$,,' | ${SED-sed} 's,[.-][0-9][_+[:alnum:]]*$,,g ;; s,[.-][0-9]*\(rc[0-9]\)\?\(b[0-9]\)\?\(git[_0-9]\)\?\(svn[_0-9]\)\?\(linux\)\?\(v[0-9]\)\?\(beta[_0-9]\)\?\(alpha[_0-9]\)\?\(a[_0-9]\)\?\(trunk\)\?\(release[_0-9]\)\?\(GIT\)\?\(SVN\)\?\(r[_0-9]\)\?\(dnh[_0-9]\)\?[0-9][_+[:alnum:]]*\.,.,g' | ${SED-sed} 's,\.[0-9][^.]*\.,.,g'; }

#cut_trailver() { cat "$@" | ${SED-sed} 's,[-_.]\?[0-9][^-.]*\(\.[0-9][^-.]*\)*$,,'; }
cut_trailver() { cat "$@" | ${SED-sed} 's,[-_.][0-9][^/]*$,,'; }

trap 'rm -f "$TMP"' EXIT
TMP=`mktemp`

for ARG; do
  cat "$ARG" |sort -V >"$TMP" 

  cut_trailver "$TMP" |uniq  |while read -r NAME; do 
#  echo "+ $NAME" 1>&2
    ${GREP-grep -a --line-buffered --color=auto} "^${NAME}[^0-9A-Za-z][0-9]" "$TMP" |sort -V |tail -n1
  done

done
