---
name: "BRImo"
colors:
  primary: "#00529C"
  on-primary: "#FFFFFF"
  accent: "#DF5A09"
  background: "#FFFFFF"
  surface: "#F1F5F9"
  text: "#020618"
  text-secondary: "#5B6B84"
  separator: "#E5E5EA"
  success: "#167F3E"
  warning: "#C93400"
  danger: "#DE0C00"
  header: "#00529C"
  header-deep: "#003872"
  on-header: "#FFFFFF"
typography:
  title:
    fontFamily: "SF Pro"
    fontSize: 34
    fontWeight: 700
  heading-lg:
    fontFamily: "SF Pro"
    fontSize: 22
    fontWeight: 700
  heading:
    fontFamily: "SF Pro"
    fontSize: 20
    fontWeight: 700
  body:
    fontFamily: "SF Pro"
    fontSize: 17
    fontWeight: 400
  caption:
    fontFamily: "SF Pro"
    fontSize: 15
    fontWeight: 400
  label:
    fontFamily: "SF Pro"
    fontSize: 13
    fontWeight: 600
rounded:
  sm: 8
  md: 14
  lg: 20
  button: full
spacing:
  scale: [4, 8, 16, 24, 32]
---

# DESIGN.md · BRImo

<!-- Isian kelima blueprint Dana: design system. Format DESIGN.md: token YAML di atas, prosa di bawah. Default starter ini memakai design system Apple sebagai platform dan satu aksen brand, sama seperti contoh di demo Dana. Bukan aset BRI.
Yang boleh diubah tim: warna primary (aksen), nada di Overview, dan aturan di Do's and Don'ts. Ubah juga DesignSystem/Tokens.swift bersamaan, lalu minta agen membaca ulang AGENTS.md. Hapus komentar ini setelah diisi. -->

## Overview

[Tiga kalimat: nada produk, apa yang selalu tampil besar, apa yang tidak boleh terjadi. Contoh: Tenang, jelas, terpercaya. Uang selalu tampil besar, tanpa desimal. Satu aksi utama per layar.]

## Colors

Sumber: screenshot prototype Lovable di `prototype/screenshots/` (1-beranda sampai 7-berhasil-pin). Sumber CSS belum diekspor, jadi hex diambil dari piksel screenshot, lalu `accent`, `success`, `text-secondary` dan `danger` digelapkan sedikit supaya lolos kontras WCAG AA (teks 4,5:1, ikon dan grafis 3:1) di mode terang dan gelap. Alasannya di `docs/DECISIONS.md`.

- `primary` (`Warna.utama`, biru BRI) untuk aksi utama: tombol utama, titik PIN, nominal besar, garis field yang sedang aktif. Bukan untuk kartu atau header (header memakai `header`).
- `on-primary` (`Warna.utamaTeks`) untuk semua teks dan ikon di atas `primary`. Di mode gelap nilainya biru tua, bukan putih, karena `primary` gelap berwarna biru muda.
- `accent` (`Warna.aksen`, oranye) hanya untuk isian, ikon dan garis: aksi cepat Transfer, ikon perisai, garis dan ikon banner. **Tidak untuk teks**: kontrasnya cukup untuk grafis, tidak untuk teks kecil. Judul banner memakai `Warna.teks`.
- Ikon di atas isian `success` atau `accent` (centang di lingkaran sukses, ikon Transfer) memakai `Warna.latar`.
- Varian lembut memakai opacity, bukan warna baru: chip nominal dan latar aksi cepat `Warna.utama.opacity(0.1)`, latar banner `Warna.aksen.opacity(0.1)`, latar ikon peringatan `Warna.aksen.opacity(0.15)`, garis banner `Warna.aksen.opacity(0.4)`. Teks chip `Warna.utama`.
- Field input: latar `Warna.permukaan`; saat aktif diberi garis `Warna.utama`.
- `background` (`Warna.latar`, putih) untuk latar layar, `surface` (`Warna.permukaan`, abu kebiruan) untuk kartu, kotak rekening tujuan, field, tombol keypad PIN dan kartu rincian transaksi.
- `text` dan `text-secondary` (`Warna.teks`, `Warna.teksSekunder`) untuk teks. `teksSekunder` lolos 4,5:1 di atas latar, permukaan, chip dan banner. `separator` (`Warna.garis`) untuk pemisah dan tombol nonaktif.
- `success`, `warning`, `danger` (`Warna.sukses`, `Warna.peringatan`, `Warna.gagal`) hanya untuk status dan error. Ketiganya boleh untuk teks (misalnya "Diotorisasi dengan Passkey + Biometrik", pesan PIN salah).
- `header` → `header-deep` (`Warna.kepala` → `Warna.kepalaTua`): satu-satunya gradasi, hanya di header Beranda (nuansa BRImo). Nilainya sama di mode terang dan gelap (tidak adaptif), supaya navigation bar dan pita header selalu satu warna; teks dan ikon di atasnya `on-header` (`Warna.kepalaTeks`, putih), kontras ≥ 7:1. Launch screen memakai `header` polos. Layar lain memakai navigation bar bawaan iOS.
- Logo: aset `LogoBRImo` (PDF vektor dari tim) lewat komponen `LogoBRImo`. Di atas `header` atau di mode gelap, "BRI" diwarnai putih; "mo" selalu biru muda bawaan logo. Warna logo tidak dijadikan token dan tidak dipakai untuk teks lain.
- Mode gelap tidak digambar di prototype. Nilainya dipilih supaya lolos kontras yang sama dan ada di `Tokens.swift`.

## Typography

Font sistem (SF). Prototype memakai font web geometris (mirip Plus Jakarta Sans); di app diganti SF. Semua lewat text style supaya ikut Dynamic Type; `fontSize` di YAML adalah ukuran default text style itu, bukan angka px prototype:

- `title` → `.largeTitle` bold → `Teks.nominal`: saldo, nominal di form, nominal Transfer Berhasil (prototype ±28–32 pt).
- `heading-lg` → `.title2` bold → `Teks.judulBesar`: sapaan "Halo, Budi", "Transfer Berhasil" (±24 pt).
- `heading` → `.title3` bold → `Teks.judul`: judul sheet peringatan, "Verifikasi Biometrik" (±20 pt).
- `body` → `.body` → `Teks.isi` / `Teks.isiTebal`: isi, label field (±16 pt).
- `caption` → `.subheadline` → `Teks.keterangan`: "Batas kewajaran", "Bank BRI", label rincian (±14–15 pt).
- `label` → `.footnote` semibold → `Teks.label`: chip nominal, label aksi cepat (±13–14 pt).
- Tombol → `.headline` → `Teks.tombol` (±18 pt).

Judul layar (Transfer, Masukkan PIN) memakai `.navigationTitle`, bukan token teks.

## Layout

Jarak dari skala 4 / 8 / 16 / 24 / 32 (`Space.xs` sampai `Space.xl`), tanpa nilai di luar skala. Margin samping layar `Space.m` (prototype ±20; `List` dan `Form` memakai margin bawaan iOS). Jarak antar-tombol keypad PIN `Space.m` (prototype ±12). Jarak antar-bagian form `Space.l`. Tombol utama di bawah, selebar layar, lewat `safeAreaInset`. Target sentuh minimal 44 pt.

## Elevation & Depth

Tanpa bayangan. Kedalaman dari warna: kartu `surface` di atas `background`. Prototype memberi bayangan pada kartu saldo dan tombol utama; di app tidak ditiru.

## Shapes

Kartu, kotak rekening tujuan, field, tombol keypad dan aksi cepat `rounded.lg` (`Radius.l`). Ikon dan elemen kecil `rounded.sm`. Tombol utama dan chip nominal kapsul (`rounded.button: full`).

## Components

| Komponen | Isi | Aturan |
| --- | --- | --- |
| `PrimaryButton(judul) { }` | Tombol utama kapsul, warna primary | Maksimal satu per layar. Label kata kerja + objek. Abu-abu saat `.disabled` |
| `BarisItem(ikon:judul:keterangan:nominal:terpilih:)` | Baris daftar umum | Satu elemen VoiceOver. Nominal tidak pernah patah baris; pada teks besar turun ke bawah judul dan boleh mengecil sampai separuh |
| `Kartu { }` | Wadah `surface` (`Warna.permukaan`), `Radius.l`, padding `Space.m` | Kartu saldo, rekening tujuan, rincian transfer |
| `KeadaanKosong`, `KeadaanGagal`, `BarisMemuat` | Tiga state selain berhasil | Pesan: apa yang terjadi, kenapa, apa yang bisa dilakukan |
| `KeadaanGagal(judul:pesan:tombol:)` | State gagal dengan satu tombol, default "Coba lagi" | Proses yang dihentikan demi keamanan memakai `tombol: "Kembali ke Beranda"` |
| `KeadaanMemproses(pesan:)` | Indikator proses singkat dengan pesan | "Memeriksa keamanan transaksi…", "Memeriksa PIN…", "Memproses transfer…". Diumumkan VoiceOver |
| `IkonLingkaran(ikon:warna:gaya:)` | SF Symbol di lingkaran. `.penuh`: lingkaran berwarna, ikon `Warna.latar`. `.lembut`: lingkaran warna 15% | Dekoratif, disembunyikan dari VoiceOver. Centang berhasil, perisai peringatan |
| `BelumDibangun(layar:task:)` | Penanda layar yang belum dibangun | |
| `RincianTransfer(bukti:tampilkanReferensi:)`, `BarisRincian(label:nilai:warna:)` | Kartu bukti transfer: Penerima, Waktu, Catatan, Otorisasi (dan No. referensi) | Dipakai Transfer Berhasil dan Detail Transaksi. Pada teks besar nilai turun ke bawah label |
| `FieldNominal(teks:labelAksesibilitas:fokus:ubah:)` | "Rp" + angka besar di latar `surface`, garis `primary` saat aktif | Dipakai Transfer dan Top Up. Aturan ketikan lewat `ValidasiTransfer.rapikan` di `ubah` |
| `PilihanNominal(pilihan:terpilih:pilih:)` | Baris chip nominal cepat, kapsul `primary` 10% | Selalu satu baris; pada teks besar digeser ke samping |
| `LogoBRImo(latar:)` | Logo BRImo dari aset vektor. `.terang`: logo asli. `.gelap`: "BRI" putih | Ikut Dynamic Type sampai batas tertentu. VoiceOver membaca "BRImo" |

Ikon app dan launch screen dibuat dari logo yang sama: `swift scripts/buat-aset-logo.swift <logo.pdf>`.

Komponen yang hanya dipakai satu layar tetap di folder layarnya: `AksiCepat`, `BannerInfo` (Beranda), `PeringatanRisikoSheet` (Transfer), `TitikPIN`, `KeypadPIN` (PIN), `BarisNotifikasi` (Notifikasi). Pindahkan ke `DesignSystem/` kalau dipakai layar kedua.

## Do's and Don'ts

- Pakai token, jangan hex atau ukuran font langsung di view.
- Satu aksi utama per layar.
- Nominal lewat `Rupiah.format(_:)`: "Rp125.000", tanpa desimal.
- Copy Bahasa Indonesia, kalimat pendek, nada tenang.
- Jangan membuat komponen baru kalau yang di atas sudah cukup. Kalau perlu, tanyakan dulu.
