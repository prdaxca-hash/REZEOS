#!/usr/bin/env bash
set -euo pipefail
: "${SYSTEM_DIR:?SYSTEM_DIR required}"
: "${WALLPAPER_ASSET:?WALLPAPER_ASSET required}"
FRAMEWORK_APK=""
for candidate in "$SYSTEM_DIR/system/framework/framework-res.apk" "$SYSTEM_DIR/framework/framework-res.apk" "$SYSTEM_DIR/system_ext/framework/framework-res.apk"; do
  if [ -f "$candidate" ]; then FRAMEWORK_APK="$candidate"; break; fi
done
[ -n "$FRAMEWORK_APK" ] || { echo "framework-res.apk not found" >&2; exit 1; }
mapfile -t ENTRIES < <(unzip -Z1 "$FRAMEWORK_APK" | grep -E '^res/drawable[^/]*/default_wallpaper\.(png|jpg|jpeg|webp)$' | sort -u)
[ "${#ENTRIES[@]}" -gt 0 ] || { echo "No default_wallpaper resources found" >&2; exit 1; }
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
for entry in "${ENTRIES[@]}"; do
  mkdir -p "$TMPDIR/$(dirname "$entry")"
  cp -- "$WALLPAPER_ASSET" "$TMPDIR/$entry"
  zip -q -FS "$FRAMEWORK_APK" "$TMPDIR/$entry"
done
echo "Reze wallpaper installed into framework-res.apk"
printf '%s\n' "${ENTRIES[@]}"
