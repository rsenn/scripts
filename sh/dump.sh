#!/bin/bash

# set path variable defaults
# ---------------------------------------------------------------------------
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# include library modules
# ---------------------------------------------------------------------------
. $shlibdir/util.sh

# configure the mysql client
# ---------------------------------------------------------------------------
MYSQL_host="digitall.ch"
MYSQL_user="vinylz_magento"
MYSQL_pass="vdf4er"
MYSQL_db="vinylz_magento" 
MYSQL_flags=""

# ---------------------------------------------------------------------------
exec mysqldump \
  --extended-insert=FALSE \
  --quote-names=FALSE \
  -h "$MYSQL_host" \
  -u "$MYSQL_user" \
  -p"$MYSQL_pass" \
  "$MYSQL_db"
