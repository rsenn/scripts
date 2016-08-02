#!/bin/bash
NL="
"

. require.sh
require archive

grep_e-expr()
{ 
    echo "($(IFS="|
         $IFS";  set -- $*; echo "$*"))"
}

grep_e()
{ 
    ( unset ARGS;
    eval "LAST=\"\${$#}\"";
    if [ ! -d "$LAST" ]; then
        unset LAST;
    else
        A="$*";
        A="${A%$LAST}";
        set -- $A;
    fi;
    while :; do
        case "$1" in 
            -*)
                ARGS="${ARGS+$ARGS
	}$1";
                shift
            ;;
            *)z
                break
            ;;
        esac;
    done;
    ${GREP-grep
-a
--line-buffered
--color=auto} -E $ARGS "$(grep_e-expr "$@")" ${LAST:+"$LAST"} )
}

grep_e-expr()
{ 
    echo "($(IFS="|
	 $IFS";  set -- $*; echo "$*"))"
}

archiver_cfg()
{
  if [ -n "$ARCHIVE" -a -e "$ARCHIVE" ]; then
    EXISTS=true
  else
  EXISTS=false
  fi

	case "${ARCHIVE##*.}" in
		 rar)  ACMD="rar"  AFLAGS="-m0 -y" ;;
		 7z)  ACMD="7za"  AFLAGS="-mx=0" ;;
		 zip)  ACMD="zip"  AFLAGS="-0 -y" ;;
		 tar*)  ACMD="tar" AFLAGS="-f" ;;
	esac  


	case "$EXISTS" in
		 true) case "${ARCHIVE##*.}" in
						 7z|rar) AFLAGS="u $AFLAGS" ;;
						 zip|tar) AFLAGS="-u $AFLAGS" ;;
					 esac
					 ;;
		 *) case "${ARCHIVE##*.}" in
						 7z|rar) AFLAGS="a $AFLAGS" ;;
						 tar) AFLAGS="-c $AFLAGS" ;;
						 zip) ;;
					 esac
	;;
	esac
}

main()
{

	while :;  do
		case "$1" in
			-u) UPDATE=true; shift ;;
			*) break ;;
		esac
done

  
  [ -z "$ARCHIVE" ] &&   {
  : ${AEXT="zip"}
  ARCHIVE="${1:-slackpkgs-$(date +%Y%m%d).$AEXT}"
}  

 ARCHIVE=` realpath "$ARCHIVE"` 
	if [ "$UPDATE" = true ]; then
		 ACTION="Updating"
	else
		 ACTION="Creating"
	fi

	echo "$ACTION archive $ARCHIVE ..." 1>&2

	if [ "$UPDATE" = true ]; then
		 
    PKGS=$(if [ -s "$ARCHIVE" ] ; then archive_list "$ARCHIVE"; fi);  set --  $PKGS; PKG_COUNT=$#
      [ $PKG_COUNT -gt 0 ] &&
        echo "$PKG_COUNT packages already in archive $ARCHIVE ..." 1>&2
     FILTER_EXPR=$(grep_e-expr $PKGS)
	else
		test -e "$ARCHIVE" && rm -vf "$ARCHIVE" 
	fi

  if [ -e "$ARCHIVE" ]; then
    EXISTS=true
	else

  case "$ARCHIVE":"$EXISTS" in
     *.zip:*)  ACMD="zip" 
               case "$ARCHIVE":"$EXISTS" in
                  true) AFLAGS="$AFLAGS -u" ;;
                  *) ;;
               esac
               ;;
     *.tar*:*)  ACMD="tar"
                 case "$ARCHIVE":"$EXISTS" in
                  true) AFLAGS="$AFLAGS -u" ;;
                  *) AFLAGS="$AFLAGS -c" ;;
               esac
                ;;
  esac  
}


main()
{

	while :;  do
		case "$1" in
			-u) UPDATE=true; shift ;;
			*) break ;;
		esac
done

	ARCHIVE="$PWD/slackpkgs-$(date "+%Y%m%d").zip"
ARGS="$@"

if [ "$UPDATE" = true ]; then
   ACTION="Updating"
else
   ACTION="Creating"
fi

echo "$ACTION archive $ARCHIVE ..." 1>&2

	if [ "$UPDATE" = true ]; then
		 
    PKGS=$(if [ -s "$ARCHIVE" ] ; then archive_list "$ARCHIVE"; fi);  set --  $PKGS; PKG_COUNT=$#
      [ $PKG_COUNT -gt 0 ] &&
        echo "$PKG_COUNT packages already in archive $ARCHIVE ..." 1>&2
     FILTER_EXPR=$(grep_e-expr $PKGS)
	else
		test -e "$ARCHIVE" && rm -vf "$ARCHIVE" 
	fi

  if [ -e "$ARCHIVE" ]; then
    EXISTS=true
	else 
		EXISTS=false
  fi  
  archiver_cfg



	PACKAGES=$( find /m*/*/pmagic -name "*.t?z" )
  set -- $PACKAGES; PACKAGE_COUNT=$#
 
  echo "Found $PACKAGE_COUNT slackware package files" 1>&2
 
 PACKAGE_FILES=$(${SED-sed} -u "s,.*/,," <<<"$PACKAGES" |sort -fu); set -- $PACKAGE_FILES ; PACKAGE_FILES_COUNT=$#

  echo "Found $PACKAGE_FILES_COUNT different slackware packages" 1>&2

  if [ "$EXISTS" = true -a -n "$PKGS" ]; then
    FILTER_EXPR="^$(grep_e-expr $PKGS)\$"
    set -- $(grep -v -E "$FILTER_EXPR" <<<"$*")
	fi

PACKAGES_NEW="$*" 
  PACKAGES_NEW_COUNT="$#"

	if [ $PACKAGE_FILES_COUNT -gt 0 ]; then
 
		echo "$PACKAGE_FILES_COUNT packages total" 1>&2

	 if [ "$PACKAGES_NEW_COUNT" != "$PACKAGE_FILES_COUNT" ]; then
		 echo "$((PACKAGE_FILES_COUNT - PACKAGES_NEW_COUNT)) packages already in $ARCHIVE" 1>&2
		fi 
		 echo "$PACKAGES_NEW_COUNT packages to be added" 1>&2
	fi

  for PKG 
	 do    
	(	 FILES=$(ls -Sd $(grep "/${PKG}\$"  <<<"$PACKAGES") ) 
     set -- $FILES
     DIR=$(dirname "$1")
		 BASE=$(basename "$1")
		 (cd "$DIR"
		   (set -x;  $ACMD $AFLAGS "$ARCHIVE" "$BASE")
		 ) || exit 1
) || break
    if [ -e "$ARCHIVE" -a -s "$ARCHIVE" ]; then
   echo "Reconfiguring archiver..." 1>&2
  
     archiver_cfg
    fi
	 done
} 

main "$@"

