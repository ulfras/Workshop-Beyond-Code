#!/bin/bash
# Build dan jalankan semua test dari Terminal. Cadangan kalau agen di Xcode macet,
# dan cara cepat untuk mentor mengecek repo kelompok.
# Pemakaian: bash scripts/cek-build.sh                   (simulator iPhone 17 Pro)
#            bash scripts/cek-build.sh "iPhone 17"       (simulator lain)
set -uo pipefail
cd "$(dirname "$0")/.."

SIM="${1:-iPhone 17 Pro}"
TUJUAN="platform=iOS Simulator,name=$SIM"
command -v xcodebuild >/dev/null || { echo "xcodebuild tidak ada. Jalankan di Mac dengan Xcode 27."; exit 1; }

petunjuk() {
  echo "  Baca error PERTAMA di atas; error berikutnya sering akibat error itu."
  echo "  Simulator \"$SIM\" tidak ada? Lihat yang tersedia: xcrun simctl list devices available"
  echo "  Lalu ulangi dengan nama itu, misalnya: bash scripts/cek-build.sh \"iPhone 17\""
}

echo "1/2 Build · scheme Prototipe · $SIM"
if ! xcodebuild -project Prototipe.xcodeproj -scheme Prototipe -destination "$TUJUAN" build -quiet; then
  echo "✗ Build gagal."; petunjuk; exit 1
fi
echo "2/2 Test · scheme Prototipe · $SIM"
if ! xcodebuild -project Prototipe.xcodeproj -scheme Prototipe -destination "$TUJUAN" test -quiet; then
  echo "✗ Ada test yang gagal (atau test tidak bisa jalan)."; petunjuk; exit 1
fi
echo "✓ Build bersih dan semua test lulus."
