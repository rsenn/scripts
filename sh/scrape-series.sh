#!/bin/sh


while read -r URL; do

  NAME=${URL#*/serie/}
  NAME=${NAME%%/*}
  NAME=${NAME%-Die-*}
  NAME=${NAME%-Der-*}
  NAME=${NAME#The-}
  NAME=${NAME#D[iea][ers]-}
  FULLNAME=$NAME

  NAME=${NAME//-/}
  SHORTNAME=$(echo "$NAME" | tr [[:{upper,lower}:]])

  echo "FULLNAME: $FULLNAME"
  echo "SHORTNAME: $SHORTNAME"

  SEASONS=`(set -x; dlynx.sh "$URL") | sed -n "\\,$URL/[0-9], { s|^$URL/||; s|/.*||;  p }" | sort -u -n`

  echo "SEASONS: $SEASONS"
  EXPAND="dlynx.sh $URL/{$(set -- $SEASONS; IFS=","; echo "$*")} | grep \"\$URL/[0-9]\\+/\""
 
  eval "$EXPAND" | grep -vE '/(en$|en/|de$)' | sort -fuV | tee "$SHORTNAME-urls.tmp"

  cat >"$SHORTNAME-rename.sh" <<__EOF__
${SHORTNAME}-rename() {
 (while read URL; do
    [ -z "\$NAME" ] && {
      NAME=\${URL##*/serie/}
      NAME=\${NAME%%/*}
      NAME=\${NAME//"-"/" "}
    }
    SEASON=\${URL#*/serie/*/}
    SEASON=\${SEASON%%/*}
    EPISODE=\${URL#*/serie/*/*/}
    EPISODE=\${EPISODE%%[-/]*}
    TITLE=\${URL#*/serie/*/*/\$EPISODE-}
    TITLE=\${TITLE%%/*}
    TITLE=\${TITLE//-/ }
    EXPR=\$(printf "(S%02dE%02d)" "\$SEASON" "\$EPISODE" #"\${TITLE//[![:alnum:]]/.*}"
    )
    F=\$(grep -iE "\$EXPR" ${SHORTNAME}-videos.tmp | head -n1)
    FILENAME=\$(printf "%s - S%02dE%02d - %s\n" "\$NAME" "\$SEASON" "\$EPISODE" "\$TITLE").mp4
    test -f "\$F" -a "\$F" != "\$FILENAME"  &&
    echo "mv -vf -- '\$F' '\$FILENAME'"
  done <${SHORTNAME}-urls.tmp)
}
__EOF__

done <urls.txt
