#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v fvm >/dev/null 2>&1; then
  echo "ERROR: FVM belum terpasang. Install: https://fvm.app/documentation/getting-started/installation"
  exit 1
fi

echo "[setup] Installing pinned Flutter version from .fvmrc..."
fvm install

echo "[setup] Running flutter pub get..."
fvm flutter pub get

echo "[setup] Generating Pigeon & build_runner files..."
fvm dart run pigeon --input packages/fluttea_security/pigeons/security_api.dart
fvm dart run build_runner build --delete-conflicting-outputs

echo "[setup] Activating Git hooks (.githooks)..."
chmod +x .githooks/pre-commit .githooks/pre-push
git config core.hooksPath .githooks

echo "[setup] Selesai. Lingkungan developer siap."

