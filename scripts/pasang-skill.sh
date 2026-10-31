#!/bin/bash
# Salin skill dari skills/ ke folder yang dibaca agen di LUAR Xcode.
# Agen di dalam Xcode (Claude Agent, Codex, Antigravity) TIDAK butuh ini: impor folder skills/
# sekali per Mac sebagai plug-in (docs/mulai-di-xcode.md, langkah 4).
#
# Pemakaian:
#   bash scripts/pasang-skill.sh kiro      ke .kiro/skills/    (Kiro)
#   bash scripts/pasang-skill.sh agents    ke .agents/skills/  (Copilot CLI, Codex CLI, Gemini CLI)
#   bash scripts/pasang-skill.sh claude    ke .claude/skills/  (Claude Code)
#   tambahkan --semua untuk ikut menyalin grup expert, ship dan meta (default: grup workshop saja)
#
# Salinan ini tidak di-commit (.gitignore). Ubah skill di skills/, lalu jalankan script ini lagi.
set -euo pipefail
cd "$(dirname "$0")/.."

bantuan() { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

TUJUAN=""
SEMUA=0
for arg in "$@"; do
  case "$arg" in
    kiro) TUJUAN=".kiro/skills" ;;
    agents) TUJUAN=".agents/skills" ;;
    claude) TUJUAN=".claude/skills" ;;
    --semua) SEMUA=1 ;;
    *) bantuan ;;
  esac
done
[ -n "$TUJUAN" ] || bantuan
[ -f skills/SKILLS.lock ] || { echo "skills/SKILLS.lock tidak ada. Folder skills/ tidak utuh."; exit 1; }

mkdir -p "$TUJUAN"
JUMLAH=0
while IFS="$(printf '\t')" read -r nama grup _; do
  case "$nama" in ''|'#'*) continue ;; esac
  if [ "$SEMUA" -eq 0 ]; then
    case "$grup" in plan|design|core|bri|debug|run|qa|media) ;; *) continue ;; esac
  fi
  [ -f "skills/$nama/SKILL.md" ] || { echo "  ! skills/$nama tidak ada, dilewati"; continue; }
  rm -rf "${TUJUAN:?}/$nama"
  cp -R "skills/$nama" "$TUJUAN/$nama"
  JUMLAH=$((JUMLAH + 1))
done < skills/SKILLS.lock

echo "✓ $JUMLAH skill disalin ke $TUJUAN/"
echo "  Di prompt, sebut nama skill-nya, misalnya: \"Ikuti skill bug-fix-loop untuk bugs/<nama>.md\"."
