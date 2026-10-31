---
name: html-ke-swiftui
description: Membangun atau mengubah layar SwiftUI native dari prototype HTML di prototype/ (HTML+CSS biasa, Tailwind, atau React/JSX dari v0 atau Lovable), atau menarik design token (warna, radius, spacing, ukuran teks) dari prototype itu ke DESIGN.md dan DesignSystem/Tokens.swift. Pakai saat prompt menyebut prototype HTML, prototype, handoff atau hasil sesi Dana, "samakan dengan prototype", screenshot prototype, atau file .html/.css/.jsx/.tsx sebagai acuan layar. Hasilnya selalu SwiftUI native, tidak pernah web di dalam app.
---

# HTML ke SwiftUI

Dibuat untuk workshop BRI x Swift Bali (Okt 2026). Balas dalam Bahasa Indonesia.

Prototype HTML adalah **acuan** untuk isi, urutan (hierarki), copy, alur dan token. Bukan markup untuk diterjemahkan baris per baris. Hasilnya harus terasa seperti app iPhone: navigasi, daftar, form dan sheet bawaan iOS, teks yang ikut Dynamic Type, dan empat state per layar.

Skill ini dipakai di beberapa repo. Nama token, komponen dan layanan berbeda per repo: selalu pakai nama yang benar-benar ada di `DesignSystem/`, `DESIGN.md`, `Services/` dan `AGENTS.md`. Jangan memanggil komponen yang tidak ada.

## 0. Baca dulu

1. `AGENTS.md` (aturan stack, desain, state, data), `DESIGN.md`, `DesignSystem/Tokens.swift` dan komponen di `DesignSystem/`.
2. `docs/userflow.md` (langkah dan state per layar) dan `prototype/README.md`.
3. Satu layar yang sudah ada di `Features/`: pola view, model, status layar dan preview yang diikuti.
4. Prototype di `prototype/`. **Lihat** screenshot di `prototype/screenshots/`, jangan hanya membaca kodenya.
   Prototype dari sesi Dana biasanya **satu file** `prototype/index.html`: semua layar di satu halaman, ditampilkan bergantian lewat JS. Temukan tiap layar lewat judulnya, `section id`, atau fungsi navigasinya. File itu biasanya juga sudah punya state memuat, kosong dan gagal: pakai copy-nya sebagai acuan.
5. Referensi di folder skill ini: `references/pemetaan.md` (elemen HTML/CSS ke SwiftUI) dan `references/token.md` (token ke DESIGN.md dan Tokens.swift).

## 1. Aturan

**Bangun native:**

- Header atau top bar → `NavigationStack` + `.navigationTitle` + `.toolbar`. Tombol kembali bawaan, bukan buatan sendiri.
- Daftar berulang → `List`, atau `ForEach` di dalam `List`, dengan komponen baris yang sudah ada di `DesignSystem/`.
- Input → `Form`, `TextField`, `Toggle`, `Picker`, `DatePicker`.
- Modal, dialog, bottom sheet → `.sheet`, `.confirmationDialog`, `.alert`.
- Tab bar bawah → `TabView` dengan `.tabItem` (iOS 17).
- Tombol sticky di bawah → `.safeAreaInset(edge: .bottom)` berisi komponen tombol utama dari `DesignSystem/`.
- Ukuran font px → text style dari token teks (Dynamic Type). Spacing, radius, warna → token di `Tokens.swift`.
- Ikon dari icon font atau SVG → SF Symbols yang paling dekat. Jangan mengarang nama simbol.
- 1 px CSS ≈ 1 pt hanya untuk cek kewajaran. Jangan menulis frame tetap dari angka prototype.

**Jangan:**

- `WKWebView`, `import WebKit`, `SFSafariViewController`, atau memuat file HTML di app.
- Posisi absolut (`.position`, `.offset`) atau `GeometryReader` untuk meniru piksel prototype.
- Lebar tetap untuk viewport 390 px (`.frame(width: 390)`, `.frame(width: 358)`).
- Meniru efek hover, `cursor`, atau transisi CSS.
- Pola navigasi web: menu hamburger, breadcrumb, footer berisi link, status bar atau home indicator palsu.
- Hex atau ukuran font langsung di view. Tidak ada nilai warna per layar.
- Teks contoh dari prototype (nama, nominal, tanggal) ditulis langsung di view.

## 2. Langkah

### Langkah 1 · Inventaris dan celah

Jangan ubah file di langkah ini. Buat tabel:

| Layar prototype (file atau `section`) | Langkah di `docs/userflow.md` | Komponen di layar | SwiftUI atau DesignSystem |
| --- | --- | --- | --- |

Lalu daftar **celah**, satu baris per temuan:

- layar di prototype yang tidak ada di userflow (tanya: Must atau tunda?);
- langkah userflow yang tidak punya prototype (dibangun dari `DESIGN.md`, sebutkan);
- state yang tidak digambar (biasanya memuat, kosong, gagal);
- komponen yang belum ada di `DesignSystem/`;
- data yang tampak asli (nama, nomor, nominal) yang harus diganti dummy.

Daftarkan celah yang perlu keputusan tim di akhir jawaban, satu baris per celah, supaya tim bisa menempelnya di Miro. Tunggu jawaban Product Owner.

### Langkah 2 · Token dulu

1. Ambil token dari prototype sesuai `references/token.md`: CSS variable di `:root`, `tailwind.config`, `@theme`, variabel shadcn, atau hex yang berulang.
2. Bandingkan dengan `DESIGN.md` dan `Tokens.swift`. Tampilkan tabel: nilai di prototype · dipakai untuk apa · token `DESIGN.md` · nama Swift · status (sama, baru, ubah).
3. Ubah hanya yang belum ada atau berbeda jelas. Nilai yang dekat dengan token yang ada (misalnya `#5D5CE5` vs `#5E5CE6`, padding 15 vs 16) memakai token yang ada.
4. Tanya dulu sebelum mengubah warna utama atau menambah token. Setelah disetujui: ubah `DESIGN.md` dan `Tokens.swift` **bersamaan**, termasuk nilai mode gelap, lalu build.

### Langkah 3 · Satu layar per loop

1. **Rencana**: file yang disentuh (folder layar di `Features/`, data di `Services/`, rute navigasi dan flag demo kalau repo memakainya), pemetaan elemen prototype ke komponen, data dummy, dan empat state.
2. **Test hanya untuk logika.** Kalau layar ini membawa logika baru (perpindahan state, aturan, validasi, hitungan), tulis test-nya dulu di model atau `Core/` (skill `tdd-feature` atau `swift-testing-pro` kalau ada). Layar yang murni tata letak tidak butuh test baru; buktinya preview.
3. **View** dengan komponen yang sudah ada di `DesignSystem/` (lihat `AGENTS.md` dan `DESIGN.md`). Ikuti pola layar yang sudah ada di `Features/`.
4. **Empat `#Preview`**: `"Berhasil"`, `"Memuat"`, `"Kosong"`, `"Gagal"`, plus preview lain yang diwajibkan `AGENTS.md`. Prototype biasanya hanya menggambar berhasil. Tiga state lain diambil dari tabel state di `docs/userflow.md` dan dibangun dengan komponen keadaan (kosong, gagal, memuat) di `DesignSystem/`.
5. **Build dan test** sesuai Loop Xcode di `AGENTS.md` (`BuildProject`, `GetBuildLog`, `RunAllTests`).
6. **Bandingkan**: render preview Berhasil (`RenderPreview`), buka `prototype/screenshots/<layar>.png`, dan tulis dua daftar:
   - **Sengaja beda** (perilaku native): judul besar dan tombol kembali bawaan, separator `List`, ukuran teks Dynamic Type, font SF, status bar asli.
   - **Perlu diperbaiki**: isi, urutan, copy, warna, aksi utama, atau elemen yang hilang.
7. Berhenti. Satu layar per loop. Commit setelah build dan test hijau terbaca.

### Langkah 4 · Data

- Copy antarmuka (judul layar, label tombol, pesan state) boleh di view.
- Data (daftar, nama, nominal, tanggal, status) masuk data dummy di `Services/`, dilayani lewat protokol atau layanan data yang dipakai repo ini (lihat `AGENTS.md` › Data). Tidak di-hard-code di view.
- Nama atau angka yang tampak asli diganti dummy, mengikuti contoh di `AGENTS.md` (misalnya "Budi Contoh", Rp125.000). Tidak ada nomor rekening, nomor HP atau email asli.
- Nominal sebagai `Int` rupiah, tampil lewat formatter rupiah yang sudah ada di `Core/`.

## 3. Format prototype

- **HTML + CSS biasa.** Baca HTML dan file CSS-nya. Token dari `:root`. Satu file, folder atau `section` = satu layar.
- **Tailwind.** Nama class dibaca sebagai token. Baca `tailwind.config.js`/`.ts`, blok `tailwind.config = {...}` di HTML (Tailwind CDN), atau `@theme` di CSS (v4). Kalau tidak ada, pakai nilai bawaan Tailwind di `references/token.md`. Nilai arbitrer (`bg-[#5E5CE6]`, `rounded-[20px]`) juga token.
- **React/JSX (v0, Lovable).** Baca halaman dan komponen beserta props-nya. Satu page atau route = satu layar. Abaikan state library, routing, data fetching, `package.json` dan isi `components/ui/` selain sebagai petunjuk komponen. Token ada di `globals.css` atau `src/index.css` (variabel shadcn, sering HSL atau oklch; ubah ke hex dan tunjukkan hasilnya).
- **Hanya link hosted.** Jangan membuka, mengunduh atau men-scrape halamannya. Minta tim mengekspor sumbernya ke `prototype/`, atau menyimpan screenshot per layar (lebar 390 px) ke `prototype/screenshots/`. Sementara itu bekerja dari screenshot dan `DESIGN.md`.
- **Satu file HTML besar.** Pecah per `section`, `id` atau `data-screen`. Cari dulu daftar id-nya, lalu baca satu bagian per layar. Tanyakan kalau bagian mana yang menjadi langkah userflow mana tidak jelas.

Ada `.env`, kunci, atau folder integrasi backend di ekspor (misalnya `src/integrations/supabase/`)? Jangan dibaca atau disalin. Beri tahu manusia.

## 4. Cek sebelum bilang selesai

- [ ] Komponen native: `NavigationStack`, `List`, `Form`, `.sheet`, `TabView`. Tidak ada header, tab bar atau status bar buatan.
- [ ] Warna, teks, spacing dan radius dari `Tokens.swift`. Tidak ada hex di `Features/`.
- [ ] Empat preview tampil (plus preview lain yang diwajibkan `AGENTS.md`).
- [ ] Ukuran Dynamic Type terbesar yang diwajibkan `AGENTS.md` (biasanya `.dynamicTypeSize(.accessibility3)` di preview): teks tidak terpotong atau bertumpuk.
- [ ] Tombol yang hanya berisi ikon punya `.accessibilityLabel`.
- [ ] Tidak ada `WKWebView` atau `import WebKit`.
- [ ] Data dummy di `Services/`, tidak di view.
- [ ] Build bersih, semua test lulus.

Cek cepat (harus kosong):

```bash
grep -rnE "WKWebView|import WebKit|GeometryReader|\.frame\(width: *3[0-9]{2}" Features/
grep -rnE "#[0-9A-Fa-f]{6}|0x[0-9A-Fa-f]{6}|Color\(red:|\.system\(size:" Features/
```

## Format laporan

```
Layar: 01 [nama] (prototype/..., screenshots/01-[nama].png)
Token: [n] sama · [n] baru · [n] diubah (rinciannya)
File: [daftar file]
Bukti: build bersih · [n] test lulus (atau: tata letak saja, tanpa test baru) · preview dilihat · Dynamic Type terbesar dicek
Sengaja beda dari prototype: ...
Perlu diperbaiki: ...
Celah untuk docs/context-gaps.md: ...
```
