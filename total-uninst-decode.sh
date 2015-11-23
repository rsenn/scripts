#!/bin/bash

FS="/"
BS="\\"
DEBUG=true

if [ -s "$1" ]; then
  exec <"$1"
fi

subst_keyroot()
{
	case "$1" in
	  HKEY_LOCAL_MACHINE*) echo "HKLM${1#HKEY_LOCAL_MACHINE}" ;;
	  HKEY_CURRENT_USER*) echo "HKCU${1#HKEY_CURRENT_USER}" ;;
	esac
}

while read -r LINE; do

  case "$LINE" in
     *"(FOLDER)"*) FOLDER=${LINE#*"(FOLDER) "} ;;
     *"(FILE)"*)
       FILE=${LINE#*"(FILE) "} 
       FILE=${FILE%" = "??.??.????" "??:??", "*" bytes, "*}
       
       echo "$FOLDER\\$FILE"
       
       ;;
       
    *"(REG KEY)"*) KEY=${LINE#*"(REG KEY) "} 
    echo
       echo "[$KEY]"
    ;;
    *"(REG VAL)"*)
       VAL=${LINE#*"(REG VAL) "}
       
       N=${VAL%%" = REG_"*}
       VAL=${VAL#"$N = "}
       TYPE=${VAL%%", "*}
       
       VAL=${VAL#"$TYPE, "}
       
       VALUE="$VAL"
       NAME="$N"
       

       case "$NAME" in
          "(Default)") NAME="@" ;;
       esac
       
       K=$(subst_keyroot "$KEY")
       unset REGVAL
       
       case "$TYPE" in
         REG_SZ) 
           PREFIX=
           VALUE=${VALUE//$BS/$BS$BS}
#           VALUE=${VALUE}
         ;;
         REG_DWORD)
           PREFIX="dword:"
           VALUE=${VALUE#\"}
           VALUE=${VALUE%\"}
         ;;
         REG_MULTI_SZ)
           PREFIX="hex(7)"
           VALUE=${VALUE#\"}
           VALUE=${VALUE%\"}
           REGVAL="/s , /v \"$VALUE\""
           VALUE=$(echo -n "${VALUE}" | iconv -f UTF-8 -t UTF-16  |hexdump -v -e '"" 1/1 "%02x" ","' | sed "s|,$||")
           
         ;;
         REG_EXPAND_SZ)
           PREFIX="hex(2)"
           VALUE=${VALUE#\"}
           VALUE=${VALUE%\"}
           REGVAL="/d \"${VALUE//"%"/"^%"}\""
           VALUE=$(echo -n "${VALUE}" | iconv -f UTF-8 -t UTF-16 |hexdump -v -e '"" 1/1 "%02x" ","' | sed "s|,$||")
         ;;
         REG_BINARY)
           PREFIX="hex"
           VALUE=$(echo -n "${VALUE}"  |hexdump -v -e '"" 1/1 "%02x" ","' | sed "s|,$||")
           
         ;;
         *) 
          PREFIX= VALUE=
          echo "Unknown type $TYPE in $NAME @ '$K'" 1>&2 ;;
       esac
[ "$DEBUG" = true ] && echo  "\"$K\" \"$NAME\" ($TYPE) = $VAL" 1>&2
       
#       echo "\"$NAME\"=${PREFIX:+$PREFIX:}$VALUE"
        
        [ "$NAME" = "@" ] && VALUEARG="/ve" ||
        VALUEARG="/v \"$NAME\""

       : ${REGVAL:="-d \"$VALUE\""}
       echo "reg add \"$K\" $VALUEARG /t $TYPE $REGVAL /f"
    ;;
    esac
done					