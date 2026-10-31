# Kartu prompt · F3

Nomor P di slide menunjuk ke prompt di file ini. Salin, ganti bagian dalam [kurung siku] dengan milik kelompok kalian, lalu tempel ke agen.

- Satu prompt, satu task. Percakapan baru untuk task berikutnya.
- Operator AI menulis peran saat ini di awal prompt, misalnya "Operator: Ayu · Tester: Dedi · Product Owner: Sari".
- Agen gagal dua kali dengan prompt yang sama? Berhenti. Kembali ke commit hijau terakhir, cari konteks yang kurang, atau angkat tangan.

Contoh di bawah memakai app "Tagih teman". Ganti nama layar, file dan task dengan milik kelompok kalian.

| ID | Prompt | Kapan |
| --- | --- | --- |
| P0 | Board ke docs/ (cadangan) | Setup, kalau folder dari sesi Dana belum lengkap |
| P1 | Nama app dan cek konteks | Setup, sebelum prompt kerja pertama |
| P2 | Inventaris prototype | Sprint 0 |
| P3 | Token ke DESIGN.md | Sprint 0, sekali |
| P4 | Rencana dulu | Setiap task |
| P5 | Satu layar dari prototype | Sprint 0 dan seterusnya |
| P6 | Bandingkan dengan screenshot | Setelah P5 |
| P7 | Test dulu, baru kode | Sprint 1 dan 2 |
| P8 | Build gagal: baca log | Kapan saja build merah |
| P9 | Jelaskan diff | Sebelum commit |
| P10 | Aksesibilitas | Sprint 2 |
| P11 | Agen sebagai tester | Uji silang |
| P12 | Temuan teratas jadi bug report dan task | Uji silang |
| P13 | Bug report ke agen | Sabtu, perbaikan |
| P14 | Log keputusan | Setiap perubahan perilaku |
| P15 | Screenshot dan video demo | Sabtu, persiapan showcase |
| P16 | Cek dokumentasi Apple | Sebelum memakai API baru |

## Setup

**P0 · Board ke docs/ (cadangan).** Hanya kalau folder dari sesi Dana belum lengkap. Foto board kelompok, lampirkan ke agen.

```text
Ini foto board kelompok kami dari sesi Dana: job story, ide terpilih, irisan alur dengan state wajib, MoSCoW, asumsi, dan dua kriteria sukses. Salin isinya ke docs/job-story.md, docs/PRD.md (Feature scope MoSCoW dan Kriteria sukses), docs/userflow.md (langkah dan state per layar) dan docs/tasks.md (satu task per langkah Must, dengan cek penerimaan). Pakai format template yang ada. Jangan menambah apa pun yang tidak ada di foto. Kalau tulisan tidak terbaca, tulis [?]. Jangan ubah kode. Tampilkan ringkasannya untuk kami cek.
```

**P1 · Nama app dan cek konteks.** Setelah folder Dana diseret ke repo (docs/, DESIGN.md, prototype/).

```text
Sebelum mulai: aturan apa yang kamu baca untuk proyek ini? Sebutkan file-nya dan tiga aturan terpenting.
Lalu: (1) di Config/Proyek.xcconfig ganti NAMA_APP jadi "[Nama App]" dan BUNDLE_ID_DASAR jadi id.workshop.f3.kelompok[N], lalu build. (2) Salin bagian "Produk" dari [path AGENTS.md Dana, misalnya ~/Desktop/kelompok-3-dana/AGENTS.md] ke bagian Produk di AGENTS.md repo ini; bagian lain jangan diubah. (3) Ringkas docs/job-story.md dan docs/PRD.md dalam tiga kalimat, termasuk baris Won't dan dua kriteria sukses. Kalau ada yang kosong atau tidak jelas, daftarkan di akhir jawaban, satu baris per celah, supaya bisa kami tempel di Miro kelompok. Jangan ubah file Swift.
```

Jawaban yang benar menyebut AGENTS.md (dan GEMINI.md). Kalau tidak, konteksnya belum terbaca: angkat tangan. Setelah build hijau: Xcode › Integrate › Commit.

## Dari prototype HTML ke SwiftUI

HTML adalah acuan isi, hierarki, teks, alur dan token. Bukan markup untuk disalin. Panduan lengkap: docs/dari-html-ke-swiftui.md.

**P2 · Inventaris prototype.**

```text
Pakai skill html-ke-swiftui, langkah 1. Baca docs/dari-html-ke-swiftui.md, file di prototype/ dan screenshot di prototype/screenshots/. Buat inventaris: layar, urutan alur, komponen dan teks per layar, dan token (warna, font, jarak, radius). Cocokkan dengan docs/userflow.md dan docs/tasks.md. Daftarkan celahnya di akhir jawaban, satu baris per celah, supaya bisa kami tempel di Miro kelompok: state memuat, kosong atau gagal yang tidak ada di prototype, dan layar yang ada di satu tempat tapi tidak di tempat lain. Jangan ubah kode.
```

**P3 · Token ke DESIGN.md.** Sekali saja.

```text
Pakai skill html-ke-swiftui, langkah 2. Ambil token dari prototype (CSS variable, config Tailwind atau theme) dan tulis ke DESIGN.md, lalu perbarui DesignSystem/Tokens.swift supaya mengikuti DESIGN.md. Ukuran font dipetakan ke text style Dynamic Type (.title, .headline, .body), bukan angka px. Warna jadi token bernama, tidak ditulis langsung di layar. Tampilkan tabel: nilai di HTML, token di DESIGN.md, nama di Tokens.swift.
```

**P4 · Rencana dulu.** Tempel brief empat baris kalian.

```text
/plan
Tujuan: [apa yang harus selesai, satu kalimat]
Konteks: [file, layar, task di docs/tasks.md, screenshot]
Batasan: [yang tidak boleh diubah atau ditambah]
Selesai kalau: [build bersih, test lulus, preview tiap state, yang terlihat di layar]

Baca AGENTS.md dan DESIGN.md. Buat rencana untuk brief ini saja: file yang dibuat atau diubah, dan cara kamu memeriksa hasilnya. Jangan menulis kode dulu. Tanyakan saya mengenai [bagian yang belum jelas, misalnya aturan pembulatan atau isi state gagal] satu per satu, dengan rekomendasimu. Jangan menebak.
```

Product Owner membaca rencananya dan mencoret yang di luar scope. Kalian yang memutuskan.

**P5 · Satu layar dari prototype.**

```text
Pakai skill html-ke-swiftui, langkah 3. Bangun layar [Pilih teman] ([T4] di docs/tasks.md) dari prototype/[file] dan prototype/screenshots/[nama].png. Jangan menyalin struktur div. Pakai komponen native: NavigationStack dengan navigationTitle, List atau Form, sheet, safeAreaInset untuk tombol yang menempel di bawah, text style Dynamic Type dan token dari Tokens.swift. Jangan pakai WKWebView. Prototype hanya menunjukkan state berhasil: state memuat, kosong dan gagal (beserta teksnya) ambil dari tabel state di docs/userflow.md. Buat satu #Preview per state di tabel itu (state "Tidak ada" dilewati). Pastikan layar ini tampil saat ⌘R: kalau layar sebelumnya belum ada, jadikan layar pertama sementara di App/PrototipeApp.swift. Lalu jalankan Loop Xcode dari AGENTS.md.
```

**P6 · Bandingkan dengan screenshot.**

```text
Pakai skill html-ke-swiftui, langkah 4. Render preview state berhasil layar [Pilih teman] dan bandingkan dengan prototype/screenshots/[nama].png. Daftar bedanya: isi, urutan, teks, warna, jarak. Pisahkan beda yang wajar karena pola iOS (judul navigasi, list bawaan, Dynamic Type) dari beda yang salah. Perbaiki yang salah saja. Tidak perlu sama persis per piksel.
```

Ulangi P5 dan P6 untuk setiap layar, satu layar per loop. Layar yang tidak ada di prototype: P4 dengan task dari docs/tasks.md.

## Membangun task

**P7 · Test dulu, baru kode.**

```text
Kerjakan [T5] di docs/tasks.md. Tulis test Swift Testing dulu untuk [SplitCalculator.bagi(total:orang:)] dengan kasus dari cek penerimaan task itu, misalnya [Rp100.000 untuk 3 orang: perTeman 33.334, pengirim 33.332; jumlah semua bagian sama dengan total]. Jalankan test dan pastikan gagal. Setelah itu implementasikan sampai lulus. Jangan mengubah test supaya lulus. Ikuti Loop Xcode dari AGENTS.md.
```

**P8 · Build gagal: baca log.**

```text
Build gagal. Baca build log lengkapnya, cari error pertama, dan jelaskan penyebabnya dalam dua kalimat. Perbaiki dengan perubahan sekecil mungkin. Jangan pakai @unchecked Sendable, nonisolated(unsafe), atau mengedit project.pbxproj; kalau build setting atau Info.plist perlu diubah, pakai tool Xcode. Build ulang sampai bersih.
```

Agen tanpa akses tool Xcode tidak bisa membaca log sendiri. Salin 3 sampai 5 baris di sekitar error pertama dari Issue Navigator (⌘5).

**P9 · Jelaskan diff.** Sebelum commit; Operator menjelaskan ke tim, Product Owner memutuskan.

```text
Jelaskan diff ini sebelum saya commit: file apa yang berubah, kenapa, dan apa risikonya. Tandai bagian yang tidak diminta di task ini.
```

**P10 · Aksesibilitas.**

```text
Cek aksesibilitas layar [Pilih teman]. Render preview state berhasil di ukuran teks .accessibility3: tidak boleh ada teks atau nominal yang terpotong. Tambahkan label VoiceOver untuk tombol ikon. Cek kontras teks di atas warna brand, target sentuh minimal 44 point, dan warna bukan satu-satunya penanda status. Laporkan yang gagal dulu, lalu perbaiki satu per satu dengan perubahan kecil.
```

**P16 · Cek dokumentasi Apple.**

```text
Sebelum memakai API yang belum ada di proyek ini, cari dulu di dokumentasi Apple (DocumentationSearch atau sosumi). Sebutkan nama API, versi iOS minimumnya, dan sumbernya. Kalau butuh iOS lebih baru dari 17, beri tahu saya dulu.
```

## Uji silang

**P11 · Agen sebagai tester.**

```text
Jalankan app di Simulator dari build terbaru. Ikuti docs/userflow.md langkah demi langkah, ambil screenshot tiap langkah, dan laporkan langkah yang hilang, buntu, atau state yang tidak muncul. Jangan mengubah kode. Laporkan setiap temuan di jawaban, satu baris per temuan (layar · yang dilakukan · yang terjadi), supaya bisa kami tempel di Miro kelompok.
```

Agen melihat yang absolut: tombol ada atau tidak, state muncul atau tidak. Rasa (cepat, jelas, tidak canggung) dinilai manusia. Temuan agen adalah dugaan sampai dibuktikan.

**P12 · Temuan teratas jadi bug report dan task.** Temuan uji silang ditempel di Miro dulu, satu sticky per temuan. Yang teratas saja yang ditulis ke repo.

```text
Ini temuan teratas dari Miro kelompok kami, hasil uji silang: "[penguji melakukan apa, di layar mana, apa yang terjadi]" [lampirkan screenshot]. Tulis sebagai bugs/[nama-singkat].md dengan format bugs/_template.md. Lalu tambahkan satu task di docs/tasks.md yang menunjuk file itu, dengan cek penerimaan. Jangan dikerjakan dulu. Kalau temuannya menunjukkan konteks yang kurang, sebutkan konteks apa, supaya kami tempel di Miro.
```

Catat yang terjadi, bukan pendapat. "Alurnya ribet" bukan temuan. "Penguji kembali ke layar Pilih teman tiga kali sebelum menemukan tombol Lanjut" adalah temuan.

## Sabtu

**P13 · Bug report ke agen.**

```text
Ikuti skill bug-fix-loop untuk bugs/[nama-singkat].md. Tulis test yang gagal untuk bug ini dulu, perbaiki akar masalahnya dengan perubahan sekecil mungkin, jangan bungkam error-nya. Jalankan Loop Xcode dari AGENTS.md dan laporkan hasilnya apa adanya.
```

Bug report yang lengkap punya: ringkasan, yang diharapkan dan yang terjadi, langkah reproduksi, lingkungan dan commit, screenshot, 3 sampai 10 baris log, file terkait, dan batasan.

**P14 · Log keputusan.** Tambahkan di akhir prompt yang mengubah perilaku.

```text
Setelah selesai, tambahkan satu entri di docs/DECISIONS.md: apa yang diubah, kenapa, alternatif yang ditolak. Tulis pesan commit dengan format: apa · kenapa · dampak.
```

**P15 · Screenshot dan video demo.**

```text
Buat 3 screenshot gaya App Store dan 1 video demo 20–30 detik dari layar pertama sampai layar terakhir yang jalan di app ini. Baca AGENTS.md, lalu ikuti skill app-demo-media. Simulator, status bar 9:41, data dummy saja. Headline Bahasa Indonesia, maksimal 5 kata, tentang manfaat. Jangan upload apa pun. Jangan pasang tool global tanpa bertanya.
```

Hasilnya di marketing/raw/ (screenshot), marketing/framed/ (kalau skill framing tersedia), dan marketing/video/demo-raw.mov.

Sebelum P15, pastikan `xcrun`, `mkdir`, `mdls`, `kill`, dan `sleep` ada di Allowed Commands agen (Xcode › Settings › Intelligence › Permissions; lihat docs/mulai-di-xcode.md langkah 3). Simulator harus sudah jalan dari ⌘R terakhir. Agen pertama membaca docs/userflow.md untuk tahu alur yang direkam.

Agen gagal merekam? Cadangan tanpa agen: di jendela Simulator (Device Hub) ada tombol rekam dan tombol screenshot di toolbar bawah. Satu orang menjalankan alur 20–30 detik, lalu simpan file-nya ke marketing/video/.

## Kalau agen meleset

Jangan langsung menulis prompt yang lebih panjang. Cari konteks yang kurang, perbaiki di file, lalu minta ulang. Catat celahnya di Miro kelompok, satu sticky: agen salah apa · konteks yang kurang · perbaikan · berhasil?

| Gejala | Perbaikan |
| --- | --- |
| API lama (ObservableObject, NavigationView, foregroundColor) | Sebut skill di prompt ("Pakai skill swiftui-pro"); cek plug-in skills/ sudah diimpor |
| Warna atau font beda dari desain | Perbaiki token di DESIGN.md dan Tokens.swift, bukan di layar |
| Fitur ditambah sendiri | Tulis baris Won't di PRD.md; tolak diff-nya |
| State kosong atau gagal tidak ada | Isi tabel state di userflow.md |
| Layar meniru web atau dibungkus WKWebView | Tolak diff-nya (git restore), jalankan P3, lalu ulangi P5 |
| Bilang selesai padahal build gagal | "Ikuti Loop Xcode di AGENTS.md dan tunjukkan buktinya" |
| Mengedit project.pbxproj | git restore file itu; tanya "Aturan apa yang kamu baca?" |
| Gagal dua kali | Berhenti. Kembali ke commit hijau, angkat tangan |

Minta bantuan: F3 untuk build, agen dan signing. F2 untuk alur dan UI. F1 untuk scope.
