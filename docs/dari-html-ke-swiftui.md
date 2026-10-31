# Dari prototype HTML ke SwiftUI

Untuk Jumat 30 Okt, dari setup (11.40) sampai sprint 0 (13.00–13.25). Agen: Antigravity di Xcode. Skill: `html-ke-swiftui`.

Prototype HTML dari sesi Dana adalah **acuan**: isi, urutan, copy, alur dan warna. Bukan kode yang disalin. Hasilnya app iPhone native: navigasi, daftar, form dan tombol bawaan iOS, teks yang ikut setelan ukuran pengguna, dan empat state per layar.

**`docs/PRD.md` dan `docs/userflow.md` menentukan apa yang dibangun** (job story, kriteria sukses, MoSCoW). **Prototype menentukan seperti apa** (tata letak, copy). Kalau keduanya bertentangan, Product Owner yang memutuskan.

Sebelum mulai:

- Folder kelompok dari sesi Dana sudah diimpor: `bash scripts/impor-dana.sh <folder>` (README › Masih di setup). Hasilnya `prototype/index.html`, `docs/`, `DESIGN.md`, dan bagian Produk di `AGENTS.md`.
- Screenshot per layar ada di `prototype/screenshots/` (`prototype/README.md`).
- Skill sudah diimpor (`docs/mulai-di-xcode.md` langkah 4).

Contoh kecil untuk dicoba dulu: `prototype/contoh/` adalah prototype dari layar `Features/Contoh` yang sudah ada. Bandingkan HTML-nya dengan `Features/Contoh/ContohView.swift`.

## Langkah 1 · Inventaris dan celah (±10 menit)

```text
Ikuti skill html-ke-swiftui, langkah 1 (inventaris). Baca prototype/ (lihat juga gambar di
prototype/screenshots/) dan docs/userflow.md. Buat tabel: layar di prototype, langkah di userflow,
komponen di layar itu, dan komponen SwiftUI atau DesignSystem yang akan dipakai. Lalu daftar celah:
layar prototype yang tidak ada di userflow, langkah tanpa prototype, state yang tidak digambar, komponen
yang belum ada di DesignSystem, dan data yang tampak asli. Jangan ubah file apa pun.
```

Product Owner mengecek: setiap layar Must punya baris, dan setiap celah diputuskan (bangun, tunda, atau tanya Dana). Keputusan yang mengubah konteks ditempel di Miro kelompok.

## Langkah 2 · Token ke DESIGN.md dan Tokens.swift (±10 menit)

```text
Ikuti skill html-ke-swiftui, langkah 2 (token). DESIGN.md sekarang dari sesi Dana. Ambil token
warna, radius, spacing dan ukuran teks dari DESIGN.md, cek dengan yang dipakai di prototype, lalu
bandingkan dengan DesignSystem/Tokens.swift. Tampilkan tabel: token DESIGN.md, nilai, dipakai untuk apa,
nama di Swift, status (sama, baru, ubah).
Tunggu persetujuan kami sebelum mengubah file. Setelah disetujui, ubah DESIGN.md dan Tokens.swift
bersamaan, lalu build.
```

Operator mengecek: perubahan `primary` disetujui tim, nilai mode gelap ikut diisi, dan tidak ada hex di `Features/`.

## Langkah 3 · Satu layar per loop (±25 menit per layar)

Rencana dulu:

```text
/plan Ikuti skill html-ke-swiftui, langkah 3, untuk layar 01 [nama] dari prototype/01-[nama]/
dan prototype/screenshots/01-[nama].png. Rencanakan: file yang disentuh, elemen prototype ke komponen
SwiftUI native, data dummy yang dibutuhkan, dan empat state dari docs/userflow.md.
```

Setelah rencana disetujui:

```text
Kerjakan rencananya. Kalau layar ini membawa logika (state, aturan, hitungan), tulis test-nya dulu
(skill tdd-feature); tata letak saja cukup dibuktikan dengan preview. Pakai komponen DesignSystem
yang sudah ada (PrimaryButton, BarisItem, Kartu, KeadaanKosong, KeadaanGagal, BarisMemuat).
Buat empat #Preview: Berhasil, Memuat, Kosong, Gagal. Teks contoh dari prototype jadi data dummy di
Services/DataContoh.swift lewat LayananData, bukan di view. Lalu ikuti Loop Xcode di AGENTS.md:
build, test, render preview.
```

## Langkah 4 · Bandingkan dengan prototype

```text
Render preview Berhasil layar 01 dan bandingkan dengan prototype/screenshots/01-[nama].png.
Tulis dua daftar: (a) beda yang sengaja dipertahankan karena perilaku iOS, (b) beda yang perlu
diperbaiki. Cek juga preview dengan teks besar (.dynamicTypeSize(.accessibility3)) dan label
VoiceOver untuk tombol yang hanya berisi ikon. Jangan ubah kode dulu.
```

Pilih dari daftar (b), satu perbaikan per prompt. Commit setelah build dan test hijau terbaca. Lalu layar berikutnya, kembali ke langkah 3.

Beda yang wajar (daftar a): judul besar dan tombol kembali bawaan, separator daftar, font SF, ukuran teks yang mengikuti setelan, status bar asli.

## Yang biasanya meleset

| Yang terlihat | Kenapa salah | Minta ke agen |
| --- | --- | --- |
| Header buatan sendiri: judul dan tombol kembali dalam `HStack` | iOS sudah punya navigation bar: tombol kembali, swipe back, judul besar | "Ganti header buatan dengan navigationTitle dan toolbar." |
| Ukuran font angka, misalnya `.font(.system(size: 17))` | Tidak ikut Dynamic Type | "Pakai text style dari Teks di Tokens.swift." |
| Hanya state berhasil | Prototype hanya menggambar keadaan ideal | "Tambahkan state memuat, kosong dan gagal dari docs/userflow.md, masing-masing dengan #Preview." |
| Hex di view, misalnya `Color(hex: "#5E5CE6")` | Warna tersebar, mode gelap rusak | "Pindahkan ke DESIGN.md dan Tokens.swift, lalu pakai Warna." |
| `WKWebView` atau file HTML dimuat di app | Itu halaman web di dalam app, bukan app native | "Hapus WKWebView. Bangun layar ini dengan SwiftUI." |
| Daftar sebagai `VStack` di dalam `ScrollView` | Tanpa semantik `List`: separator, VoiceOver per baris, swipe | "Pakai List dengan BarisItem." |
| Lebar tetap 390 atau 358 | Rusak di iPhone lain dan saat teks diperbesar | "Hapus frame tetap, pakai maxWidth: .infinity dan padding Space." |
| Nama dan nominal dari prototype ditulis di view | Susah diganti, tidak bisa dites | "Pindahkan ke data dummy di Services/." |
| Status bar palsu, menu hamburger, breadcrumb | Pola web atau gambar prototype | "Hapus. Pakai navigasi bawaan iOS." |

Setiap kali agen meleset: satu sticky celah konteks di Miro kelompok. Kalau berulang, tambahkan aturannya ke `AGENTS.md`.

## Siapa mengerjakan apa

| Peran | Di alur ini |
| --- | --- |
| **Operator AI** | Menempel prompt, satu layar per loop. Menunjukkan tabel, diff dan preview ke tim |
| **Product Owner** | Mengecek inventaris: setiap layar prototype menempel ke satu langkah di `docs/userflow.md`. Memutuskan celah: Must atau tunda |
| **Operator AI** | Membaca diff: komponen native (`NavigationStack`, `List`, `Form`, `.sheet`, `TabView`), warna, teks, spacing dan radius dari `Tokens.swift`. Menolak hex, `WKWebView`, frame tetap |
| **Tester** | Membandingkan app di Simulator dengan prototype (screenshot dibuka di sebelahnya): isi, urutan, copy. Mengecek empat state (Edit Scheme › Run › Arguments) dan teks terbesar (Environment Overrides di debug bar Xcode). Mencatat yang meleset di Miro kelompok |

## Kalau prototype belum lengkap

- Hanya ada link: lihat `prototype/README.md` › Kalau hanya ada link.
- Satu langkah tidak punya prototype: agen membangun dari `DESIGN.md` dan `docs/userflow.md`, lalu menyebutnya di laporan.
- Prototype dan board bertentangan: scope dari board dan `docs/PRD.md`, tata letak dan copy dari prototype. Product Owner memutuskan, lalu catat di `docs/DECISIONS.md`.
