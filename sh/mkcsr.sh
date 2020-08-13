#!/bin/sh
# 
# Generates RSA private key if none available in @shlibprefix@/etc/ircd.key
# Dumps RSA public key if none available to @shlibprefix@/etc/ircd.pub
# Makes certificate request in @shlibprefix@/etc/ircd.req
#
# The request and the public key file are passed to the CA which
# will return a signed certificate.
#
# $Id: mkreq.in,v 1.1.1.1 2006/09/27 10:08:58 roman Exp $

bits=${2-2048}            # how many bits the RSA private key will have
cnf=/etc/ssl/openssl.cnf  # defaults for x509 and stuff
name=$1                   # certifcate base name
key=$name.key             # private key file
pub=$name.pub             # public key file
req=$name.csr             # certificate signing request
#rnd=/dev/urandom          # random data

# generate RSA private key if not already there
if [ -f "$key" ]; then
  echo "There is already an RSA private key in $key."
else
  # generate key
  openssl genrsa ${rnd+-rand "$rnd"} -out "$key" "$bits"
  
  # remove old shit based on inexistent
  rm -f "$pub" "$req" "$crt"
  
  # destroy random data
  #rhred "$rnd"
  #rm "$rnd"
fi

# dump the public key if not present
if [ -f "$pub" ]
then
  echo "There is already an RSA public key in $pub."
else
  openssl rsa -in "$key" -out "$pub" -pubout
fi

# generate certificate request
if [ -f "$req" ]; then
  echo "There is already a request in $req."
else
  openssl req -config "$cnf" -new -nodes -key "$key" -out "$req"
fi

