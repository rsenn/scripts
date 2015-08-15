#!/bin/bash
#
# mysql-functions.sh: Functions wrapping the Msql builtin.
#
# $Id: mysql.in 686 2007-04-18 21:31:53Z  $
# ----------------------------------------------------------------------------

if test "$(type -t Msql)" != builtin && 
 ! enable -f /usr/lib/bash/mysql.so Msql
then
  echo "Failed to enable the bash-builtin module mysql.so" 1>&2
  exit 1
fi

# ----------------------------------------------------------------------------
mysql_askpass()
{
  if test "${mysql_pass+set}" != set; then
    read -p"Password: " mysql_pass
  fi
}

# mysql_query [options] <query>
# ----------------------------------------------------------------------------
mysql_query()
{
  mysql_askpass

  Msql \
  -f -e \
      -h "$mysql_server" \
      ${mysql_port:+-p "$mysql_port"} \
      -d "$mysql_database" \
      -u "$mysql_user" \
      -P "$mysql_pass" \
    "$@"
}

# mysql_query <query>
# ----------------------------------------------------------------------------
mysql_query2()
{
  mysql_askpass

  echo "$@" |
  mysql \
      -h "$mysql_server" \
      ${mysql_port:+-P "$mysql_port"} \
      -u "$mysql_user" \
      -p"$mysql_pass" 
      "$mysql_database"
}

# mysql_tables [-a variable-name]
# 
# Outputs the list of tables
# ----------------------------------------------------------------------------
mysql_tables()
{
  mysql_query "$@" "SHOW TABLES"
}

# mysql_fields [-a variable-name] <table>
# 
# Shows the fields of the specified table.
# ----------------------------------------------------------------------------
mysql_fields()
{
  local o=  

  while test "$#" -gt 1
  do
    o="${o:+$o${IFS:0:1}}$1"
    shift
  done

  mysql_query $o "SHOW FIELDS FROM $1"
}

# mysql_field_names <table>
# 
# Shows the field names of the specified table.
# ----------------------------------------------------------------------------
mysql_field_names()
{
  local a= f i

  case $1 in
    -a) a="$2" && shift 2 ;;
    -a*) a="${1#-a}" && shift ;;
  esac

  mysql_fields -a "f" "$@"
  
  for (( i = 0; i < ${#f[@]}; i += 6 ))
  do
    if test -n "$a"; then
      eval "$a+=${f[i]}"
    else
      echo "${f[i]}"
    fi
  done
}
