cut-ver()
{
  cat "$@" | cut-trailver |
  sed 's,[-.]rc[[:alnum:]~][^-.]*,,g ;; s,[-.]b[[:alnum:]~][^-.]*,,g ;; s,[-.]git[_[:alnum:]~][^-.]*,,g ;; s,[-.]svn[_[:alnum:]~][^-.]*,,g ;; s,[-.]linux[^-.]*,,g ;; s,[-.]v[[:alnum:]~][^-.]*,,g ;; s,[-.]beta[_[:alnum:]~][^-.]*,,g ;; s,[-.]alpha[_[:alnum:]~][^-.]*,,g ;; s,[-.]a[_[:alnum:]~][^-.]*,,g ;; s,[-.]trunk[^-.]*,,g ;; s,[-.]release[_[:alnum:]~][^-.]*,,g ;; s,[-.]GIT[^-.]*,,g ;; s,[-.]SVN[^-.]*,,g ;; s,[-.]r[_[:alnum:]~][^-.]*,,g ;; s,[-.]dnh[_[:alnum:]~][^-.]*,,g' |
  sed 's,[^-.]*git[_0-9][^.].,,g ;; s,[^-.]*svn[_0-9][^.].,,g ;; s,[^-.]*GIT[^.].,,g ;; s,[^-.]*SVN[^.].,,g' |
  sed 's,\.\(P\)\?[[:digit:]][_+[:digit:]]*\.,.,g' |
  sed 's,-\([0-9]\+\):\([0-9]\+\),-\1.\2,' | 
  sed 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]][_+[:alnum:]~]*\([-.]\),\1,g'|
  sed 's,[-_.][[:digit:]]*\(svn\)\?\(git\)\?\(P\)\?\(rc\)\?[[:digit:]][_+[:digit:]]*\(-.\),\5,g' |
  sed 's,-[[:digit:]][._+[:digit:]]*$,, ;;  s,-[[:digit:]][._+[:digit:]]*$,,'  |
  sed 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]]*\(rc[[:digit:]]\)\?\(b[[:digit:]]\)\?\(git[_0-9]\)\?\(svn[_0-9]\)\?\(linux\)\?\(v[[:digit:]]\)\?\(beta[_0-9]\)\?\(alpha[_0-9]\)\?\(a[_0-9]\)\?\(trunk\)\?\(release[_0-9]\)\?\(GIT\)\?\(SVN\)\?\(r[_0-9]\)\?\(dnh[_0-9]\)\?[[:digit:]][_+[:alnum:]~]*\.,.,g' |
  sed 's,\.[[:digit:]][^.]*\.,.,g'

}
