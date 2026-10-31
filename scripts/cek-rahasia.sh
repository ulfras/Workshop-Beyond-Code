#!/bin/bash
# Pengecek rahasia. Jalan otomatis sebelum setiap commit (dipasang oleh scripts/mulai.sh),
# atau manual: bash scripts/cek-rahasia.sh   (memeriksa file yang sedang di-stage)
#
# Menolak commit kalau ada:
#   - file .xcconfig selain Config/Proyek.xcconfig dan Config/Supabase.example.xcconfig
#   - file .env atau .env.*
#   - kunci secret Supabase (sb_secret_...), token JWT, atau kata service_role di file selain .md
# Memberi peringatan (tidak menolak) kalau kunci publishable muncul di luar template.
# Isi kunci tidak pernah dicetak, hanya nama filenya.
set -u
cd "$(git rev-parse --show-toplevel)" || exit 1

TOLAK=0
tolak() { echo "✗ $1"; TOLAK=1; }

# 1. File yang tidak boleh di-commit
while IFS= read -r -d '' f; do
  case "$f" in
    Config/Proyek.xcconfig|Config/Supabase.example.xcconfig) ;;
    *.xcconfig) tolak "$f: .xcconfig lokal bisa berisi kunci. Yang boleh di-commit hanya Config/Proyek.xcconfig dan Config/Supabase.example.xcconfig." ;;
  esac
  case "${f##*/}" in
    .env|.env.*) tolak "$f: file .env tidak boleh di-commit." ;;
  esac
done < <(git diff --cached --name-only --diff-filter=ACMR -z)

# 2. Isi baris yang ditambahkan (format: file<TAB>baris). Script ini sendiri dilewati.
SEMENTARA="$(mktemp)"
trap 'rm -f "$SEMENTARA"' EXIT
git diff --cached -U0 --no-color --no-ext-diff --diff-filter=ACMR -- . ':(exclude)scripts/cek-rahasia.sh' \
  | awk '/^\+\+\+ / { f = substr($0, 5); sub(/^b\//, "", f); next }
         /^\+/      { print f "\t" substr($0, 2) }' > "$SEMENTARA"

file_cocok() { grep -E "$1" "$SEMENTARA" | cut -f1 | sort -u; }

while IFS= read -r f; do
  tolak "$f: berisi kunci secret Supabase. Kunci ini tidak boleh ada di repo atau di app."
done < <(file_cocok 'sb_secret_[A-Za-z0-9_-]{8,}')
while IFS= read -r f; do
  tolak "$f: berisi token JWT (kunci anon lama atau service role). Simpan kunci hanya di Config/Supabase.xcconfig."
done < <(file_cocok 'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}')
while IFS= read -r f; do
  tolak "$f: menyebut service_role. Kunci dan peran service role tidak dipakai di prototipe ini."
done < <(file_cocok 'service_role' | grep -v '\.md$')
while IFS= read -r f; do
  echo "! $f: berisi kunci publishable. Tidak berbahaya, tapi tempatnya di Config/Supabase.xcconfig (tidak di-commit)."
done < <(file_cocok 'sb_publishable_[A-Za-z0-9_-]{8,}' | grep -vxE 'Config/Supabase(\.example)?\.xcconfig')

if [ "$TOLAK" -ne 0 ]; then
  echo
  echo "Commit dibatalkan. Keluarkan file itu dari stage: git restore --staged <file>"
  echo "Lalu hapus kuncinya dari file, atau pindahkan ke Config/Supabase.xcconfig."
  exit 1
fi
exit 0
