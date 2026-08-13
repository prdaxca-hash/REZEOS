#!/usr/bin/env bash
set -euo pipefail

: "${SYSTEM_DIR:?SYSTEM_DIR required}"
: "${REZEOS_NAME:?REZEOS_NAME required}"
: "${REZEOS_VERSION:?REZEOS_VERSION required}"
: "${REZEOS_CODENAME:?REZEOS_CODENAME required}"
: "${REZEOS_BASE:?REZEOS_BASE required}"

# A mounted GSI system image exposes the Android system root directly.
# Depending on the build layout, build.prop may be at the root of the image.
PROP="$SYSTEM_DIR/build.prop"
if [ ! -f "$PROP" ]; then
  PROP="$SYSTEM_DIR/system/build.prop"
fi

if [ -f "$PROP" ]; then
  sed -i '/^ro\.rezeos\./d' "$PROP" || true
  {
    echo "ro.rezeos.name=${REZEOS_NAME}"
    echo "ro.rezeos.version=${REZEOS_VERSION}"
    echo "ro.rezeos.codename=${REZEOS_CODENAME}"
  } >> "$PROP"
fi

# The GSI uses a system-as-root style /etc -> /system/etc symlink. When the
# system partition is mounted by itself at $SYSTEM_DIR, /system/etc is outside
# the host namespace and realpath cannot resolve it. In the Android runtime,
# /system/etc refers to the etc directory supplied by this same system image.
# Replace this special dangling symlink with a real directory so the resulting
# image preserves the intended runtime path while remaining directly editable.
ETC_PATH="$SYSTEM_DIR/etc"
if [ -L "$ETC_PATH" ]; then
  ETC_LINK="$(readlink "$ETC_PATH")"
  echo "Android /etc symlink: $ETC_LINK"

  if [ "$ETC_LINK" = "/system/etc" ] && [ ! -e "$ETC_PATH" ]; then
    echo 'Converting dangling /etc -> /system/etc symlink to a real etc directory'
    rm -f "$ETC_PATH"
    mkdir -p "$ETC_PATH"
  fi
fi

if [ -L "$ETC_PATH" ]; then
  ETC_DIR="$(realpath -e "$ETC_PATH")"
else
  ETC_DIR="$ETC_PATH"
fi

if [ ! -d "$ETC_DIR" ]; then
  echo "Unable to locate Android etc directory: $ETC_DIR" >&2
  exit 1
fi

echo "Resolved Android etc directory: $ETC_DIR"

REZEOS_DIR="$ETC_DIR/rezeos"
mkdir -p "$REZEOS_DIR"
test -d "$REZEOS_DIR"

echo "Writing RezeOS metadata: $REZEOS_DIR/build-info"
cat > "$REZEOS_DIR/build-info" <<EOF
NAME=${REZEOS_NAME}
VERSION=${REZEOS_VERSION}
CODENAME=${REZEOS_CODENAME}
BASE=${REZEOS_BASE}
EOF

test -s "$REZEOS_DIR/build-info"
