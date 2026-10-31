---
name: bug-fix-loop
description: Fix a bug or a failing build in this iOS app the disciplined way. Turns a bug report (screenshot, steps, log lines) into a failing test, a minimal root-cause fix, a verified build and a DECISIONS.md entry. Use when the user reports a bug, pastes an error or build log, says something "doesn't work", or when a previous fix attempt failed.
---

# Bug fix loop

Written for the BRI x Swift Bali workshop (Oct 2026). Reply to the user in Bahasa Indonesia.

The goal is not "make the error go away". The goal is: understand why it happens, prove it with a test, fix the cause with the smallest change, and leave a note so the next session does not undo it.

## 0. Read before touching code

1. Read `AGENTS.md`.
2. Read `DECISIONS.md` if it exists. Do not reverse a decision recorded there without asking.
3. Read only the files named in the bug report or in `AGENTS.md`. Do not scan the whole repo.

## 1. Check the bug report

A usable report has: summary, expected, actual, reproduction steps, environment (Simulator or iPhone, iOS version, commit), screenshot, the relevant log lines, related files, what was tried, and constraints. Template: `bugs/_template.md` in the repo, or `tools/templates/bug-report.md` in the facilitator package.

If something important is missing, ask for exactly those items in one short message, then stop. Typical questions:

- "Langkah mana yang membuat bug ini muncul?"
- "Tolong tempel 3 sampai 5 baris di sekitar error pertama di build log (Issue Navigator, Cmd+5)."
- "Ada screenshot layar saat bug terjadi?"

## 2. Reproduce

- **Build error:** build the project (Xcode MCP tools, MobileBuildMCP `build_sim`, or `xcodebuild`). Find the FIRST error in the log; later errors are often caused by it. Explain the cause in two sentences.
- **Runtime or UI bug:** run the app in the Simulator and follow the steps. Take a screenshot at the failing step (`xcrun simctl io booted screenshot --type=png bug-before.png`) and look at it.
- If you cannot reproduce, say so and list what you tried. Do not guess a fix.

## 3. Write a failing test first

- Use Swift Testing (`import Testing`, `@Test`, `#expect`). If the skill `tdd-bug-fix` or `swift-testing-pro` is present, follow it.
- The test must fail for the reason in the bug report, not because of a typo or missing import. Run it and show that it fails.
- If the bug is purely visual and cannot be unit tested, write down the manual check instead (which screen, which state, what should be visible).

## 4. Fix the root cause with the smallest change

Never do these to make a bug "disappear":

- `@unchecked Sendable`, `nonisolated(unsafe)`, `try!`, force unwraps added to silence errors
- editing `project.pbxproj` by hand (project settings change through Xcode's project tools or by a person in Xcode)
- deleting, skipping or weakening tests, or changing a test so it passes
- touching files listed under "Batasan" (constraints) in the report
- adding a dependency without asking

If the real fix is large or touches a shared component, stop and propose a plan first.

## 5. Verify

1. Run the new test and the existing tests. All must pass.
2. Build again. Zero errors.
3. For UI bugs: run the same steps, take `bug-after.png`, and compare with `bug-before.png`.
4. Report what you checked. Do not say "done" if you could not build or run tests; say what blocked you.

## 6. Leave a trace

Append one entry at the end of `docs/DECISIONS.md` (or `DECISIONS.md` in the repo root if there is no `docs/` folder; create it if missing):

If the file already has entries, follow their format. Otherwise:

```markdown
## <tanggal, misalnya 31 Okt 2026> · <judul singkat>

- **Keputusan:** <apa yang diubah>
- **Alasan:** <gejala, akar masalah, dan kenapa perbaikannya begini>
- **Alternatif yang ditolak:** <apa dan kenapa>
- **Dampak:** <file dan test yang terpengaruh, yang perlu diketahui sesi berikutnya>
```

Suggest a commit message in the format `apa · kenapa · dampak`, for example:
`Bawa teman terpilih ke layar Kirim link · state hilang saat navigasi · canSend kini benar`

## 7. Stop rules (save time and tokens)

- After two failed attempts at the same bug, stop. Do not try a third variation of the same idea.
- Report: your hypotheses ranked, what you ruled out, and which context is missing (spec, design token, log, API docs).
- Suggest one line for `context-gaps.md` so the team can fix the context, not the prompt.
- Keep context small: named files only, 3 to 5 log lines around the first error, one bug per session.

## Final report format (Bahasa Indonesia)

```
Akar masalah: ...
Perubahan: <file> (<ringkas>)
Bukti: test <nama> gagal lalu lulus · build bersih · screenshot sebelum/sesudah
DECISIONS.md: entri ditambahkan
Commit: <apa · kenapa · dampak>
Belum dicek: ...
```
