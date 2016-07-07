#!/bin/sh
# 
# Generates RSA private key if none available in @prefix@/etc/ircd.key
# Dumps RSA public key if none available to @prefix@/etc/ircd.pub
# Makes a self-signed certificate in @prefix@/etc/ircd.crt
#
# $Id: mkcrt.in,v 1.1.1.1 2006/09/27 10:08:58 roman Exp $

bits=${2-2048}            # how many bits the RSA private key will have
cnf=/etc/ssl/openssl.cnf  # defaults for x509 and stuff
name=$1                   # certifcate base name
key=$name.key             # private key file
pub=$name.pub             # public key file
crt=$name.crt             # certificate
rnd=/dev/urandom          # random data


# generate RSA private key if not already there
if [ -f "$key" ]; then
  echo "There is already an RSA private key in $key."
else
  # generate key
  openssl genrsa -rand "$rnd" -out "$key" "$bits"
  
  # remove old shit based on inexistent
  rm -f "$pub" "$req" "$crt"
fi

# dump the public key if not present
if [ -f "$pub" ]; then
  echo "There is already an RSA public key in $pub."
else
  openssl rsa -in "$key" -out "$pub" -pubout
fi

# generate certificate
if [ -f "$crt" ]; then
  echo "There is already a certificate in $crt."
else
  openssl req -config "$cnf" -new -x509 -nodes -key "$key" -out "$crt"
  openssl x509 -subject -dates -fingerprint -noout -in "$crt"
fi

