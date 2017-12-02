ffcropdetect() {
  ${FFPLAY-ffplay} ${@+-i} ${@+"$@"} -vf cropdetect=24:16:0  -an 2>&1 |grep -iE  '(error|cropdetect)'
}

