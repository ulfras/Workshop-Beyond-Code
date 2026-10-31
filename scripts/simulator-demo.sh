#!/bin/bash
# Siapkan Simulator untuk demo, screenshot dan video.
# Pemakaian:
#   bash scripts/simulator-demo.sh rapikan                   status bar 9:41, baterai penuh, mode terang
#   bash scripts/simulator-demo.sh paksa demoContoh gagal    jalankan app dengan state dipaksa
#   bash scripts/simulator-demo.sh normal                    jalankan app tanpa paksaan
#   bash scripts/simulator-demo.sh rekam marketing/video/demo.mov   rekam layar, Ctrl+C untuk berhenti
# App harus sudah pernah dijalankan dari Xcode (Cmd+R) di simulator yang sedang menyala.
set -euo pipefail
cd "$(dirname "$0")/.."
# Bundle ID app dibaca dari Config/Proyek.xcconfig (BUNDLE_ID_DASAR, diisi scripts/mulai.sh).
APP="$(awk -F= '/^BUNDLE_ID_DASAR[ \t]*=/ { gsub(/[ \t]/, "", $2); print $2; exit }' Config/Proyek.xcconfig)"
[ -n "$APP" ] || { echo "BUNDLE_ID_DASAR tidak ditemukan di Config/Proyek.xcconfig."; exit 1; }

case "${1:-}" in
  rapikan)
    xcrun simctl ui booted appearance light
    xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100 \
      --cellularMode active --cellularBars 4 --wifiBars 3 --operatorName ""
    echo "Status bar 9:41." ;;
  paksa)
    xcrun simctl terminate booted "$APP" 2>/dev/null || true
    xcrun simctl launch booted "$APP" "-${2:?nama layar, misalnya demoContoh}" "${3:?keadaan: memuat kosong gagal}" ;;
  normal)
    xcrun simctl terminate booted "$APP" 2>/dev/null || true
    xcrun simctl launch booted "$APP" ;;
  rekam)
    mkdir -p "$(dirname "${2:-marketing/video/demo.mov}")"
    xcrun simctl io booted recordVideo --codec=h264 "${2:-marketing/video/demo.mov}" ;;
  *)
    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
