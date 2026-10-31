# Hook: pagar pengaman otomatis

Aturan di `AGENTS.md` adalah permintaan: agen biasanya patuh, tapi bisa lupa di percakapan panjang. Hook berbeda. Hook adalah skrip yang dijalankan **tool agen** pada momen tertentu, jadi agen tidak bisa melewatinya.

Aturan sederhananya: skrip keluar dengan **exit 2**, aksinya diblokir, dan pesan di stderr dibaca agen supaya ia mencari cara lain. Exit 0 berarti lanjut.

## Isi starter

| File | Momen | Yang dilakukan |
| --- | --- | --- |
| `tools/hooks/cek-rahasia.sh` | Sebelum prompt dikirim | Menolak prompt berisi private key, API key, token GitHub atau Slack, `password=…`, atau angka 16 digit (nomor kartu, NIK) |
| `tools/hooks/blokir-perintah.sh` | Sebelum agen menjalankan perintah atau mengedit file | Menolak `git push --force`, `git reset --hard`, `git clean -f`, `rm -rf`, edit langsung ke `project.pbxproj`, dan file rahasia atau signing |
| `tools/hooks/lint-setelah-edit.sh` | Setelah agen mengedit file `.swift` | Menjalankan SwiftLint pada file itu; pelanggarannya dikirim ke agen. Dilewati kalau SwiftLint belum terpasang |
| `.claude/settings.json` | | Konfigurasi untuk Claude Code |
| `.cursor/hooks.json` | | Konfigurasi untuk Cursor |

Ketiga skrip membaca JSON dari stdin dan butuh `jq` (sudah ada di macOS 15 ke atas di `/usr/bin/jq`).

## Nama momen di setiap tool

| Momen | Claude Code | Cursor |
| --- | --- | --- |
| Sebelum prompt dikirim | `UserPromptSubmit` | `beforeSubmitPrompt` |
| Sebelum perintah shell | `PreToolUse` dengan matcher `Bash` | `beforeShellExecution` |
| Sebelum atau sesudah edit file | `PreToolUse` atau `PostToolUse`, matcher Edit dan Write | `afterFileEdit` |

Copilot CLI, Codex, Kiro, dan Antigravity CLI juga punya hook dengan nama event yang berbeda. Cek dokumentasi tool kalian, lalu arahkan ke skrip yang sama. Untuk agen yang belum mendukung hook, aturan yang sama tetap ditulis di `AGENTS.md`.

## Mencoba tanpa agen

Jalankan dari folder starter di Terminal:

```bash
echo '{"tool_input":{"command":"git push --force origin main"}}' | tools/hooks/blokir-perintah.sh; echo "exit $?"
echo '{"prompt":"nomor kartu 4111 1111 1111 1111"}' | tools/hooks/cek-rahasia.sh; echo "exit $?"
```

Keduanya harus menampilkan pesan "Ditolak" dan `exit 2`.

## Menambah aturan

- Satu aturan, satu baris `grep` di skrip yang sesuai, dengan pesan yang menjelaskan apa yang harus dilakukan agen sebagai gantinya.
- Uji dengan contoh yang harus ditolak **dan** contoh yang harus lolos, supaya hook tidak menghalangi kerja normal.
- Aturan yang wajib dijadikan hook. Yang masih bisa didiskusikan tetap di `AGENTS.md`.
- Untuk tim: simpan konfigurasi hook di repo (`.claude/settings.json`, `.cursor/hooks.json`) supaya berlaku untuk semua orang. Di tingkat organisasi, Claude Code dan Cursor mendukung pengaturan yang dikelola admin.

## Sumber

- Claude Code hooks: https://code.claude.com/docs/en/hooks
- Cursor hooks: https://cursor.com/docs/hooks
