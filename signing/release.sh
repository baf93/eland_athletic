#!/bin/zsh
# Signed build for Play: asks for the password, derives the upload key into a temp folder,
# builds the AAB (and an APK to try), then deletes the key. Nothing is left on disk.
#   signing/release.sh   → build/app/outputs/bundle/userAppRelease/*.aab (+ apk)
set -euo pipefail
cd "${0:A:h}/.."
export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
EXPECTED=signing/upload-cert.sha256

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
store=$(openssl rand -hex 16)

read -rs "pw?Eland key password: "; echo
if [[ ! -f $EXPECTED ]]; then
  read -rs "pw2?Repeat it (first time): "; echo
  [[ "$pw" == "$pw2" ]] || { echo "They don't match."; exit 1; }
  unset pw2
fi
echo "Deriving the key (a few seconds)…"
fp=$(print -r -- "$pw" | "$JAVA_HOME/bin/java" signing/DeriveUploadKey.java "$tmp/upload.p12" "$store")
unset pw

if [[ -f $EXPECTED ]]; then
  [[ "$fp" == "$(<$EXPECTED)" ]] || { echo "Wrong password: the fingerprint is not the recorded one."; exit 1; }
else
  print -r -- "$fp" > $EXPECTED
  echo "First time: fingerprint saved to $EXPECTED (it goes in the repo, it is not secret)."
fi
echo "Key: $fp"

# Stale native libs from earlier builds can end up in the release package.
rm -rf build/app/intermediates/{merged_jni_libs,merged_native_libs,stripped_native_libs}/userAppRelease

export ELAND_KEYSTORE="$tmp/upload.p12" ELAND_STORE_PASSWORD="$store"
flutter build appbundle --release --flavor userApp -t lib/main_user.dart
flutter build apk --release --flavor userApp -t lib/main_user.dart
ls -1 build/app/outputs/bundle/userAppRelease/*.aab build/app/outputs/flutter-apk/app-userapp-release.apk
