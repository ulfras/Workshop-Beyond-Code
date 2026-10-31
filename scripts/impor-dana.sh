#!/bin/bash
# Impor folder kelompok dari sesi Dana ke starter ini. Aman dijalankan ulang.
# Pemakaian: bash scripts/impor-dana.sh <folder kelompok dari sesi Dana>
# Contoh:    bash scripts/impor-dana.sh ~/Desktop/TagihTeman
# Disalin: docs/*.md dari sesi Dana, DESIGN.md, folder prototype/, dan bagian "## Produk" di AGENTS.md.
# File starter yang tertimpa disimpan sekali di docs/_starter/. Setelah itu: commit, lalu perbarui Tokens.swift lewat agen.
set -euo pipefail
cd "$(dirname "$0")/.."

bantuan() { sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

SUMBER="${1:-}"
[ -n "$SUMBER" ] || bantuan
SUMBER="${SUMBER%/}"
[ -d "$SUMBER" ] || { echo "Folder tidak ditemukan: $SUMBER"; exit 1; }
SUMBER="$(cd "$SUMBER" && pwd)"
if [ "$SUMBER" = "$(pwd)" ]; then
  echo "Itu folder starter ini sendiri. Tunjuk folder kelompok dari sesi Dana."; exit 1
fi
if [ ! -f "$SUMBER/AGENTS.md" ] && [ ! -f "$SUMBER/DESIGN.md" ] && [ ! -d "$SUMBER/docs" ] && [ ! -d "$SUMBER/prototype" ]; then
  echo "Di $SUMBER tidak ada AGENTS.md, DESIGN.md, docs/ atau prototype/."
  echo "Benar ini folder kelompok dari sesi Dana?"; exit 1
fi

CADANGAN="docs/_starter"
mkdir -p "$CADANGAN"
# Simpan versi starter sekali saja, sebelum ditimpa. Nama diberi akhiran .starter.md supaya tidak dibaca agen sebagai aturan.
simpan() {
  local f="$1" tujuan
  tujuan="$CADANGAN/$(echo "${f%.md}" | tr '/' '_').starter.md"
  if [ -f "$f" ] && [ ! -f "$tujuan" ]; then cp "$f" "$tujuan"; fi
  return 0
}

DISALIN=""
STARTER_SAJA=" DECISIONS.md cara-kerja-tim.md dari-html-ke-swiftui.md mulai-di-xcode.md supabase-opsional.md "

# 1. docs/: job-story, userflow, PRD, tasks, dan .md lain dari sesi Dana
if [ -d "$SUMBER/docs" ]; then
  for src in "$SUMBER"/docs/*.md; do
    [ -f "$src" ] || continue
    nama="$(basename "$src")"
    case "$STARTER_SAJA" in *" $nama "*) echo "Lewati docs/$nama: file ini milik starter."; continue ;; esac
    simpan "docs/$nama"
    cp "$src" "docs/$nama"
    DISALIN="$DISALIN docs/$nama"
  done
fi

# 2. DESIGN.md
if [ -f "$SUMBER/DESIGN.md" ]; then
  simpan DESIGN.md
  cp "$SUMBER/DESIGN.md" DESIGN.md
  DISALIN="$DISALIN DESIGN.md"
fi

# 3. prototype/: tanpa node_modules dan tanpa file .env
if [ -d "$SUMBER/prototype" ]; then
  mkdir -p prototype
  ( cd "$SUMBER/prototype" && find . -type f ! -path '*/node_modules/*' ! -name '.env*' ! -name '.DS_Store' ) | while IFS= read -r f; do
    f="${f#./}"
    mkdir -p "prototype/$(dirname "$f")"
    cp "$SUMBER/prototype/$f" "prototype/$f"
  done
  DISALIN="$DISALIN prototype/"
fi

# 4. AGENTS.md: hanya bagian "## Produk". Aturan lain di AGENTS.md starter tetap.
if [ -f "$SUMBER/AGENTS.md" ]; then
  mkdir -p docs/_dana
  cp "$SUMBER/AGENTS.md" docs/_dana/AGENTS-sesi-dana.md
  PRODUK="$(awk '/^## Produk/{p=1; print; next} p && /^## /{exit} p{print}' "$SUMBER/AGENTS.md")"
  if [ -n "$PRODUK" ]; then
    simpan AGENTS.md
    export PRODUK
    perl -0pi -e 's/^## Produk[^\n]*\n.*?(?=^## )/$ENV{PRODUK}\n\n/ms' AGENTS.md
    DISALIN="$DISALIN AGENTS.md(Produk)"
  else
    echo "AGENTS.md dari sesi Dana tidak punya bagian \"## Produk\"."
    echo "Isi bagian Produk di AGENTS.md dari docs/job-story.md dan docs/PRD.md."
  fi
fi

[ -n "$DISALIN" ] || { echo "Tidak ada yang disalin."; exit 1; }
echo "Disalin dari $SUMBER:"
for x in $DISALIN; do echo "  $x"; done
echo "Versi starter yang tertimpa ada di $CADANGAN/."

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -A docs DESIGN.md AGENTS.md prototype 2>/dev/null || true
  if git commit -q -m "Impor folder kelompok dari sesi Dana"; then
    echo "Commit: Impor folder kelompok dari sesi Dana"
  else
    echo "Belum di-commit. Cek pesan di atas (misalnya cek-rahasia), perbaiki, lalu commit."
  fi
fi

cat <<'LANJUT'

Langkah berikutnya:
1. Tulis temuan terbesar dari uji cepat sesi Dana sebagai task pertama di docs/tasks.md.
2. Minta agen: "Perbarui DesignSystem/Tokens.swift dari DESIGN.md. Pakai skill html-ke-swiftui,
   references/token.md. Tunjukkan tabel nilai lama dan baru sebelum mengubah, lalu build."
3. Tes agen: "Aturan apa yang kamu baca?"
LANJUT
