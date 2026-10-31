# PRD · Tagih teman

Disusun dari blueprint sesi desain: job story, prioritized flow, feature scope (MoSCoW), dan kriteria sukses.

## Produk dan masalah

Fitur di aplikasi mobile banking untuk menagih bagian teman setelah makan bersama. Nasabah enggan menagih langsung. Patungan terjadi di chat grup, bukti transfer tercecer, dan hitungannya sering salah.

## Pengguna dan job story

- Pengguna: nasabah muda yang baru membayar makan bersama teman.
- Job story: Ketika selesai makan bersama teman, saya ingin menagih bagian mereka dalam satu menit, agar tidak ada yang canggung.
- Asumsi paling berisiko: kami percaya teman mau membayar lewat link.

## Kriteria sukses

1. Kirim: 4 dari 5 penguji mengirim tagihan dalam 60 detik tanpa bantuan. (Dari job story.)
2. Bayar: 4 dari 5 penguji membayar lewat link tanpa bantuan. (Dari asumsi paling berisiko. Di prototipe ini pembayaran disimulasikan: penguji berperan sebagai teman, membaca pesan dan link di layar Kirim link, lalu menunjukkan apa yang akan ia lakukan.)

## Feature scope (MoSCoW)

| | Fitur | Langkah di user flow |
| --- | --- | --- |
| Must | Pilih dari riwayat transaksi | 01 Pilih transaksi |
| Must | Pilih teman dari kontak (dummy) | 02 Pilih teman |
| Must | Bagi rata otomatis, dengan aturan pembulatan | 03 Bagi rata |
| Must | Kirim link lewat chat (simulasi), dengan pesan yang sopan | 04 Kirim link |
| Must | Status lunas atau belum per teman | 05 Pantau status |
| Should | Pengingat otomatis · Pilih dari grup chat | Antrean berikutnya |
| Could | Bagi per item · Scan struk · QR di meja | Antrean berikutnya |
| Won't | Cicilan patungan · Chat di dalam aplikasi | Tidak dibangun |

Prototipe ini hanya membangun Must. Should dan Could tidak dikerjakan tanpa entri baru di `docs/DECISIONS.md`.

## User flow

Lihat `userflow.md`.

## Tech

- iOS 17+, iPhone, SwiftUI, Swift 6, `@Observable`, `NavigationStack`. Tanpa package pihak ketiga.
- Data dari `LayananDummy` (`Services/`): 5 transaksi, 6 kontak (Ayu, Bima, Citra, Dimas, Eka, Fajar). Tidak ada backend. Link bayar adalah URL contoh. Status bayar disimulasikan.
- Aturan bisnis yang tidak terlihat di layar: nominal disimpan sebagai `Int` rupiah. Bagian tiap teman dibulatkan ke atas ke rupiah penuh; bagian pengirim = total dikurangi bagian semua teman. Rp100.000 untuk 3 orang: tiap teman Rp33.334, pengirim Rp33.332.

## Design system

`DESIGN.md` dan `DesignSystem/` (token dan komponen). Komponen yang dipakai: `PrimaryButton`, `TotalCard`, `BagianRow`, `TransaksiRow`, `TemanRow`, `StatusPill`, `KeadaanKosong`, `KeadaanGagal`, `BarisMemuat`.

## Batasan

- Data: dummy, tanpa data nasabah.
- Platform: iOS 17+, jalan di Simulator; perangkat lewat Personal Team kalau ada.
- Lisensi: hanya SF Symbols dan aset buatan sendiri.

## Pertanyaan terbuka

- Bagaimana teman yang tidak punya aplikasi bank yang sama membayar?
- Apakah bagi rata dianggap adil kalau pesanan tiap orang berbeda jauh?
