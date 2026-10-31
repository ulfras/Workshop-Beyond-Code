#!/bin/bash
# Hook: sebelum agen menjalankan perintah atau mengedit file.
# Claude Code: PreToolUse (matcher Bash|Edit|Write) · Cursor: beforeShellExecution
# Menolak perintah yang merusak dan edit langsung ke file proyek Xcode.
# Exit 2 = aksi diblokir; pesan di stderr dibaca agen supaya ia mencari cara lain.

input=$(cat)
cmd=""
path=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // .command // empty' 2>/dev/null)
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .file_path // empty' 2>/dev/null)
fi

tolak() {
  echo "Ditolak oleh hook blokir-perintah: $1" >&2
  exit 2
}

if [ -n "$cmd" ]; then
  printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push[^|;&]*(--force|-f([[:space:]]|$)|--force-with-lease)' && tolak "jangan push --force. Buat commit baru, atau tanya tim."
  printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+reset[[:space:]]+--hard' && tolak "jangan reset --hard. Pakai git restore untuk file tertentu, atau tanya tim."
  printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f' && tolak "jangan git clean -f. File yang belum dicommit akan hilang."
  printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)' && tolak "jangan rm -rf. Hapus file satu per satu dan sebutkan alasannya."
  printf '%s' "$cmd" | grep -Eq '(>|sed[[:space:]].*-i|tee)[^|;&]*project\.pbxproj' && tolak "jangan mengedit project.pbxproj lewat shell. Ubah build setting lewat tool Xcode."
fi

if [ -n "$path" ]; then
  case "$path" in
    *.pbxproj) tolak "jangan mengedit project.pbxproj langsung. Ubah build setting atau target lewat tool Xcode." ;;
    *.env|*/.env.*|*.p12|*.mobileprovision) tolak "file rahasia atau signing tidak boleh diubah agen: $path" ;;
  esac
fi

exit 0
