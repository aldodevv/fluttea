#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export TOOLCHAINS="${TOOLCHAINS:-com.apple.dt.toolchain.XcodeDefault}"

echo "=========================================================="
echo "🔒 FLUTTEA MITM PROXY & SSL PINNING VERIFICATION TOOL"
echo "=========================================================="
echo ""
echo "Menguji penolakan Man-In-The-Middle (MITM) pada layer TLS..."
echo ""

# 1. Menjalankan Live TLS Socket Verification Test
echo "▶️ [1/2] Menjalankan Automated Live HTTPS Handshake Test..."
if rtk fvm flutter test test/core/security/pinning_live_test.dart; then
  echo ""
  echo "✅ PASSED: Verifikasi Pre-Send Pinning Berhasil!"
  echo "   - Saat sertifikat/pin valid: Request berhasil diproses."
  echo "   - Saat sertifikat MITM/pin salah: Handshake diputus seketika."
  echo "   - Terbukti 0 byte data plaintext terkirim ke server proxy saat diserang."
else
  echo ""
  echo "❌ FAILED: Uji pinning live gagal!"
  exit 1
fi

echo ""
echo "=========================================================="
echo "📋 [2/2] PANDUAN PENGUJIAN MITM MANUAL DENGAN PROXY TOOLS"
echo "=========================================================="
echo "Untuk menguji aplikasi release di perangkat nyata (Android/iOS)"
echo "menggunakan Charles Proxy, Proxyman, Burp Suite, atau mitmproxy:"
echo ""
echo "1. Pasang sertifikat root CA proxy (misal Charles CA) ke perangkat user."
echo "2. Konfigurasikan proxy HTTP di pengaturan Wi-Fi ponsel (IP:PORT)."
echo "3. Buka aplikasi Fluttea flavor 'prod' (release build)."
echo "4. HASIL YANG DIHARAPKAN:"
echo "   - Semua request HTTPS ke domain dengan pinning HARUS GAGAL di log proxy."
echo "   - Charles / Proxyman akan mencatat: 'SSL Handshake Failed' / 'Client closed connection'."
echo "   - Tidak ada header, path, query param, atau body payload yang terbaca di proxy."
echo "5. DI FLAVOR 'DEV':"
echo "   - Buka DevTools Hub > Tab Network > Proxy Config untuk mengarahkan proxy secara terkontrol."
echo "=========================================================="
exit 0

