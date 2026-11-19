#!/bin/zsh
# Writes signing/upload-cert.pem: the certificate (public, not secret) of the
# password-derived upload key, to upload in Play Console for an upload key reset.
set -euo pipefail
cd "${0:A:h}/.."
export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
EXPECTED=signing/upload-cert.sha256

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
store=$(openssl rand -hex 16)

read -rs "pw?Eland key password: "; echo
echo "Deriving the key (a few seconds)…"
fp=$(print -r -- "$pw" | "$JAVA_HOME/bin/java" signing/DeriveUploadKey.java "$tmp/upload.p12" "$store")
unset pw
if [[ -f $EXPECTED && "$fp" != "$(<$EXPECTED)" ]]; then
  echo "Wrong password: the fingerprint is not the recorded one."; exit 1
fi

"$JAVA_HOME/bin/keytool" -exportcert -rfc -alias upload \
  -keystore "$tmp/upload.p12" -storetype PKCS12 -storepass "$store" \
  -file signing/upload-cert.pem 2>/dev/null
echo "Certificate: signing/upload-cert.pem"
echo "SHA-256:     $fp"
