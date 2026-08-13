#!/usr/bin/env bash
set -euo pipefail

: "${SYSTEM_DIR:?SYSTEM_DIR required}"
: "${REZEOS_NAME:?REZEOS_NAME required}"
: "${REZEOS_VERSION:?REZEOS_VERSION required}"
: "${REZEOS_CODENAME:?REZEOS_CODENAME required}"

PROP="$SYSTEM_DIR/system/build.prop"
if [ -f "$PROP" ]; then
  sed -i '/^ro.rezeos./d' "$PROP" || true
  echo "ro.rezeos.name=${REZEOS_NAME}" >> "$PROP"
  echo "ro.rezeos.version=${REZEOS_VERSION}" >> "$PROP"
  echo "ro.rezeos.codename=${REZEOS_CODENAME}" >> "$PROP"
fi

mkdir -p "$SYSTEM_DIR/etc/rezeos"
cat > "$SYSTEM_DIR/etc/rezeos/build-info" <<EOF
NAME=${REZEOS_NAME}
VERSION=${REZEOS_VERSION}
BASE=AxionOS-2.8-GSI
EOF
