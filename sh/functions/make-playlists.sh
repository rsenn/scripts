make-playlists () 
{ 
 
 VIDEOS=
 DATABASE=$(ls -d --  "$(cygpath -am "$USERPROFILE")"/AppData/*/Locate32/*.dbs | filter-filesize -gt 1k )
 
 msg "Acquiring videos using locate..."
 pushv VIDEOS "$( locate32.sh -c video )"
 
 msg "Acquiring videos using find-media.sh..."
 pushv VIDEOS "$( find-media.sh -c video )"
 
 wc -l <<<"$VIDEOS" 1>&2
 msg "Acquiring videos using find \$(list-mediapath ...)"
 pushv VIDEOS "$( for_each -f 'find "$1" -type f -not -name "*.part"' $(list-mediapath -m {,Downloads/}{Videos/,Porn/} ) | grep-videos.sh )"
 wc -l <<<"$VIDEOS" 1>&2
 
 msg "Merging videos..."
 VIDEOS=$(ls -td -- $(realpath $(sed 's,\r*$,, ; s,\\\+,/,g' <<<"$VIDEOS" |filter-test -e ))   2>/dev/null | sed 's,^/cygdrive,, ; s,^/\(.\)/\(.*\),\1:/\2,' | sort -f -u | filter-filesize -ge 15M)
 
 set -- $VIDEOS
 msg "Acquired $# videos."
 
 split_results() {
   L="videos-by-$NAME.list"; grep -vi porn/ <<<"$R" >"$L";   N=$(wc -l <"$L")
  msg "Wrote $N entries to $L."
  L="porn-by-$NAME.list"; grep -i porn/ <<<"$R" >"$L";   N=$(wc -l <"$L")
  msg "Wrote $N entries to $L."
 }
 write_playlist() {
    for LL in videos porn; do
      LN=$LL-by-$NAME
      msg "Writing $LN.m3u"
    eval 'make-m3u.sh $(<'$LN'.list) |sed "s|/|\\\\|g ; s|\\r*\$|\\r|" >'$LN'.m3u'
   done
    
    
 }
 for CMD in "ls -"{t,S}"d --"; do
   case "$CMD" in
   *-S*) NAME=size ;;
   *-t*) NAME=time ;;
   esac
   eval 'R=$('$CMD' "$@" 2>/dev/null)'
   
   split_results
   
   write_playlist
   
 done
 
for CMD in \
  "duration -m" \
  "duration" \
  "bitrate" \
  "resolution"; do
  NAME=${CMD//" "/""}
  OUT=$NAME.tmp
  EVAL="$CMD \"\$@\" >$OUT"
  msg "Executing: $EVAL"
  eval "$EVAL"
  
  R=$(sort -r -nk3 -t: "$OUT" | grep -v ":[0-4]\$" | cut -d: -f 1,2)
  
split_results
  write_playlist
done

}
 
