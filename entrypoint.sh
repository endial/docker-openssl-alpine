#!/bin/sh
# docker entrypoint script
# generate three tier certificate chain

echo "[i] Start OpenSSL, cert file save path: $CERT_DIR"
SUBJ="/C=$COUNTY/ST=$STATE/L=$LOCATION/O=$ORGANISATION"

if [ ! -d $CERT_DIR ]; then
  echo "[i] Make directory: $CERT_DIR"
  mkdir -p "$CERT_DIR"
fi

if [ ! -f "$CERT_DIR/$ROOT_NAME.crt" ]
then
  echo "[i] Generate $ROOT_NAME.crt"

  # generate root certificate
  ROOT_SUBJ="$SUBJ/CN=$ROOT_CN"

  openssl genrsa \
    -out "$ROOT_NAME.key" \
    "$RSA_KEY_NUMBITS"

  openssl req \
    -new \
    -key "$ROOT_NAME.key" \
    -out "$ROOT_NAME.csr" \
    -subj "$ROOT_SUBJ"

  openssl req \
    -x509 \
    -key "$ROOT_NAME.key" \
    -in "$ROOT_NAME.csr" \
    -out "$ROOT_NAME.crt" \
    -days "$DAYS" \
    -subj "$ROOT_SUBJ"

  # copy certificate to volume
  cp "$ROOT_NAME.crt" "$CERT_DIR"
fi

if [ ! -f "$CERT_DIR/$ISSUER_NAME.crt" ]
then
  echo "[i] Generate $ISSUER_NAME.crt"
  # generate issuer certificate
  ISSUER_SUBJ="$SUBJ/CN=$ISSUER_CN"

  openssl genrsa \
    -out "$ISSUER_NAME.key" \
    "$RSA_KEY_NUMBITS"

  openssl req \
    -new \
    -key "$ISSUER_NAME.key" \
    -out "$ISSUER_NAME.csr" \
    -subj "$ISSUER_SUBJ"

  openssl x509 \
    -req \
    -in "$ISSUER_NAME.csr" \
    -CA "$ROOT_NAME.crt" \
    -CAkey "$ROOT_NAME.key" \
    -out "$ISSUER_NAME.crt" \
    -CAcreateserial \
    -extfile issuer.ext \
    -days "$DAYS"

  # copy certificate to volume
  cp "$ISSUER_NAME.crt" "$CERT_DIR"
fi

if [ ! -f "$CERT_DIR/$PUBLIC_NAME.key" ]
then
  echo "[i] Generate $PUBLIC_NAME.key"
  # generate public rsa key
  openssl genrsa \
    -out "$PUBLIC_NAME.key" \
    "$RSA_KEY_NUMBITS"

  # copy public rsa key to volume
  cp "$PUBLIC_NAME.key" "$CERT_DIR"
fi

if [ ! -f "$CERT_DIR/$PUBLIC_NAME.crt" ]
then
  echo "[i] Generate $PUBLIC_NAME.crt"
  # generate public certificate
  PUBLIC_SUBJ="$SUBJ/CN=$PUBLIC_CN"
  openssl req \
    -new \
    -key "$PUBLIC_NAME.key" \
    -out "$PUBLIC_NAME.csr" \
    -subj "$PUBLIC_SUBJ"

  openssl x509 \
    -req \
    -in "$PUBLIC_NAME.csr" \
    -CA "$ISSUER_NAME.crt" \
    -CAkey "$ISSUER_NAME.key" \
    -out "$PUBLIC_NAME.crt" \
    -CAcreateserial \
    -extfile public.ext \
    -days "$DAYS"

  # copy certificate to volume
  cp "$PUBLIC_NAME.crt" "$CERT_DIR"
fi

if [ ! -f "$CERT_DIR/ca.pem" ]
then
  echo "[i] Make combined root and issuer ca.pem"
  # make combined root and issuer ca.pem
  cat "$CERT_DIR/$ISSUER_NAME.crt" "$CERT_DIR/$ROOT_NAME.crt" > "$CERT_DIR/ca.pem"
fi

echo "[i] Generate Let\'s Encrypt like files"
mkdir -p "$CERT_DIR/letsencrypt"
cat "$CERT_DIR/$PUBLIC_NAME.key" > "$CERT_DIR/letsencrypt/privkey.pem"
cat "$CERT_DIR/$PUBLIC_NAME.crt" "$CERT_DIR/ca.pem" > "$CERT_DIR/letsencrypt/fullchain.pem"
cat "$CERT_DIR/ca.pem" > "$CERT_DIR/letsencrypt/chain.pem"
cat "$CERT_DIR/$PUBLIC_NAME.crt" > "$CERT_DIR/letsencrypt/cert.pem"

echo "This directory contains your keys and certificates." > "$CERT_DIR/letsencrypt/README"
echo "" >> "$CERT_DIR/letsencrypt/README"
echo "\`privkey.pem\`  : the private key for your certificate." >> "$CERT_DIR/letsencrypt/README"
echo "\`fullchain.pem\`: the certificate file used in most server software." >> "$CERT_DIR/letsencrypt/README"
echo "\`chain.pem\`    : used for OCSP stapling in Nginx >=1.3.7." >> "$CERT_DIR/letsencrypt/README"
echo "\`cert.pem\`     : will break many server configurations, and should not be used" >> "$CERT_DIR/letsencrypt/README"
echo "                 without reading further documentation (see link below)." >> "$CERT_DIR/letsencrypt/README"
echo "" >> "$CERT_DIR/letsencrypt/README"

# run command passed to docker run
exec "$@"
