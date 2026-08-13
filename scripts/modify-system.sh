#!/usr/bin/env bash
set -euo pipefail

: "${SYSTEM_DIR:?SYSTEM_DIR required}"
: "${REZEOS_NAME:?REZEOS_NAME required}"
: "${REZEOS_VERSION:?REZEOS_VERSION required}"
: "${REZEOS_CODENAME:?REZEOS_CODENAME required}"
: "${REZEOS_BASE:?REZEOS_BASE required}"
WALLPAPER_ASSET="${WALLPAPER_ASSET:-}"

PROP="$SYSTEM_DIR/build.prop"
if [ ! -f "$PROP" ]; then
  PROP="$SYSTEM_DIR/system/build.prop"
fi
[ -f "$PROP" ] || { echo "Unable to locate build.prop in $SYSTEM_DIR" >&2; exit 1; }

# Keep the Android runtime layout intact: never rewrite /etc or its symlinks.
# Apply RezeOS branding through build properties only.
sed -i '/^ro\.rezeos\./d' "$PROP"
sed -i 's/LineageOS/RezeOS/gI' "$PROP"

set_prop() {
  local key="$1" value="$2"
  sed -i "/^${key}=.*/d" "$PROP"
  printf '%s=%s\n' "$key" "$value" >> "$PROP"
}

set_prop ro.rezeos.name "$REZEOS_NAME"
set_prop ro.rezeos.version "$REZEOS_VERSION"
set_prop ro.rezeos.codename "$REZEOS_CODENAME"
set_prop ro.rezeos.base "$REZEOS_BASE"

# Product identity used by Android/Setup Wizard-facing APIs.
set_prop ro.product.brand "$REZEOS_NAME"
set_prop ro.product.manufacturer "$REZEOS_NAME"
set_prop ro.product.model "$REZEOS_NAME"
set_prop ro.product.name "$REZEOS_NAME"
set_prop ro.product.device reze
set_prop ro.product.system.brand "$REZEOS_NAME"
set_prop ro.product.system.manufacturer "$REZEOS_NAME"
set_prop ro.product.system.model "$REZEOS_NAME"
set_prop ro.product.system.name "$REZEOS_NAME"
set_prop ro.product.system.device reze
set_prop ro.build.display.id "$REZEOS_NAME-$REZEOS_VERSION"

if [ -n "$WALLPAPER_ASSET" ] && [ -f "$WALLPAPER_ASSET" ]; then
  WALLPAPER_DST="$SYSTEM_DIR/system/media/rezeos_default.webp"
  mkdir -p "$(dirname "$WALLPAPER_DST")"
  install -o 0 -g 0 -m 0644 "$WALLPAPER_ASSET" "$WALLPAPER_DST"
  # Android checks ro.config.wallpaper before its framework default.
  set_prop ro.config.wallpaper /system/media/rezeos_default.webp
  echo "Installed RezeOS wallpaper: $WALLPAPER_DST"
fi

if grep -qi 'lineageos' "$PROP"; then
  echo "Residual LineageOS branding remains in build.prop" >&2
  exit 1
fi

echo "Modified RezeOS properties in: $PROP"
grep -E '^(ro\.rezeos\.|ro\.product\.(brand|manufacturer|model|name|device)=|ro\.product\.system\.|ro\.build\.display\.id=|ro\.config\.wallpaper=)' "$PROP"
