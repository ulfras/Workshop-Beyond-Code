# User flow · Tagih teman

Irisan 1 dari board sesi desain (prioritized flow): pilih transaksi → pilih teman → bagi rata → kirim link → pantau status.

| # | Layar | Pengguna ada di mana | Yang ia lakukan | Yang ia butuhkan | Ke mana selanjutnya |
| --- | --- | --- | --- | --- | --- |
| 01 | Pilih transaksi | Baru selesai membayar, membuka riwayat | Memilih "Makan malam · Warung Bu Sri · Rp240.000", menekan "Tagih teman" | Daftar transaksi per hari: merchant, waktu, nominal | → 02 |
| 02 | Pilih teman | Daftar kontak | Memilih teman yang ikut makan (Ayu, Bima, Citra) | Kontak, pencarian, jumlah terpilih | "Lanjut (3)" → 03 |
| 03 | Bagi rata | Ringkasan pembagian | Mengecek bagian tiap orang | Total, jumlah orang, bagian tiap teman, bagian sendiri | "Lanjut" → 04 |
| 04 | Kirim link | Pratinjau pesan | Mengirim link bayar | Pesan yang sopan, daftar penerima, saluran | "Kirim ke 3 teman" → 05 |
| 05 | Pantau status | Tagihan aktif | Melihat siapa yang sudah bayar | Terkumpul, status per teman | "Selesai" → 01 |

## State per layar

| Layar | Berhasil | Memuat | Kosong | Gagal |
| --- | --- | --- | --- | --- |
| 01 Pilih transaksi | Daftar transaksi | Baris placeholder | "Belum ada transaksi minggu ini." | "Riwayat belum bisa dimuat. Periksa koneksi, lalu coba lagi." + Coba lagi |
| 02 Pilih teman | Daftar kontak, jumlah terpilih | Baris placeholder | "Belum ada kontak." | "Kontak belum bisa dimuat." + Coba lagi |
| 03 Bagi rata | Kartu total + bagian tiap orang | Baris placeholder saat rincian transaksi dimuat | "Pilih minimal satu teman." + kembali ke 02 | "Total tidak valid." (nominal 0) |
| 04 Kirim link | Pratinjau pesan, tombol "Kirim ke N teman" | "Membuat link…" | "Belum ada teman yang akan ditagih." | "Link belum terkirim. Koneksi terputus saat membuat link. Coba lagi." |
| 05 Pantau status | Ayu Belum · Bima Lunas · Citra Belum | Baris placeholder | "Belum ada tagihan aktif." | "Status belum bisa dimuat." + Coba lagi |

State gagal dan kosong bisa dipaksa untuk demo dan uji lewat launch argument, misalnya `-demoKontak gagal`. Daftarnya di `README.md`.
