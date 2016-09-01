#!/bin/sh
# 
# Generates RSA private key if none available in @prefix@/etc/ircd.key
# Dumps RSA public key if none available to @prefix@/etc/ircd.pub
#
# $Id: mkkeys.in,v 1.1.1.1 2006/09/27 10:08:58 roman Exp $

# ircd install prefix
prefix="@prefix@"
exec_prefix="@exec_prefix@"
sbindir="@sbindir@"
sysconfdir="@sysconfdir@"

# how many bits the RSA private key will have
bits=${2-2048}

# certifcate base name
name="${1-$sysconfdir/ircd}"

# defaults for x509 and stuff
cnf="$sbindir/openssl.cnf"

# private key file
key="$name.key"

# public key file
pub="$name.pub"

# random data
rnd="$sysconfdir/openssl.rnd"

# generate RSA private key if not already there
if [ -f "$key" ]
then
  echo "There is already an RSA private key in $key."
else
  # dump random data
  dd if=/dev/urandom "of=$rnd" count=1 "bs=$bits"

  # generate key
  openssl genrsa -rand "$rnd" -out "$key" "$bits"
  
  # remove old shit based on inexistent
  rm -f "$pub" "$req" "$crt"
  
  # destroy random data
  shred "$rnd"
  rm "$rnd"
fi

# dump the public key if not present
if [ -f "$pub" ]
then
  echo "There is already an RSA public key in $pub."
else
  openssl rsa -in "$key" -out "$pub" -pubout
fi
