#!/bin/bash
export BASE_DIR=$1
export DOMAIN_NAME=$2
export COMMON_NAME=$3

cat <<EOF> ${BASE_DIR}/openssl-san.config
[ req ]
distinguished_name = req
[ san ]
subjectAltName = DNS:*.${COMMON_NAME}
EOF


openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 \
-subj "/O=Example Inc./CN=${DOMAIN_NAME}" \
-keyout $BASE_DIR/root.key \
-out $BASE_DIR/root.crt

openssl req -new -keyout $BASE_DIR/wildcard.key -out $BASE_DIR/wildcard.csr \
-sha256 -nodes \
-subj "/CN=${DOMAIN_NAME}/O=Example Inc." \
-config ${BASE_DIR}/openssl-san.config

openssl x509 -req -in $BASE_DIR/wildcard.csr -CA $BASE_DIR/root.crt \
-CAkey $BASE_DIR/root.key -CAcreateserial \
-out $BASE_DIR/wildcard.crt \
-days 3560 -sha256 \
-extfile ${BASE_DIR}/openssl-san.config -extensions san

openssl x509 -in ${BASE_DIR}/wildcard.crt -text
