#!/usr/bin/env bash
set -euo pipefail
: "${SYSTEM_DIR:?SYSTEM_DIR required}"
: "${REZEOS_NAME:?REZEOS_NAME required}"
: "${REZEOS_VERSION:?REZEOS_VERSION required}"
: "${REZEOS_CODENAME:?REZEOS_CODENAME required}"
: "${REZEOS_BASE:?REZEOS_BASE required}"
WALLPAPER_ASSET="${WALLPAPER_ASSET:-}"
mapfile -t PROP_FILES < <(find "$SYSTEM_DIR" -type f -name 'build.prop' -print | sort)
[ "${#PROP_FILES[@]}" -gt 0 ] || { echo "No build.prop found" >&2; exit 1; }
set_prop() {
  local prop="$1" key="$2" value="$3"
  sed -i "/^${key}=.*/d" "$prop"
  printf '%s=%s\n' "$key" "$value" >> "$prop"
}
for PROP in "${PROP_FILES[@]}"; do
  sed -i '/^ro\.rezeos\./d' "$PROP"
  sed -i -E 's/Lineage[[:space:]_-]*OS/RezeOS/gI' "$PROP"
  case "$PROP" in
    */system/build.prop|*/product/build.prop|*/vendor/build.prop|*/odm/build.prop|*/system_ext/build.prop|*/build.prop)
      set_prop "$PROP" ro.product.brand "$REZEOS_NAME"
      set_prop "$PROP" ro.product.manufacturer "$REZEOS_NAME"
      set_prop "$PROP" ro.product.model "$REZEOS_NAME"
      set_prop "$PROP" ro.product.name "$REZEOS_NAME"
      set_prop "$PROP" ro.product.device reze
      ;;
  esac
  set_prop "$PROP" ro.rezeos.name "$REZEOS_NAME"
  set_prop "$PROP" ro.rezeos.version "$REZEOS_VERSION"
  set_prop "$PROP" ro.rezeos.codename "$REZEOS_CODENAME"
  set_prop "$PROP" ro.rezeos.base "$REZEOS_BASE"
  set_prop "$PROP" ro.build.display.id "$REZEOS_NAME-$REZEOS_VERSION"
done
if grep -RqiE 'lineage[[:space:]_-]*os' "${PROP_FILES[@]}"; then
  echo "Residual LineageOS branding remains in build.prop" >&2
  exit 1
fi
echo "Modified RezeOS properties:"
for PROP in "${PROP_FILES[@]}"; do
  echo "--- $PROP"
  grep -E '^(ro\.rezeos\.|ro\.product\.(brand|manufacturer|model|name|device)=|ro\.build\.display\.id=)' "$PROP" || true
done
