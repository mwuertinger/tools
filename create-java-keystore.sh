#!/bin/sh

set -e

if [ $# -ne 1 ]
then
  echo "This tool reads a certificate and a private key in PEM format and converts them" >&2
  echo "into a Java Key Store (JKS) file." >&2
  echo "More specifically this script reads \$NAME.key and \$NAME.crt and creates" >&2
  echo "\$NAME.pkcs12 and the end product: \$NAME.jks." >&2
  echo "" >&2
  echo "This tool sets a static password for the JKS file which is defined in the \$PW" >&2
  echo "variable. See source code for details." >&2
  echo "" >&2
  echo "Usage: $0 <NAME>" >&2
  echo "" >&2
  exit 1
fi

NAME=$1

CRT=${NAME}.crt
KEY=${NAME}.key
PKCS12=${NAME}.pkcs12
JKS=${NAME}.jks

echo "Source:" >&2
echo "  $CRT" >&2
echo "  $KEY" >&2
echo "Output:" >&2
echo "  $PKCS12" >&2
echo "  $JKS" >&2
echo "" >&2

# The static password. If you require a strong password you should change it.
PW=123456

if [ ! -f $CRT  ]
then
  echo "Error: The input file $CRT does not exist." >&2
  exit 2
fi

if [ ! -f $KEY  ]
then
  echo "Error: The input file $KEY does not exist." >&2
  exit 2
fi

if [ -e $PKCS12 ]
then
  echo "Error: $PKCS12 already exists. You need to delete it manually before proceeding." >&2
  exit 3
fi

if [ -e $JKS ]
then
  echo "Error: $JKS already exists. You need to delete it manually before proceeding." >&2
  exit 4
fi

echo "Creating PKCS12..." >&2
openssl pkcs12 -export -passout pass:$PW -out $PKCS12 -inkey $KEY -in $CRT
echo "Creating JKS..." >&2
keytool -importkeystore -srckeystore $PKCS12 -srcstoretype pkcs12 -destkeystore $JKS -deststoretype jks -storepass $PW -keypass $PW -srcstorepass $PW
