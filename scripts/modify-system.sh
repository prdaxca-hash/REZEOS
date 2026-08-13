#!/usr/bin/env bash
set -euo pipefail

: "${SYSTEM_DIR:?SYSTEM_DIR required}"
: "${REZEOS_NAME:?REZEOS_NAME required}"
: "${REZEOS_VERSION:?REZEOS_VERSION required}"
: "${REZEOS_CODENAME:?REZEOS_CODENAME required}"
: "${REZEOS_BASE:?REZEOS_BASE required}"

PROP="$SYSTEM_DIR/build.prop"
if [ ! -f "$PROP" ]; then
  PROP="$SYSTEM_DIR/system/build.prop"
fi

if [ -f "$PROP" ]; then
  sed -i '/^ro\.rezeos\./d' "$PROP"
  {
    printf 'ro.rezeos.name=%s\n' "$REZEOS_NAME"
    printf 'ro.rezeos.version=%s\n' "$REZEOS_VERSION"
    printf 'ro.rezeos.codename=%s\n' "$REZEOS_CODENAME"
  } >> "$PROP"
fi

mkdir -p "$SYSTEM_DIR/etc/rezeos"
cat > "$SYSTEM_DIR/etc/rezeos/build-info" <<EOF
NAME=$REZEOS_NAME
VERSION=$REZEOS_VERSION
CODENAME=$REZEOS_CODENAME
BASE=$REZEOS_BASE
EOF

chmod 0644 "$SYSTEM_DIR/etc/rezeos/build-info"
