# Tasks · Tagih teman

Urut dari atas. Satu task = satu sesi agen = satu commit = diff yang terbaca dalam 2 menit. Centang task setelah cek penerimaannya terpenuhi.

- [ ] **T1** Model, data dummy dan LayananDummy
  - Cek penerimaan: Test `PilihTemanModelTests` lulus; `-demoKontak gagal` memunculkan state gagal.
- [ ] **T2** Design system dari `DESIGN.md`
  - Cek penerimaan: Preview komponen tampil, terang dan gelap.
- [ ] **T3** Layar Pilih transaksi (userflow #01)
  - Cek penerimaan: 4 preview tampil; "Tagih teman" membuka Pilih teman.
- [ ] **T4** Layar Pilih teman (userflow #02)
  - Cek penerimaan: 4 preview tampil; "Lanjut" nonaktif tanpa teman, "Lanjut (3)" setelah memilih 3.
- [ ] **T5** Layar Bagi rata (userflow #03), dipecah tiga
  - [ ] **T5a** SplitCalculator + test pembulatan
    - Cek penerimaan: Test dulu. Rp100.000 untuk 3 orang: teman Rp33.334, pengirim Rp33.332; jumlah semua bagian = total; total 0 ditolak.
  - [ ] **T5b** BagiRataView dengan empat state
    - Cek penerimaan: 4 preview tampil; `TotalCard` dan `BagianRow` dari DesignSystem; "Lanjut (3)" di Pilih teman membuka Bagi rata di Simulator.
  - [ ] **T5c** Sambungkan ke Kirim link
    - Cek penerimaan: "Lanjut" membuka Kirim link dengan teman dan hasil bagi.
- [ ] **T6** Layar Kirim link (userflow #04)
  - Cek penerimaan: 4 preview tampil; tombol "Kirim ke 3 teman"; `-demoKirim gagal` memunculkan gagal kirim.
- [ ] **T7** Layar Pantau status (userflow #05)
  - Cek penerimaan: 4 preview tampil; "Selesai" kembali ke Riwayat.
- [ ] **T8** Aksesibilitas: Dynamic Type dan VoiceOver
  - Cek penerimaan: Preview "Teks besar" (`.accessibility3`) tanpa teks terpotong; baris teman satu elemen VoiceOver: label "Ayu, Sering patungan", trait Selected saat dipilih (cek di Accessibility Inspector).
- [ ] **T9** Uji kriteria sukses
  - Cek penerimaan: Kirim: satu orang di luar kelompok mengirim tagihan dari Riwayat sampai Tagihan aktif dalam 60 detik tanpa bantuan. Bayar: satu orang lain, berperan sebagai teman, membaca pesan di Kirim link dan langsung menunjuk link bayarnya.
