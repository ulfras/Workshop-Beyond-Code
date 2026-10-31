#!/bin/bash
# Hook: sebelum prompt dikirim ke model.
# Claude Code: UserPromptSubmit · Cursor: beforeSubmitPrompt
# Menolak prompt yang berisi rahasia (API key, token, private key) atau angka 16 digit (nomor kartu / NIK).
# Exit 2 = prompt ditolak; pesan di stderr ditampilkan.

input=$(cat)
if command -v jq >/dev/null 2>&1; then
  text=$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)
fi
[ -z "$text" ] && text="$input"

tolak() {
  echo "Ditolak oleh hook cek-rahasia: prompt berisi $1. Hapus atau ganti dengan data dummy, lalu kirim ulang." >&2
  exit 2
}

printf '%s' "$text" | grep -Eq -- '-----BEGIN ([A-Z]+ )?PRIVATE KEY-----' && tolak "private key"
printf '%s' "$text" | grep -Eq 'AKIA[0-9A-Z]{16}' && tolak "AWS access key"
printf '%s' "$text" | grep -Eq 'gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}' && tolak "token GitHub"
printf '%s' "$text" | grep -Eq 'sk-(ant-|proj-)?[A-Za-z0-9_-]{20,}' && tolak "API key model AI"
printf '%s' "$text" | grep -Eq 'xox[abprs]-[A-Za-z0-9-]{10,}' && tolak "token Slack"
printf '%s' "$text" | grep -Eiq '(api[_-]?key|secret|password|passwd|token)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9_/+.-]{12,}' && tolak "kata sandi atau key"
printf '%s' "$text" | grep -Eq '(^|[^0-9])[0-9]{16}([^0-9]|$)|(^|[^0-9])[0-9]{4}[ -][0-9]{4}[ -][0-9]{4}[ -][0-9]{4}([^0-9]|$)' && tolak "angka 16 digit (nomor kartu atau NIK)"

exit 0
