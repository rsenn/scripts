yaourt-joinlines() {
 (P_VERSION=' ${VERSION}' P_NUM= P_STATE= P_DESC=' - ${DESC}'
  while :; do
   case "$1" in
    -i | --installed) P_INSTALLED=yes ;;
    -I | --not-installed) P_INSTALLED=no ;;
    -n | --num*) P_NUM='${NUM:+ $NUM}' ;;
    -s | --state) P_STATE='${STATE:+ $STATE}' ;;
    -R | --no-repository) R_REPOSITORY='#*/' ;;
    -V | --no-version) P_VERSION= ;;
    -D | --no*desc*) P_DESC= ;;
    *) break ;;
    esac
    shift
  done
	rep() { N=$1; shift ; C="$*"; O=; while [ $((N)) -gt 0 ]; do O="${O}$C";  : $((--N)); done; echo "$O"; }
	pad() { W=$1; shift; S=$*; P=$(rep $(($W-${#S})) " "); echo "${S}${P}"; }
    DESC= INSTALLED=
		P_NAME='${NAME'$R_REPOSITORY'}'

		P_NAME='$(pad 32 "'$P_NAME'")'; [ -n "$P_VERSION" ] && P_VERSION=' $(pad 20'$P_VERSION')'

    P_CMD='if [ -n "$DESC"'${P_INSTALLED:+' -a "$P_INSTALLED" = "$INSTALLED"'}' ]; then
        echo "'$P_NAME$P_VERSION$P_STATE$P_NUM$P_DESC'"
      fi'
    eval "p() { $P_CMD; }"
    while read -r LINE; do
    case "$LINE" in
      "   "*) 
				[ "$DEBUG" = true ] && echo "DESC=\"\$DESC    ${LINE#    }\"" 1>&2
				DESC="${DESC:+$DESC - }${LINE#    }" ;;
      *)
        p
        DESC="${LINE}"

				NAME=${DESC%%" "*}; DESC=${DESC#"$NAME "}
				VERSION=${DESC%%" "*}; DESC=${DESC#*"$VERSION "}

				STATE= NUM=
				while :; do
					case "$DESC" in
						"["*"]"*) STATE=${DESC%%"]"*}"]"; DESC=${DESC#*"]"} ;;
						"("*")"*) NUM=${DESC%%")"*}")"; DESC=${DESC#*")"} ;;
						*) break ;;
					esac
					DESC=${DESC#" "}
				done

				case "$STATE" in
				  *installed*) INSTALLED=yes ;;
					*) INSTALLED=no ;;
			  esac

        ;;
    esac
  done
  p)
}
