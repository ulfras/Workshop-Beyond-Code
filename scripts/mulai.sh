#!/bin/bash
# Siapkan starter untuk kelompok kalian. Aman dijalankan ulang.
# Pemakaian: bash scripts/mulai.sh "<Nama App>" <nomor-kelompok> [akhiran]
# Contoh:    bash scripts/mulai.sh "Tagih Cepat" 3
#            bash scripts/mulai.sh "Tagih Cepat" 3 ayu    (bundle ID: id.workshop.f3.kelompok3.ayu)
# Yang dilakukan: isi NAMA_APP dan BUNDLE_ID_DASAR di Config/Proyek.xcconfig, siapkan git
# (repo + commit pertama kalau belum ada), pasang pengecek rahasia sebelum commit, lalu buka Xcode.
set -euo pipefail
cd "$(dirname "$0")/.."

bantuan() { sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

NAMA="${1:-}"
NOMOR="${2:-}"
AKHIRAN="${3:-}"
# Urutan terbalik (nomor dulu) juga diterima.
if [[ "$NAMA" =~ ^[0-9]+$ ]] && ! [[ "$NOMOR" =~ ^[0-9]+$ ]]; then
  TUKAR="$NAMA"; NAMA="$NOMOR"; NOMOR="$TUKAR"
fi

if [ -z "$NAMA" ] || [ -z "$NOMOR" ]; then bantuan; fi
if ! [[ "$NOMOR" =~ ^[0-9]{1,2}$ ]]; then
  echo "Nomor kelompok harus angka, misalnya 3."; exit 1
fi
POLA_NAMA='^[A-Za-z0-9][A-Za-z0-9 ._-]{0,29}$'
if ! [[ "$NAMA" =~ $POLA_NAMA ]]; then
  echo "Nama app: 1-30 karakter, hanya huruf, angka, spasi, titik atau tanda hubung. Contoh: \"Tagih Cepat\""; exit 1
fi
if [ -n "$AKHIRAN" ] && ! [[ "$AKHIRAN" =~ ^[a-z][a-z0-9]{0,11}$ ]]; then
  echo "Akhiran: huruf kecil dan angka saja, maksimal 12 karakter, misalnya ayu."; exit 1
fi

CONFIG="Config/Proyek.xcconfig"
[ -f "$CONFIG" ] || { echo "$CONFIG tidak ada. Jalankan script ini dari folder starter yang utuh."; exit 1; }

BUNDLE="id.workshop.f3.kelompok$NOMOR"
[ -n "$AKHIRAN" ] && BUNDLE="$BUNDLE.$AKHIRAN"
export NAMA BUNDLE
perl -pi -e 's/^NAMA_APP\s*=.*$/NAMA_APP = $ENV{NAMA}/' "$CONFIG"
perl -pi -e 's/^BUNDLE_ID_DASAR\s*=.*$/BUNDLE_ID_DASAR = $ENV{BUNDLE}/' "$CONFIG"
grep -q "^NAMA_APP = $NAMA\$" "$CONFIG" && grep -q "^BUNDLE_ID_DASAR = $BUNDLE\$" "$CONFIG" \
  || { echo "Gagal mengubah $CONFIG. Cek isinya dengan tangan."; exit 1; }
echo "✓ $CONFIG: NAMA_APP = $NAMA, BUNDLE_ID_DASAR = $BUNDLE"

# --- git -----------------------------------------------------------------------
if ! command -v git >/dev/null; then
  echo "! git belum ada. Jalankan: xcode-select --install"; exit 1
fi
if [ ! -d .git ]; then
  git init -q -b main
  echo "✓ Repo git baru (branch main)"
fi
if [ -z "$(git config user.email || true)" ]; then
  git config user.name "Kelompok $NOMOR"
  git config user.email "kelompok$NOMOR@workshop.invalid"
fi

# Pengecek rahasia: menolak commit yang membawa kunci secret, .env, atau .xcconfig lokal.
HOOK="$(git rev-parse --git-path hooks)/pre-commit"
mkdir -p "$(dirname "$HOOK")"
cat > "$HOOK" <<'HOOK'
#!/bin/sh
# Dipasang oleh scripts/mulai.sh
exec bash "$(git rev-parse --show-toplevel)/scripts/cek-rahasia.sh"
HOOK
chmod +x "$HOOK" scripts/*.sh
echo "✓ Pengecek rahasia aktif sebelum setiap commit (scripts/cek-rahasia.sh)"

git add -A
if git diff --cached --quiet; then
  echo "✓ Tidak ada perubahan untuk di-commit"
elif git rev-parse -q --verify HEAD >/dev/null; then
  git commit -q -m "Atur nama app dan bundle ID · kelompok $NOMOR · $NAMA ($BUNDLE)"
  echo "✓ Commit: nama app dan bundle ID"
else
  git commit -q -m "Starter kelompok $NOMOR · $NAMA ($BUNDLE)"
  echo "✓ Commit pertama"
fi

echo
echo "Siap: $NAMA ($BUNDLE)."
echo "Berikutnya:"
echo "  1. Buka Prototipe.xcodeproj, pilih simulator iPhone 17 Pro, lalu Cmd+R (app jalan) dan Cmd+U (test lulus)."
echo "  2. Impor folder skills/ sekali per Mac: Xcode > Settings > Intelligence > Plug-ins > Add Plug-in."
echo "  3. Tanya agen: \"Aturan apa yang kamu baca dari repo ini?\"  Langkah lengkap: docs/mulai-di-xcode.md"
if [ "$(uname)" = "Darwin" ]; then
  open Prototipe.xcodeproj
fi
