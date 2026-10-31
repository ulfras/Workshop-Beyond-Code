# Starter prototipe iOS

Titik awal untuk membangun prototipe app iOS bersama agen AI di Xcode. Starter ini membawa hasil sesi desain (job story, user flow, PRD, design system, prototype HTML) sampai menjadi layar SwiftUI native yang jalan di Simulator atau iPhone, dengan test dan aturan yang dibaca agen.

Isinya: proyek Xcode `Prototipe.xcodeproj` yang langsung jalan, satu layar contoh dengan empat state, test, aturan untuk agen (`AGENTS.md`, `GEMINI.md`), 45 skill, dan template konteks di `docs/`. Data dummy saja; Supabase opsional.

Hasil sesi desain masuk ke sini: prototype HTML ke `prototype/`; job story, prioritized flow, feature scope dan kriteria sukses ke `docs/`; design system ke `DESIGN.md`. Prototype menjadi layar SwiftUI native lewat `docs/dari-html-ke-swiftui.md`.

## Mulai dalam 3 langkah

Tanpa Terminal. Cukup Finder, Xcode, dan agen.

1. **Unduh.** Buka halaman repo ini di GitHub, klik tombol hijau **Code › Download ZIP**, double-click ZIP-nya di Downloads, lalu ganti nama foldernya jadi `kelompok-N` (N = nomor kelompok). Cukup di **satu Mac** per kelompok.
2. **Buka dan jalankan.** Double-click `Prototipe.xcodeproj` (kalau Xcode bertanya karena proyek diunduh dari internet, pilih **Open**). Pilih simulator iPhone terbaru di daftar, **⌘R**: layar "Contoh" tampil. **⌘U**: semua test lulus.
3. **Nyalakan git.** Xcode › **Integrate › New Git Repository…** › Create. Setelah itu commit lewat Xcode › Integrate › Commit (⌥⌘C).

Lalu, **sekali per Mac**, impor skill: Xcode › Settings › Intelligence › **Plug-ins** › **Add Plug-in** › folder lokal › pilih folder `skills/` di repo ini. Xcode membagikannya ke semua agen di Xcode. Langkah lengkap (agen, login, izin, iPhone): **`docs/mulai-di-xcode.md`**.

## Masih di setup

4. **Masukkan folder kelompok dari sesi desain.** Folder itu berisi `AGENTS.md`, `DESIGN.md`, `docs/` (job story, user flow, PRD, tasks) dan `prototype/index.html`. Di Finder, buka folder hasil desain dan folder repo ini berdampingan. Untuk docs: buka folder `docs/` dari sesi desain, ⌘A, lalu seret **isinya** ke folder `docs/` repo ini. **Jangan seret folder `docs/`-nya**: Replace akan menghapus dokumen starter (kartu prompt, DECISIONS.md, panduan Xcode). Kalau Finder bertanya, centang Apply to All, lalu **Replace**. Setelah itu seret **`DESIGN.md`** dan folder **`prototype/`**; keduanya boleh diganti. `AGENTS.md` dari sesi desain jangan diseret: minta agen menyalin bagian **Produk**-nya (prompt P1). Detail dan kalau prototype-nya hanya link: `prototype/README.md`.
5. **Temuan uji cepat jadi task pertama.** Temuan terbesar dari uji cepat di akhir sesi desain ditulis sebagai task paling atas di `docs/tasks.md`, lengkap dengan cek penerimaannya.
6. **Token dari DESIGN.md.** Minta agen: "Perbarui `DesignSystem/Tokens.swift` dari `DESIGN.md`. Pakai skill html-ke-swiftui, references/token.md. Tunjukkan tabel nilai lama dan baru sebelum mengubah, lalu build."
7. **Prompt pertama: P1** di `docs/kartu-prompt.md`. Agen mengganti nama app dan bundle ID di `Config/Proyek.xcconfig`, menyalin bagian Produk dari `AGENTS.md` sesi desain, lalu menjawab "Aturan apa yang kamu baca?" (jawabannya menyebut `GEMINI.md` atau `AGENTS.md`).

Folder dari sesi desain belum ada? Lihat **`contoh-sesi-desain/`**: contoh lengkap hasil sesi desain (Tagih teman) termasuk prototype HTML. Bisa dipakai sebagai titik awal, lalu ganti dengan folder kalian begitu sampai.

Lalu bangun layar dari prototype, satu layar per loop: **`docs/dari-html-ke-swiftui.md`**.

Sprint 0 selesai kalau: satu layar inti dari user flow dan prototype, satu preview per state di tabel userflow, tampil saat ⌘R di Simulator, dan minimal satu celah konteks di Miro kelompok.

## Peta repo

**Untuk orang**

```
README.md                  file ini
docs/mulai-di-xcode.md     setup Mac kelompok: proyek, agen, skill, izin, iPhone
docs/cara-kerja-tim.md     peran, rotasi, git, merge conflict, linimasa
docs/dari-html-ke-swiftui.md  prototype HTML ke layar SwiftUI: empat langkah, prompt, peran
docs/kartu-prompt.md       prompt P0–P16 siap salin, nomornya sama dengan di slide
docs/hooks.md              hook: pagar pengaman otomatis untuk agen (tools/hooks/)
contoh-sesi-desain/        contoh lengkap hasil sesi desain (Tagih teman): docs, DESIGN.md, prototype HTML
prototype/                 prototype HTML dari sesi desain + screenshots/ (sekarang berisi contoh)
docs/supabase-opsional.md  jalur Supabase, setelah alur utama jalan
docs/job-story.md          job story dan kriteria sukses (dari sesi desain)
docs/PRD.md                produk, feature scope MoSCoW, kriteria sukses
docs/userflow.md           layar dan empat state per layar
docs/tasks.md              task berurutan dengan cek penerimaan
docs/DECISIONS.md          kenapa sebuah perubahan dibuat
DESIGN.md                  design system: token YAML + aturan (isian kelima blueprint)
bugs/                      bug report untuk agen (salin bugs/_template.md)
```

**Untuk agen**

```
AGENTS.md                  aturan untuk semua agen, satu sumber. Isi bagian Produk
GEMINI.md                  dibaca Antigravity lebih dulu: aturan inti, lalu AGENTS.md
CLAUDE.md                  mengimpor AGENTS.md untuk Claude
.github/copilot-instructions.md   salinan aturan inti untuk Copilot
.kiro/steering/ .kiro/settings/mcp.json   aturan tambahan dan MCP untuk Kiro
.mobilebuildmcp/config.yaml        MobileBuildMCP untuk agen di luar Xcode
skills/                    45 skill; diimpor sekali per Mac sebagai plug-in Xcode
```

**Kode dan proyek**

```
Prototipe.xcodeproj        proyek Xcode, di-commit; jangan diedit dengan tangan
Config/                    Proyek.xcconfig (nama app, bundle ID, sumber data), Supabase.example.xcconfig
App/                       entry point, navigasi, Info.plist
Core/                      StatusMuat, Rupiah, Rute, model
DesignSystem/              Tokens.swift dan komponen
Features/Contoh/           layar contoh: pola yang diikuti agen. Ganti dengan layar kalian
Services/                  LayananData (protokol), LayananDummy (default), LayananSupabase, SumberData, DemoFlags
Tests/                     Swift Testing
supabase/                  migration dan data dummy untuk jalur opsional
scripts/                   cadangan lewat Terminal: mulai.sh, impor-dana.sh, cek-build.sh, cek-rahasia.sh, simulator-demo.sh, pasang-skill.sh
```

Nama target dan scheme tetap "Prototipe"; nama yang tampil di layar adalah nama app kalian (`NAMA_APP`).

## File aturan per agen

| Agen | File aturan | Skill |
| --- | --- | --- |
| **Antigravity di Xcode** | `GEMINI.md`, lalu `AGENTS.md` | Plug-in Xcode dari `skills/` |
| Claude Agent, Codex di Xcode | `AGENTS.md` (Claude lewat `CLAUDE.md`) | Plug-in Xcode dari `skills/` |
| Kiro | `AGENTS.md` langsung, plus `.kiro/steering/` dan MCP di `.kiro/settings/mcp.json` | `bash scripts/pasang-skill.sh kiro` |
| Copilot for Xcode | `.github/copilot-instructions.md`. Setiap `AGENTS.md` berubah, samakan bagian "Aturan inti" | Sebut isi skill di prompt |
| Claude Code, Copilot CLI, Gemini CLI | `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | `bash scripts/pasang-skill.sh claude` atau `agents` |

Menurut dokumentasi komunitas, Antigravity membaca `GEMINI.md` lalu `AGENTS.md`; di dalam Xcode diasumsikan sama. Kalau jawabannya tidak menyebut keduanya, awali prompt dengan "Baca GEMINI.md dan AGENTS.md dulu." Skill jarang dipakai kalau tidak disebut; tulis namanya di prompt, misalnya "ikuti skill bug-fix-loop".

Kalau agen meleset: satu sticky celah konteks di Miro kelompok (agen salah apa, konteks apa yang ditambahkan), lalu perbaiki aturannya di `AGENTS.md` (bukan di prompt).

## Memaksa state untuk uji dan screenshot

Di Xcode: Product › Scheme › Edit Scheme › Run › Arguments, centang `-demoContoh gagal` (atau `memuat`, `kosong`). Untuk layar baru: tambahkan `case` di `Services/DemoFlags.swift`, lalu tambahkan argument-nya di Edit Scheme dengan tombol +.

Dari Terminal (setelah app pernah dijalankan dengan ⌘R):

```bash
bash scripts/simulator-demo.sh rapikan                   # status bar 9:41
bash scripts/simulator-demo.sh paksa demoContoh gagal    # app dengan state dipaksa
bash scripts/simulator-demo.sh rekam marketing/video/demo.mov
```

## Aturan repo

- Satu task, satu commit, setelah test terbaca hijau. Pesan commit: apa · kenapa · dampak.
- `Prototipe.xcodeproj` di-commit seperti file lain, tapi tidak diedit dengan tangan.
- Jangan commit data nasabah, kunci, `Config/Supabase.xcconfig` atau `.env`. `scripts/cek-rahasia.sh` menolaknya sebelum commit.
- Cadangan kalau agen macet: `bash scripts/cek-build.sh` (build + test dari Terminal).
- Hasil screenshot dan video agen masuk `marketing/` (tidak di-commit).

## Baca berikutnya

1. `docs/mulai-di-xcode.md`: setup Mac kelompok.
2. `docs/cara-kerja-tim.md`: peran dan rotasi sebelum sprint 0.
3. `docs/dari-html-ke-swiftui.md`: dari prototype HTML ke layar SwiftUI.
4. `AGENTS.md`: aturan yang dibaca agen. Isi bagian Produk.
5. `docs/supabase-opsional.md`: hanya setelah alur utama jalan dengan dummy.

## Sumber dan lisensi skill

Skill di `skills/` ditulis oleh penulisnya masing-masing dan disalin apa adanya dari repo asalnya, pada commit yang tercatat di `skills/SKILLS.lock`. Lisensi tiap skill ada di foldernya (`LICENSE.upstream`, `LICENSE.txt`); ringkasan sumber dan lisensi di `skills/README.md`. Sebagian besar MIT; `skill-creator` Apache 2.0; `remotion-best-practices` memakai Remotion License. Satu contoh kunci palsu di `swift-security-expert` disamarkan supaya tidak terbaca sebagai rahasia.
