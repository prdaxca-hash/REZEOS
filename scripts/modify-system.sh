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

if [ ! -f "$PROP" ]; then
  echo "Unable to locate build.prop in $SYSTEM_DIR" >&2
  exit 1
fi

# Keep the modification minimal: only add RezeOS properties to build.prop.
# Do not rewrite /etc or any Android runtime symlinks. In a GSI, /etc may be a
# deliberately dangling /system/etc symlink while the system partition is
# mounted at /system during Android boot. Replacing it with a directory breaks
# the original runtime layout and can cause a boot hang.
sed -i '/^ro\.rezeos\./d' "$PROP"
{
  echo "ro.rezeos.name=${REZEOS_NAME}"
  echo "ro.rezeos.version=${REZEOS_VERSION}"
  echo "ro.rezeos.codename=${REZEOS_CODENAME}"
  echo "ro.rezeos.base=${REZEOS_BASE}"
} >> "$PROP"

echo "Modified RezeOS properties in: $PROP"
grep -E '^ro\.rezeos\.' "$PROP"
