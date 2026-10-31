# Mulai di Xcode

Untuk Mac kelompok, sekitar 15 menit. Butuh Xcode 27 dan Mac Apple silicon. Tidak perlu Homebrew atau akun developer berbayar.

## 1. Buka proyek

Tanpa Terminal.

1. Unduh ZIP dari link/QR di grup WhatsApp (tombol hijau **Code › Download ZIP**), double-click ZIP-nya, ganti nama foldernya jadi `kelompok-N`. Atau: Xcode › Integrate › **Clone…** dengan URL dari panitia.
2. Double-click `Prototipe.xcodeproj`. Kalau Xcode bertanya karena proyek diunduh dari internet, pilih **Open**.
3. Xcode › **Integrate › New Git Repository…** › Create (tidak perlu kalau tadi Clone). Commit nanti lewat Xcode › Integrate › Commit (⌥⌘C).
4. Nama app dan bundle ID (`id.workshop.f3.kelompokN`) diganti agen lewat prompt P1 di `docs/kartu-prompt.md`, atau dengan tangan di `Config/Proyek.xcconfig` lalu ⌘B.

Mentor punya cadangan lewat Terminal (`scripts/mulai.sh`) kalau ada yang macet.

## 2. Cek kesehatan

1. Di toolbar pilih scheme **Prototipe** dan simulator iPhone terbaru di daftar (iPhone 17 Pro atau 18 Pro, tergantung versi Xcode).
2. **⌘R**: layar "Contoh" tampil dengan tiga baris.
3. **⌘U**: semua test lulus. "0 tests" berarti scheme salah.
4. Xcode › Settings › **Source Control**: matikan **Add and remove files automatically**. Supaya file berisi kunci tidak ikut ter-stage tanpa sengaja.

## 3. Pasang agen: Antigravity

Agen peserta adalah **Antigravity** (Google), dengan lisensi Gemini BRI. Claude Agent hanya dipakai fasilitator untuk demo.

1. Xcode › Settings › **Intelligence** › **Agents** › **Antigravity** › **Get** › **Install**.
2. Login: klik **…** di baris **Account**, ikuti sheet dan browser. Masuk dengan **akun Google yang membawa lisensi Gemini BRI**. (Asumsi: lisensi itu bisa dipakai di Antigravity; dicek di hari uji.)
3. **Permissions**: tambahkan `git`, `swiftlint`, `xcrun`, `mkdir`, `mdls`, `kill`, dan `sleep` di **Allowed Commands**. Tool Xcode (build, test, preview, Simulator) sudah termasuk. `xcrun` dipakai agen untuk merekam video dan mengambil screenshot Simulator (P15); tanpa ini, agen akan minta izin tiap kali atau gagal merekam.

Login gagal atau menu Intelligence kosong? Jangan lebih dari 5 menit. Beri tahu fasilitator F3, lalu pakai cadangan berurutan:

1. **Copilot for Xcode** (Copilot Business): membaca `.github/copilot-instructions.md`.
2. **Kiro** (Kiro Enterprise) lewat MCP: langkah 5 di bawah, config sudah ada di `.kiro/settings/mcp.json`.
3. **Pairing** di Mac fasilitator.

## 4. Impor skill (sekali per Mac)

1. Xcode › Settings › Intelligence › **Plug-ins** › **Add Plug-in** › impor dari folder lokal › pilih folder **`skills/`** di repo ini (45 skill).
2. Xcode membagikan skill itu ke semua agen di Xcode; untuk Antigravity, Xcode menyalinnya ke `~/Library/Developer/Xcode/CodingAssistant/gemini/.gemini/extensions/`. Jangan menyalin skill ke folder config agen dengan tangan.
3. Mengubah sebuah `SKILL.md`? Impor ulang plug-in itu (hapus lalu tambah lagi). Xcode memakai salinannya sendiri.
4. Agen di luar Xcode membaca skill dari folder lain: `bash scripts/pasang-skill.sh kiro` (atau `agents`, `claude`).

## 5. Hanya untuk agen di luar Xcode: MCP

Xcode › Settings › Intelligence › **Model Context Protocol** › nyalakan **Allow external agents to use Xcode tools**. Ini untuk Kiro, Copilot for Xcode atau Claude Code, lewat `xcrun mcpbridge` (config Kiro sudah ada di `.kiro/settings/mcp.json`, server `xcode`). Agen di dalam Xcode tidak butuh saklar ini.

## 6. Percakapan pertama

1. Pilih **Antigravity** di panel coding assistant.
2. Tanya: **"Aturan apa yang kamu baca dari repo ini?"** Jawabannya harus menyebut `GEMINI.md` dan/atau `AGENTS.md`. Kalau tidak, awali setiap prompt dengan "Baca GEMINI.md dan AGENTS.md dulu."
3. Tanya: **"Jelaskan isi proyek ini, lalu build dan jalankan test."**
4. Setiap task: mulai dengan **`/plan`** (plan mode; keluar lewat `/exit` lalu `/exit-plan`). Sebut skill-nya di prompt, misalnya "Pakai skill html-ke-swiftui." Ketik `/` untuk melihat skill bawaan Xcode.
5. Layar pertama dibangun dari prototype HTML sesi Dana: **`docs/dari-html-ke-swiftui.md`**.

## 7. Yang bisa dilakukan agen di Xcode

| Kemampuan | Tool Xcode |
| --- | --- |
| Build dan membaca build log | `BuildProject`, `GetBuildLog` |
| Menjalankan test | `RunAllTests`, `RunSomeTests` |
| Render preview, termasuk Dynamic Type besar | `RenderPreview` |
| Menjalankan app di Simulator dan menekan layarnya | `RunProject`, `DeviceInteraction…` |
| Membaca console app | `GetConsoleOutput` |
| Mengubah build setting, key Info.plist, target | `UpdateTargetBuildSetting`, `AddInfoPlist`, `XcodeNewTarget` |
| Mencari dokumentasi Apple | `DocumentationSearch` |

Urutan wajibnya ada di `AGENTS.md` › Loop Xcode. Kalau agen bilang "selesai" tanpa bukti build, test dan preview, minta buktinya.

## 8. Jalankan di iPhone (opsional, Personal Team gratis)

Simulator dan iPhone sama-sama boleh untuk showcase.

1. Xcode › Settings › **Apple Accounts** › tambah Apple ID. Muncul tim **(Personal Team)**.
2. iPhone (iOS 17+), tersambung ke Mac: Settings › Privacy & Security › **Developer Mode** › nyalakan (iPhone restart).
3. Target **Prototipe** › **Signing & Capabilities** › centang **Automatically manage signing** › Team: **(Personal Team)**.
4. Bundle ID ditolak karena sudah dipakai? Jangan ubah kolom Bundle Identifier. Tambahkan akhiran inisial di `BUNDLE_ID_DASAR` di `Config/Proyek.xcconfig` (misalnya `id.workshop.f3.kelompok3.ayu`), atau minta agen: "Tambahkan akhiran .ayu ke BUNDLE_ID_DASAR di Config/Proyek.xcconfig, lalu build."
5. Pilih iPhone di toolbar › **⌘R**. Pertama kali: iPhone › Settings › General › **VPN & Device Management** › percayai developer kalian.

Batas Personal Team: app kedaluwarsa setelah 7 hari, maksimal 3 perangkat, tanpa TestFlight. TestFlight hanya demo fasilitator.

## 9. Kalau macet

| Gejala | Coba ini |
| --- | --- |
| Menu Intelligence kosong | Kebijakan perangkat. Beri tahu fasilitator F3, pakai agen cadangan |
| Antigravity tidak bisa login | Cadangan di langkah 3: Copilot for Xcode, Kiro lewat MCP, lalu pairing di Mac fasilitator |
| Agen tidak mengikuti aturan | Tanya "Aturan apa yang kamu baca?"; awali prompt dengan "Baca GEMINI.md dan AGENTS.md dulu" |
| Skill tidak terasa dipakai | Sebut nama skill di prompt |
| "0 tests" | Pilih scheme Prototipe di toolbar |
| Preview hanya menampilkan memuat | Wajar untuk data async. Cek di Simulator (⌘R) atau lewat test |
| Error preview `__designTimeSelection` | Minta agen mengganti method reference dengan closure di view |
| Agen macet atau tidak bisa build | Salin error pertama dari Issue Navigator (⌘5) ke grup. Mentor bisa menjalankan `scripts/cek-build.sh` |
| Push gagal dari agen | Xcode › Integrate › Push |

Catat pesan error lengkap (teks, bukan foto layar kalau bisa).
