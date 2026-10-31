# Prioritized flow (irisan 1)

Transfer dengan verifikasi tambahan (Passkey + biometrik) untuk transaksi tidak wajar. Acuan tampilan: `prototype/screenshots/`. Keputusan di balik alur ini: `docs/DECISIONS.md`.

0. Beranda — cara: kartu saldo + aksi cepat Transfer
1. Nasabah pilih rekening tujuan, lalu isi nominal — cara: daftar rekening tersimpan, form input + validasi nominal/saldo
2. Sistem cek risiko (FDS) saat nasabah mengetuk Lanjutkan — cara: FDS evaluasi rule (nominal, jam malam + total 4 jam)
3. Konfirmasi dan Input PIN Transaksi — cara: PIN diperiksa server; signed proof ke server untuk risiko tinggi
4. Verifikasi Passkey (hanya kalau terdeteksi tidak wajar) — cara: Face ID/Touch ID, lalu backend verifikasi signature
5. Transaksi berhasil — cara: Tampilkan bukti transaksi

| Jalur | Urutan |
|---|---|
| Normal | Beranda → Pilih Rekening Tujuan → Transfer → Lanjutkan → "Memeriksa keamanan transaksi…" → PIN → Berhasil ("Diotorisasi dengan PIN") |
| Risiko tinggi | Beranda → Pilih Rekening Tujuan → Transfer → Lanjutkan → "Memeriksa keamanan transaksi…" → sheet peringatan → PIN → Verifikasi Biometrik → Berhasil ("Diotorisasi dengan Passkey + Biometrik") |

## Layar

| # | Layar | Prototype | Yang dilakukan nasabah | Ke mana selanjutnya |
|---|---|---|---|---|
| 0 | Beranda | `1-beranda.png` | Melihat saldo, mengetuk Transfer | Transfer → Pilih Rekening Tujuan. Top Up, Riwayat, lonceng → Notifikasi. QRIS → layar "belum dibangun" (T9) |
| 1a | Pilih Rekening Tujuan | Tidak ada | Memilih satu dari 3 rekening tersimpan (Ayu Contoh, Citra Contoh, Dimas Contoh) | Transfer ke rekening itu. Kembali dari Transfer → daftar lagi |
| 1–2 | Transfer + sheet peringatan | `2-transfer.png`, `4-peringatan-keamanan.png` | Mengisi nominal (atau chip Rp1.000.000 / Rp10.000.000 / Rp75.000.000), catatan, Lanjutkan | Normal → PIN. Risiko tinggi → sheet: "Lanjutkan ke PIN" atau "Batalkan transfer" (tetap di Transfer, isian utuh) |
| 3 | Masukkan PIN | `3-pin.png` | Mengetik 6 digit; dikirim otomatis di digit ke-6 | Normal → Berhasil. Risiko tinggi → Verifikasi |
| 4 | Verifikasi Biometrik | `5-biometrik-passkey.png` | Mengetuk "Ketuk untuk memindai", lalu Face ID | Berhasil. "Batalkan transfer" → Beranda |
| 5 | Transfer Berhasil | `6-berhasil-passkey.png`, `7-berhasil-pin.png` | Membaca bukti, "Kembali ke Beranda" | Beranda (saldo diperbarui) |
| 6 | Riwayat | Tidak ada | Melihat transfer berhasil per hari | Detail Transaksi |
| 7 | Notifikasi | Tidak ada | Membaca notifikasi keamanan; membuka semua menandai dibaca | Detail Transaksi (untuk transfer berhasil) |
| 8 | Top Up | Tidak ada | Mengisi nominal (atau chip Rp100.000 / Rp500.000 / Rp1.000.000), "Top Up" | Top Up Berhasil → "Kembali ke Beranda" (saldo bertambah). Top up tidak masuk Riwayat dan tidak dihitung FDS |

Beda yang disengaja dari prototype: sheet peringatan muncul di atas Transfer (bukan di atas PIN) dengan tombol "Lanjutkan ke PIN" dan "Batalkan transfer"; layar Verifikasi memakai Face ID (prototype: sidik jari) dan menampilkan nominal + penerima yang diotorisasi; nominal tampil "Rp7.500.000" tanpa spasi (`Rupiah.format`); tanpa gradasi dan bayangan.

## Aturan FDS

Risiko tinggi kalau salah satu terpenuhi (dicek di server saat Lanjutkan, dan dinilai ulang saat kirim):

1. Nominal transfer ini **lebih dari Rp50.000.000**, kapan pun. Tepat Rp50.000.000 masih normal.
2. Transfer pukul **22.00–05.59**, dan total transfer berhasil dalam **4 jam terakhir + transfer ini lebih dari Rp30.000.000**. Pukul 06.00 sudah normal. Transfer sebelum 22.00 yang masih dalam 4 jam ikut dihitung; transfer gagal atau batal tidak.

Kalau keduanya terpenuhi, sheet menampilkan alasan nominal.

## State per layar

| Layar | Berhasil | Memuat | Kosong | Gagal |
|---|---|---|---|---|
| 0 Beranda | Sapaan, kartu saldo, aksi cepat, banner | Kartu saldo diburamkan (redacted) | "Belum ada rekening yang terhubung." | "Saldo belum bisa dimuat. Periksa koneksi, lalu coba lagi." + Coba lagi |
| 1a Pilih Rekening Tujuan | Daftar 3 rekening: nama, bank, nomor | Baris placeholder | "Belum ada rekening tujuan tersimpan." | "Rekening tujuan belum bisa dimuat. Periksa koneksi, lalu coba lagi." + Coba lagi |
| 1 Transfer (dibuka) | Rekening tujuan yang dipilih, field nominal, chip, catatan | Tidak ada | Tidak ada | Tidak ada |
| 1 Transfer (nominal) | Lanjutkan aktif | Tidak ada | Nominal kosong atau 0: Lanjutkan nonaktif, tanpa pesan | "Saldo tidak cukup." di bawah field (tanpa menyebut saldo), Lanjutkan nonaktif |
| 2 Cek FDS | Normal → PIN; tinggi → sheet | "Memeriksa keamanan transaksi…" | Tidak ada | "Pemeriksaan keamanan belum bisa dilakukan. Transfer belum diproses. Periksa koneksi, lalu coba lagi." + Coba lagi. **Tidak** diteruskan ke jalur normal |
| 3 PIN | 6 titik terisi → diperiksa | "Memeriksa PIN…", keypad nonaktif | Titik kosong (keadaan awal) | Koneksi: "PIN belum bisa diperiksa. Periksa koneksi, lalu coba lagi." (tidak dihitung salah). Salah: "PIN salah. Sisa 2 kesempatan." Salah ke-3: "PIN salah 3 kali. Demi keamanan, transfer ini dibatalkan." + Kembali ke Beranda |
| 4 Verifikasi | Face ID lulus → kirim | Prompt Face ID sistem | Tidak ada | Lihat baris di bawah |
| 4 ↳ wajah tidak cocok | | | | "Wajah tidak dikenali." + tombol "Coba lagi" (memanggil Face ID lagi), tetap di layar |
| 4 ↳ dibatalkan nasabah | | | | "Verifikasi dibatalkan. Transfer belum diproses." + tombol "Coba lagi" atau "Batalkan transfer" |
| 4 ↳ Face ID tidak tersedia | | | | "Face ID belum diaktifkan di iPhone ini. Transfer ini butuh verifikasi biometrik, jadi belum bisa diproses." + Kembali ke Beranda. **Tanpa** jalan pintas lewat PIN saja |
| 4 ↳ Face ID terkunci | | | | "Face ID terkunci karena terlalu banyak percobaan. Buka kunci iPhone dengan kode sandi, lalu coba lagi." + Kembali ke Beranda |
| 4 ↳ signature ditolak | | | | "Verifikasi transaksi gagal. Demi keamanan, transfer ini dibatalkan." + Kembali ke Beranda |
| Kirim transfer (dari PIN atau Verifikasi) | → Berhasil | "Memproses transfer…" | Tidak ada | Judul "Transfer belum terkirim", "Koneksi terputus. Saldo Anda tidak berubah." + Coba lagi (transfer yang sama, Face ID tidak diminta ulang) |
| 5 Berhasil | Centang, nominal, Penerima, Waktu, Catatan, Otorisasi | Tidak ada | Tidak ada | Tidak ada |
| 6 Riwayat | Transfer berhasil per hari (Hari ini, Kemarin, tanggal) | Baris placeholder | "Transfer yang berhasil akan muncul di sini." | "Riwayat belum bisa dimuat. Periksa koneksi, lalu coba lagi." + Coba lagi |
| 7 Notifikasi | Peringatan risiko, transfer berhasil, transfer dibatalkan; titik untuk yang belum dibaca | Baris placeholder | "Peringatan keamanan dan bukti transfer akan muncul di sini." | "Notifikasi belum bisa dimuat. Periksa koneksi, lalu coba lagi." + Coba lagi |
| 8 Top Up (isi) | Field nominal, chip, tombol "Top Up" | Tidak ada | Nominal kosong: tombol nonaktif, tanpa pesan | Di bawah Rp10.000: "Minimal top up Rp10.000."; di atas Rp100.000.000: "Maksimal top up Rp100.000.000." Tombol nonaktif |
| 8 Top Up (kirim) | "Top Up Berhasil", nominal, Saldo sekarang, Waktu + "Kembali ke Beranda" | "Memproses top up…" | "Belum ada rekening yang terhubung. Saldo tidak bisa ditambah." | "Top up belum berhasil. Koneksi terputus. Saldo Anda tidak berubah." + Coba lagi (top up yang sama, saldo tidak bertambah dua kali) |

Layar Berhasil tidak memuat apa pun (datanya dibawa dari layar sebelumnya), jadi hanya punya preview "Berhasil Passkey" dan "Berhasil PIN". Detail Transaksi juga. Transfer juga: rekening tujuan dan saldo dibawa dari Pilih Rekening Tujuan; server tetap memeriksa saldo saat kirim. Top Up tidak memuat apa pun saat dibuka, jadi "Memuat" saat dibuka tidak ada. Setiap layar juga punya preview "Teks besar" (`.accessibility3`).

Aturan field nominal (Transfer dan Top Up, `ValidasiTransfer.rapikan`): titik ribuan langsung terpasang setiap digit diketik atau dihapus ("7.500.000"); maksimal 12 digit, digit ke-13 tidak masuk; selain angka 0–9 (huruf, koma, minus, spasi, emoji, "Rp", digit non-Latin) tidak diterima, termasuk saat menempel teks: angka di field tetap seperti sebelumnya, tanpa pesan. Nol di depan dibuang.

## Untuk Tester

- **PIN dummy: 000000.** PIN lain dihitung salah; salah 3 kali membatalkan transfer itu. Transfer baru dari layar Transfer mulai lagi dari 3 kesempatan.
- **Saldo dummy:** Rp125.000.000. Riwayat dummy: satu transfer Rp20.000.000 satu jam sebelum app dibuka.
- **Face ID di Simulator:** Features › Face ID › Enrolled (centang), lalu saat prompt muncul: Matching Face (lulus) atau Non-matching Face (gagal). Tanpa Enrolled, layar menampilkan "Face ID belum diaktifkan". Setelah Non-matching Face, prompt sistem menawarkan "Try Face ID Again": di Simulator prompt itu menunggu, jadi pilih lagi Matching Face atau Non-matching Face dari menu. Kalau prompt ditutup, tombol "Coba lagi" di layar memanggil Face ID lagi.
- **Top Up:** chip Rp500.000 → "Top Up" → saldo di Beranda bertambah Rp500.000.
- **Jalur risiko tinggi siang hari:** chip Rp75.000.000.
- **Jalur jam malam:** jalankan dengan `-demoJam 23:00`, lalu chip Rp10.000.000 → total Rp30.000.000 → normal; ketik Rp15.000.000 → total Rp35.000.000 → sheet peringatan.

Launch argument (Xcode › Edit Scheme › Run › Arguments, atau `bash scripts/simulator-demo.sh paksa <flag> <nilai>`):

| Flag | Nilai | Akibat |
|---|---|---|
| `-demoBeranda` | `memuat` / `kosong` / `gagal` | State Beranda |
| `-demoRekening` | `memuat` / `kosong` / `gagal` | State Pilih Rekening Tujuan (dulu `-demoTransfer`) |
| `-demoFDS` | `gagal` | Cek risiko gagal setelah Lanjutkan |
| `-demoPin` | `gagal` | PIN tidak bisa diperiksa (koneksi), bukan PIN salah |
| `-demoKirim` | `gagal` | Transfer belum terkirim |
| `-demoSignature` | `gagal` | Server menolak signature passkey |
| `-demoJam` | `23:00` (HH:mm) | Jam server dummy dimulai dari jam itu |
| `-demoRiwayat` | `memuat` / `kosong` / `gagal` | State Riwayat |
| `-demoNotifikasi` | `memuat` / `kosong` / `gagal` | State Notifikasi (juga titik lonceng di Beranda) |
| `-demoTopUp` | `memuat` / `kosong` / `gagal` | Kirim top up tidak pernah selesai / belum ada rekening / koneksi putus |
| `-demoMulai` | `rekening` / `transfer` / `pin` / `verifikasi` / `berhasil` / `riwayat` / `notifikasi` / `topup` | Hanya build debug: app dibuka langsung di layar itu, untuk screenshot dan cek tata letak. PIN di layar ini selalu "belum bisa diperiksa" karena transfer contohnya tidak terdaftar di server |

## Nanti (tidak dibuat sekarang)
- konfirmasi di wearable (Won't)
- aturan FDS lokasi/device (T2b)
- QRIS (T9)
- Top up dari sumber dana asli, top up di Riwayat
