find-all()
{
 (CMD="for_each 'locate32.sh -f -d -i \"\$1\"' \"\$@\""
  CMD="${CMD:+$CMD; }find-media.sh -i \"\$@\""

  SED_EXPR='s,/$,,;s|^A|a|;s|^B|b|;s|^C|c|;s|^D|d|;s|^E|e|;s|^F|f|;s|^G|g|;s|^H|h|;s|^I|i|;s|^J|j|;s|^K|k|;s|^L|l|;s|^M|m|;s|^N|n|;s|^O|o|;s|^P|p|;s|^Q|q|;s|^R|r|;s|^S|s|;s|^T|t|;s|^U|u|;s|^V|v|;s|^W|w|;s|^X|x|;s|^Y|y|;s|^Z|z|'

  FILTER='sed "$SED_EXPR"'
  FILTER="${PATHTOOL:=msyspath} -m | ${FILTER}"
  [ "$PATHTOOL" != msyspath ] && FILTER="xargs -d '\n' $FILTER"

  CMD="($CMD) | $FILTER"
  eval "$CMD"
 )
}
