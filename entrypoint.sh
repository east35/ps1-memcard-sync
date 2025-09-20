#!/bin/sh
set -eu

WATCH_DIR="${WATCH_DIR:-/watch}"
POLL_INTERVAL="${POLL_INTERVAL:-2}"
PUID="${PUID:-0}"
PGID="${PGID:-0}"

# ensure user/group exist
if [ "$PGID" -ne 0 ] && ! getent group "$PGID" >/dev/null 2>&1; then
  addgroup -g "$PGID" syncgroup
fi
if [ "$PUID" -ne 0 ] && ! getent passwd "$PUID" >/dev/null 2>&1; then
  adduser -D -H -u "$PUID" -G "$(getent group "$PGID" | cut -d: -f1 || echo root)" syncuser
fi

echo "[ps1-sync] WATCH_DIR=${WATCH_DIR} POLL_INTERVAL=${POLL_INTERVAL}s PUID=${PUID} PGID=${PGID}"

umask 0002

cpnew() {
  src="$1" dst="$2"
  if [ ! -f "$dst" ] || [ "$src" -nt "$dst" ]; then
    cp -f -p "$src" "$dst"
    touch -r "$src" "$dst"
    chmod 664 "$dst" 2>/dev/null || true
    echo "[ps1-sync] wrote $(basename "$dst") from $(basename "$src")"
  fi
}

swap_sav() {
  in="$1" out="$2"
  tmp="${out}.tmp.$$"
  dd if="$in" of="$tmp" conv=swab status=none
  cpnew "$tmp" "$out"
  rm -f "$tmp"
}

while :; do
  for f in "$WATCH_DIR"/*; do
    [ -f "$f" ] || continue
    n="${f##*/}"
    case "$n" in .*|*.syncthing*|*.tmp|*.tmp.*) continue;; esac

    base="${f%.*}"
    ext="${n##*.}"
    lc=$(printf "%s" "$ext" | tr A-Z a-z)

    sz=$(stat -c %s "$f" 2>/dev/null || stat -f %z "$f" || echo 0)

    # expect 131072 bytes (128 KB)
    [ "$sz" -eq 131072 ] || continue

    if [ "$lc" = sav ]; then
      # MiSTer -> handheld
      cpnew "$f" "${base}.srm"
      cpnew "$f" "${base}.mcr"
    elif [ "$lc" = srm ] || [ "$lc" = mcr ]; then
      # Handheld -> MiSTer (byte-swapped copy)
      swap_sav "$f" "${base}.sav"
    fi
  done
  sleep "$POLL_INTERVAL"
done