---
name: Tagih teman
colors:
  primary: "#5E5CE6"
  on-primary: "#FFFFFF"
  background: "#F2F2F7"
  surface: "#FFFFFF"
  text: "#1D1D1F"
  text-secondary: "#6E6E73"
  separator: "#E5E5EA"
  success: "#248A3D"
  danger: "#FF453A"
typography:
  title:
    fontFamily: "SF Pro Rounded"
    fontSize: 34
    fontWeight: 700
  heading:
    fontFamily: "SF Pro"
    fontSize: 20
    fontWeight: 600
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

# DESIGN.md · Tagih teman

Design system prototipe, ditulis dengan format DESIGN.md (token YAML di atas, prosa di bawah). Mengikuti design system contoh di demo Dana (F2): design system Apple sebagai platform, satu aksen brand. Bukan aset BRI. Kode Swift-nya di `DesignSystem/Tokens.swift`; kalau nilai di sini berubah, ubah keduanya bersamaan.

## Overview

Tenang, jelas, terpercaya. Uang selalu tampil besar, tanpa desimal. Satu aksi utama per layar.

## Colors

- `primary` (`Warna.utama`) hanya untuk aksi utama: tombol utama, tanda pilih, tautan. Bukan untuk kartu atau latar.
- `background` (`Warna.latar`) untuk latar layar, `surface` (`Warna.permukaan`) untuk kartu dan grup baris.
- Penamaan: `background` di sini sama dengan `surface` (#F2F2F7) di contoh Dana; `surface` di sini dipakai untuk kartu putih.
- `text` dan `text-secondary` (`Warna.teks`, `Warna.teksSekunder`) untuk teks. `separator` (`Warna.garis`) untuk pemisah dan tombol nonaktif.
- `success` (`Warna.sukses`) untuk status "Lunas". Status "Belum" netral (teks sekunder di atas latar), bukan merah.
- `danger` (`Warna.gagal`) hanya untuk error.
- Mode gelap memakai padanan sistem; nilainya ada di `Tokens.swift`.

## Typography

Font sistem (SF). Semua lewat text style supaya ikut Dynamic Type: `title` → `Teks.nominal` (Large Title, rounded), `heading` → `Teks.judul`, `body` → `Teks.isi` / `Teks.isiTebal`, `caption` → `Teks.keterangan`, `label` → `Teks.label`. Nominal boleh mengecil sampai 60% sebelum terpotong.

## Layout

Jarak dari skala 4 / 8 / 16 / 24 / 32 (`Space.xs` sampai `Space.xl`). Tombol utama di bawah, selebar layar, lewat `safeAreaInset`. Target sentuh minimal 44 pt (`Ukuran.sentuhMinimal`).

## Elevation & Depth

Tanpa bayangan. Kedalaman dari warna: kartu `surface` di atas `background`.

## Shapes

Kartu `rounded.lg` (20, `Radius.l`). Ikon dan elemen kecil `rounded.sm` (8). Tombol utama kapsul (`rounded.button: full`).

## Components

| Komponen | Isi | Aturan |
| --- | --- | --- |
| `PrimaryButton(judul) { }` | Tombol utama kapsul, warna primary | Maksimal satu per layar. Label kata kerja + objek: "Tagih teman", "Kirim ke 3 teman". Abu-abu saat `.disabled` |
| `TotalCard(total:judul:label:)` | Kartu putih: judul transaksi, total besar, label kecil | Bukan warna primary |
| `BagianRow(nama:jumlah:keterangan:urutan:)` | Avatar, nama, keterangan, nominal | Satu elemen VoiceOver |
| `TransaksiRow(transaksi:terpilih:)` | Ikon kategori, merchant, waktu, nominal | Tanda pilih primary di kanan |
| `TemanRow(teman:urutan:terpilih:)` | Avatar, nama, keterangan, tanda pilih | Satu elemen VoiceOver, trait terpilih |
| `StatusPill(status:)` | "Lunas" hijau, "Belum" netral | Warna bukan satu-satunya penanda: ada teksnya |
| `KeadaanKosong`, `KeadaanGagal`, `BarisMemuat` | Tiga state selain berhasil | Pesan: apa yang terjadi, kenapa, apa yang bisa dilakukan |

## Do's and Don'ts

- Pakai token, jangan hex atau ukuran font langsung di view.
- Satu aksi utama per layar.
- Nominal lewat `Rupiah.format(_:)`: "Rp240.000", tanpa desimal.
- Copy Bahasa Indonesia, kalimat pendek, "kamu", nada tenang.
- Jangan membuat komponen baru kalau yang di atas sudah cukup. Kalau perlu, catat dulu di `docs/context-gaps.md`.
