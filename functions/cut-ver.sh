cut-ver()
{
  cat "$@" | cut-trailver |
  ${SED-sed} 's,[-.]rc[[:alnum:]~][^-.]*,,g ;; s,[-.]b[[:alnum:]~][^-.]*,,g ;; s,[-.]git[_[:alnum:]~][^-.]*,,g ;; s,[-.]svn[_[:alnum:]~][^-.]*,,g ;; s,[-.]linux[^-.]*,,g ;; s,[-.]v[[:alnum:]~][^-.]*,,g ;; s,[-.]beta[_[:alnum:]~][^-.]*,,g ;; s,[-.]alpha[_[:alnum:]~][^-.]*,,g ;; s,[-.]a[_[:alnum:]~][^-.]*,,g ;; s,[-.]trunk[^-.]*,,g ;; s,[-.]release[_[:alnum:]~][^-.]*,,g ;; s,[-.]GIT[^-.]*,,g ;; s,[-.]SVN[^-.]*,,g ;; s,[-.]r[_[:alnum:]~][^-.]*,,g ;; s,[-.]dnh[_[:alnum:]~][^-.]*,,g' |
  ${SED-sed} 's,[^-.]*git[_0-9][^.].,,g ;; s,[^-.]*svn[_0-9][^.].,,g ;; s,[^-.]*GIT[^.].,,g ;; s,[^-.]*SVN[^.].,,g' |
  ${SED-sed} 's,\.\(P\)\?[[:digit:]][_+[:digit:]]*\.,.,g' |
  ${SED-sed} 's,-\([0-9]\+\):\([0-9]\+\),-\1.\2,' |
  ${SED-sed} 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]][_+[:alnum:]~]*\([-.]\),\1,g'|
  ${SED-sed} 's,[-_.][[:digit:]]*\(svn\)\?\(git\)\?\(P\)\?\(rc\)\?[[:digit:]][_+[:digit:]]*\(-.\),\5,g' |
  ${SED-sed} 's,-[[:digit:]][._+[:digit:]]*$,, ;;  s,-[[:digit:]][._+[:digit:]]*$,,'  |
  ${SED-sed} 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]]*\(rc[[:digit:]]\)\?\(b[[:digit:]]\)\?\(git[_0-9]\)\?\(svn[_0-9]\)\?\(linux\)\?\(v[[:digit:]]\)\?\(beta[_0-9]\)\?\(alpha[_0-9]\)\?\(a[_0-9]\)\?\(trunk\)\?\(release[_0-9]\)\?\(GIT\)\?\(SVN\)\?\(r[_0-9]\)\?\(dnh[_0-9]\)\?[[:digit:]][_+[:alnum:]~]*\.,.,g' |
  ${SED-sed} 's,\.[[:digit:]][^.]*\.,.,g'

}
