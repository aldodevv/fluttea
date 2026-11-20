#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export TOOLCHAINS="${TOOLCHAINS:-com.apple.dt.toolchain.XcodeDefault}"

echo "========================================"
echo "🛡️  FLUTTEA COMPREHENSIVE SECURITY AUDIT"
echo "========================================"
echo ""

FAILURES=0

# 1. Gitleaks Secret Detection
echo "🔍 [1/5] Checking for hardcoded secrets with Gitleaks..."
if command -v gitleaks >/dev/null 2>&1; then
  if gitleaks dir . --config .gitleaks.toml --gitleaks-ignore-path .gitleaksignore >/dev/null 2>&1; then
    echo "   ✅ PASSED: Tidak ada secret/token/kunci hardcode ditemukan."
  else
    echo "   ❌ FAILED: Terdeteksi secret yang belum diabaikan atau terekspos!"
    FAILURES=$((FAILURES + 1))
  fi
else
  echo "   ⚠️ SKIPPED: gitleaks CLI tidak terpasang di sistem PATH."
fi

# 2. Dependency Vulnerability Audit with OSV-Scanner
echo "📦 [2/5] Checking supply chain dependencies with OSV-Scanner..."
if command -v osv-scanner >/dev/null 2>&1; then
  if osv-scanner --lockfile pubspec.lock >/dev/null 2>&1; then
    echo "   ✅ PASSED: 0 kerentanan (vulnerabilities) pada pubspec.lock."
  else
    echo "   ❌ FAILED: Ditemukan advisory kerentanan dependensi!"
    FAILURES=$((FAILURES + 1))
  fi
else
  echo "   ⚠️ SKIPPED: osv-scanner CLI tidak terpasang di sistem PATH."
fi

# 3. UI Token & Theme Rule Compliance
echo "🎨 [3/5] Verifying UI tokens & theme compliance..."
if ./tool/check_ui_rules.sh >/dev/null 2>&1; then
  echo "   ✅ PASSED: Bebas dari warna/font/dimensi mentah di lib/features."
else
  echo "   ❌ FAILED: Pelanggaran aturan UI terdeteksi!"
  FAILURES=$((FAILURES + 1))
fi

# 4. Dart Static Analysis
echo "🔬 [4/5] Running strict static code analysis..."
if rtk fvm dart analyze --fatal-infos >/dev/null 2>&1; then
  echo "   ✅ PASSED: 0 issue pada analisis kode Dart."
else
  echo "   ❌ FAILED: Terdapat analyzer issues/lints!"
  FAILURES=$((FAILURES + 1))
fi

# 5. Code Formatting Standard
echo "📐 [5/5] Checking code formatting..."
if rtk fvm dart format --output=none --set-exit-if-changed lib test tool integration_test >/dev/null 2>&1; then
  echo "   ✅ PASSED: Format kode konsisten dan rapi."
else
  echo "   ❌ FAILED: Ada file yang belum diformat dengan dart format!"
  FAILURES=$((FAILURES + 1))
fi

echo ""
echo "========================================"
if [ $FAILURES -eq 0 ]; then
  echo "🎉 AUDIT SELESAI: SEMUA CHECK AMAN (0 FAILURES)"
  echo "========================================"
  exit 0
else
  echo "❌ AUDIT GAGAL: Ditemukan $FAILURES kegagalan pemeriksaan keamanan."
  echo "========================================"
  exit 1
fi
