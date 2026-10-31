@./AGENTS.md

<!-- Baris @./AGENTS.md di atas mengimpor AGENTS.md untuk Gemini CLI. Kalimat di bawah untuk Antigravity, kalau impor tidak diproses.
     Antigravity membaca GEMINI.md lebih dulu dan GEMINI.md menang kalau bertentangan dengan AGENTS.md (dokumentasi komunitas; di Xcode diasumsikan sama, cek di hari uji).
     Jadi file ini hanya ringkasan AGENTS.md. Jangan menulis aturan yang berbeda di sini; kalau AGENTS.md berubah, samakan daftar di bawah. -->

Baca dan ikuti AGENTS.md di root repo ini sebelum mulai. Kalau prompt bertentangan dengan `AGENTS.md`, ikuti `AGENTS.md` dan tanyakan. Jawab dalam Bahasa Indonesia.

## Khusus Antigravity (Gemini) di Xcode

Aturan terpenting dari `AGENTS.md`, ringkas:

1. **Rencana dulu.** Sebelum menulis kode: file yang disentuh dan cara mengecek hasilnya. Satu task per kali, diff kecil.
2. **Loop Xcode setelah setiap perubahan:** build (`BuildProject`, lalu baca `GetBuildLog`), test (`RunAllTests`), render preview (`RenderPreview`), Simulator untuk alur. Bilang "selesai" hanya dengan bukti.
3. **Jangan edit `project.pbxproj` dengan tangan.** File Swift baru cukup dibuat di folder yang benar; folder itu otomatis masuk target.
4. **Data dummy saja.** Tidak ada data nasabah, nomor rekening asli, API key atau secret.
5. **Empat state per layar:** berhasil, memuat, kosong, gagal, masing-masing dengan `#Preview`.
6. **Prototype HTML di `prototype/` adalah acuan, bukan markup.** Ikuti skill `html-ke-swiftui`: SwiftUI native dengan token dari `DesignSystem/Tokens.swift`. Jangan `WKWebView`.

Ditanya "Aturan apa yang kamu baca dari repo ini?": sebutkan `GEMINI.md` dan `AGENTS.md`, lalu enam poin di atas.

Gemini CLI (di luar Xcode): build dan test lewat MCP `xcode` (`xcrun mcpbridge`, Xcode terbuka) atau `bash scripts/cek-build.sh`.
