#!/usr/bin/env bash
# html-to-png.sh — rasterize a Claude Design HTML/SVG export to an email-ready PNG.
#
# Claude Design exports HTML/SVG/React, but email clients (Gmail, Outlook) need a flat
# raster. This is the guaranteed export-to-PNG bridge: render the exported file in
# headless Google Chrome at a fixed width (2x for retina) and screenshot it.
#
# Usage:
#   html-to-png.sh <input.html|input.svg> <output.png> [width_css_px] [height_css_px]
# Example:
#   html-to-png.sh hero.html hero@2x.png 600 240
#
# Notes:
# - width/height are the CSS dimensions of the header (email heroes are typically
#   600px wide; pick a height to match the design, e.g. 200-300). Output renders at
#   2x device scale, so 600x240 => a 1200x480 PNG. Chrome screenshots the WHOLE
#   window, so the window is sized to exactly width x height — set them to the
#   artifact's real canvas size or the PNG will be padded with background.
# - For a transparent background, ensure the HTML body has no opaque background;
#   Chrome's --default-background-color=00000000 enables alpha.
set -euo pipefail

IN="${1:?need input html/svg path}"
OUT="${2:?need output png path}"
WIDTH="${3:-600}"
HEIGHT="${4:-300}"
SCALE="2"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || CHROME="$(command -v google-chrome || command -v chromium || true)"
[ -n "$CHROME" ] && [ -x "$CHROME" ] || { echo "ERROR: Google Chrome not found"; exit 1; }
[ -f "$IN" ] || { echo "ERROR: input not found: $IN"; exit 1; }

# Resolve to a file:// URL (absolute path).
case "$IN" in
  /*) URL="file://$IN" ;;
  *)  URL="file://$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")" ;;
esac

PXWIDTH=$(( WIDTH * SCALE ))
PXHEIGHT=$(( HEIGHT * SCALE ))

"$CHROME" \
  --headless=new \
  --disable-gpu \
  --hide-scrollbars \
  --force-device-scale-factor="$SCALE" \
  --default-background-color=00000000 \
  --window-size="${WIDTH},${HEIGHT}" \
  --screenshot="$OUT" \
  "$URL" >/dev/null 2>&1 || {
    echo "ERROR: headless render failed for $URL"; exit 1; }

[ -f "$OUT" ] || { echo "ERROR: no PNG produced at $OUT"; exit 1; }
echo "Saved $OUT (${WIDTH}x${HEIGHT}css @ ${SCALE}x => ${PXWIDTH}x${PXHEIGHT}px)"
