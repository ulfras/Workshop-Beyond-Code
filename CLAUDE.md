@AGENTS.md

## Khusus Claude (Claude Agent di Xcode, Claude Code)

- Di Xcode, jalankan Loop Xcode dengan tool Xcode (`BuildProject`, `RunAllTests`, `RenderPreview`, `RunProject`). Di Claude Code, pakai MCP `xcode` (`xcrun mcpbridge`, Xcode terbuka) atau `bash scripts/cek-build.sh`.
- Skill datang dari plug-in Xcode (folder `skills/`). Claude Code membaca `.claude/skills/`: jalankan `bash scripts/pasang-skill.sh claude` sekali.
- Ragu soal task atau scope? Tanya dengan satu pertanyaan singkat, jangan menebak.
