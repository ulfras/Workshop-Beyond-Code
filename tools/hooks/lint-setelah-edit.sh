#!/bin/bash
# Hook: setelah agen mengedit file.
# Claude Code: PostToolUse (matcher Edit|Write) · Cursor: afterFileEdit
# Menjalankan SwiftLint pada file .swift yang baru diubah. Kalau ada pelanggaran,
# hasilnya dikirim ke agen (exit 2 di PostToolUse: pesan dibaca agen, edit tidak dibatalkan).

input=$(cat)
path=""
if command -v jq >/dev/null 2>&1; then
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .file_path // empty' 2>/dev/null)
fi

case "$path" in
  *.swift) ;;
  *) exit 0 ;;
esac

# SwiftLint belum terpasang: lewati tanpa menghentikan agen.
command -v swiftlint >/dev/null 2>&1 || exit 0
[ -f "$path" ] || exit 0

hasil=$(swiftlint lint --quiet "$path" 2>/dev/null)
if [ -n "$hasil" ]; then
  echo "SwiftLint menemukan pelanggaran di $path. Perbaiki sebelum lanjut:" >&2
  echo "$hasil" >&2
  exit 2
fi
exit 0
