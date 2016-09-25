#!/bin/bash
total_uninst_decode() {
  ME=${FUNCNAME[0]##*/}; ME=${ME//_/-}.sh; CR=$'\r'; FS="/"; BS="\\"; IFS="$IFS$CR"
 usage() {
 echo "Usage: $ME [OPTIONS] <FILE>
 
  --debug, -x         Show debug messages
  --help, -h          Show this help
  
  --registry-only     Show only registry dump
  --files-only        Show only files list
  
  --no-registry, -R   Don't show registry dump
  --no-files, -F      Don't show files list" 1>&2
 }
  while :; do
    case "$1" in
      --registry-only*) NO_REG=false NO_FILES=true; shift ;;
      --files-only*) NO_FILES=false NO_REG=true; shift ;;
      --registry* | -r) NO_REG=false; shift ;;
      --files* | -f) NO_FILES=false; shift ;;
      --no-files | -F) NO_FILES=true; shift ;;
      --no-registry|-R) NO_REG=true; shift ;;
      --debug | -x) DEBUG=true; shift ;;
       --help | -h) usage ; exit ;;
       *) break ;;
     esac
  done

  if [ -s "$1" ]; then
	exec <"$1"
  fi
  subst_keyroot()
  {
	  case "$1" in
		HKEY_LOCAL_MACHINE*) echo "HKLM${1#HKEY_LOCAL_MACHINE}" ;;
		HKEY_CURRENT_USER*) echo "HKCU${1#HKEY_CURRENT_USER}" ;;
		HKEY_USERS*) echo "HKU${1#HKEY_USERS}" ;;
		*) echo "$1" ;;
	  esac
  }
  while read -r LINE; do
   LINE=${LINE%"$CR"}
	case "$LINE" in
	   *"(FOLDER)"*) FOLDER=${LINE#*"(FOLDER) "}; FOLDER=${FOLDER%"$CR"} ;;
	   *"(FILE)"*) FILE=${LINE#*"(FILE) "}; FILE=${FILE%" = "??.??.????" "??:??", "*" bytes, "*}; FILE=${FILE%"$CR"}
		[ "$NO_FILES" != true ] && echo "$FOLDER\\$FILE"
		 ;;
	  *"(REG KEY)"*) KEY=${LINE#*"(REG KEY) "} ; KEY=${KEY%"$CR"}
	 if [ "$NO_REG" != true ]; then
	  echo
		 echo "[$KEY]"
	fi
	  ;;
	  *"(REG VAL)"*) VAL=${LINE#*"(REG VAL) "}; N=${VAL%%" = REG_"*}; VAL=${VAL#"$N = "}; TYPE=${VAL%%", "*}; VAL=${VAL#"$TYPE, "}; VALUE="$VAL"; NAME="$N"		 
		 case "$NAME" in
			"(Default)") NAME="@" ;;
		 esac
		 K=$(subst_keyroot "$KEY")
		 unset REGVAL
		 case "$TYPE" in
		   REG_SZ) PREFIX=; VALUE=${VALUE//$BS/$BS$BS}
  #           VALUE=${VALUE}
		   ;;
		   REG_DWORD) PREFIX="dword:"; VALUE=${VALUE#\"}; VALUE=${VALUE%\"} ;;
		   REG_MULTI_SZ) PREFIX="hex(7)"; VALUE=${VALUE#\"}; VALUE=${VALUE%\"}; REGVAL="/s , /v \"$VALUE\""; VALUE=$(echo -n "${VALUE}" | iconv -f UTF-8 -t UTF-16  |hexdump -v -e '"" 1/1 "%02x" ","' | ${SED-sed} "s|,$||") ;;
		   REG_EXPAND_SZ) PREFIX="hex(2)"; VALUE=${VALUE#\"}; VALUE=${VALUE%\"}; REGVAL="/d \"${VALUE//"%"/"^%"}\""; VALUE=$(echo -n "${VALUE}" | iconv -f UTF-8 -t UTF-16 |hexdump -v -e '"" 1/1 "%02x" ","' | ${SED-sed} "s|,$||") ;;
		   REG_BINARY) PREFIX="hex"; VALUE=$(echo -n "${VALUE}"  |hexdump -v -e '"" 1/1 "%02x" ","' | ${SED-sed} "s|,$||") ;;
		   *) PREFIX= VALUE=
			echo "Unknown type $TYPE in $NAME @ '$K'" 1>&2 ;;
		 esac
  [ "$DEBUG" = true ] && echo  "\"$K\" \"$NAME\" ($TYPE) = $VAL" 1>&2
  #       echo "\"$NAME\"=${PREFIX:+$PREFIX:}$VALUE"
		  [ "$NAME" = "@" ] && VALUEARG="/ve" ||
		  VALUEARG="/v \"$NAME\""
		  VALUE=${VALUE%"$CR"}
		 : ${REGVAL:="-d \"$VALUE\""}
		[ "$NO_REG" != true ] && echo "reg add \"$K\" $VALUEARG /t $TYPE $REGVAL /f"
	  ;;
	  esac
  done					
}
total_uninst_decode "$@"