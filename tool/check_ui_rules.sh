#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FEATURES_DIR="lib/features"

if [ ! -d "$FEATURES_DIR" ]; then
  echo "[check_ui_rules] No $FEATURES_DIR directory found. Skipping."
  exit 0
fi

echo "[check_ui_rules] Checking UI rules in $FEATURES_DIR..."

VIOLATIONS=0

# 1. Colors.xxx in features
COLOR_MATCHES=$(grep -rnE 'Colors\.[a-zA-Z]+' "$FEATURES_DIR" || true)
if [ -n "$COLOR_MATCHES" ]; then
  echo "ERROR: Dilarang memakai Colors.xxx di lib/features. Gunakan Theme.of(context) / context.colors."
  echo "$COLOR_MATCHES"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 2. Color(0x...) in features
RAW_COLOR_MATCHES=$(grep -rnE 'Color\(0x[0-9a-fA-F]+\)' "$FEATURES_DIR" || true)
if [ -n "$RAW_COLOR_MATCHES" ]; then
  echo "ERROR: Dilarang memakai Color(0x..) mentah di lib/features. Gunakan token di Palette / Theme."
  echo "$RAW_COLOR_MATCHES"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 3. fontSize: xx in features
FONT_MATCHES=$(grep -rnE 'fontSize:[[:space:]]*[0-9]+' "$FEATURES_DIR" || true)
if [ -n "$FONT_MATCHES" ]; then
  echo "ERROR: Dilarang memakai fontSize mentah di lib/features. Gunakan context.text.*."
  echo "$FONT_MATCHES"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

if [ $VIOLATIONS -gt 0 ]; then
  echo "[check_ui_rules] FAILED: Ditemukan $VIOLATIONS jenis pelanggaran aturan UI."
  exit 1
fi

echo "[check_ui_rules] PASSED: Tidak ada pelanggaran aturan UI di $FEATURES_DIR."
exit 0

