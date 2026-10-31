# Prototype HTML dari sesi Dana

Folder ini berisi prototype HTML dari sesi Dana (Jumat 30 Okt, 08.30–10.45): biasanya satu file `index.html` yang dibuat agen Kiro dari `docs/` dan `DESIGN.md` kelompok. Lebarnya 390 px, bisa diklik dari awal sampai akhir alur, dan sudah menampilkan memuat, kosong, dan gagal. Agen memakainya sebagai **acuan** untuk membangun layar SwiftUI native, bukan sebagai kode yang disalin. Skill: `html-ke-swiftui`. Panduan tim: `docs/dari-html-ke-swiftui.md`.

Isi sekarang hanya contoh: `contoh/` dan `screenshots/contoh.png` menggambar layar `Features/Contoh`. Folder kelompok dari sesi Dana masuk ke repo ini lewat satu perintah, dari folder repo:

```bash
bash scripts/impor-dana.sh ~/Desktop/NamaFolderKelompok
```

## Isi folder ini

```
prototype/
  index.html            dari sesi Dana: semua layar dalam satu file
  screenshots/          satu PNG per layar, lebar 390 px
    01-buka-transaksi.png
    02-pilih-teman.png
```

- **Satu `index.html` berisi semua layar.** Supaya layar bisa ditunjuk, setiap layar sebaiknya punya judul atau `<section id="01-buka-transaksi">` yang sama dengan langkahnya di `docs/userflow.md`. Kalau belum, minta agen mendaftar layar di `index.html` dulu (langkah Inventaris di `docs/dari-html-ke-swiftui.md`).
- **Screenshot.** Buka `index.html` di Safari › Develop › Responsive Design Mode, lebar 390 px. Simpan satu screenshot per layar ke `screenshots/`, nama sama dengan langkahnya. Screenshot dipakai untuk membandingkan preview SwiftUI.
- **Prototype dari tool lain** (v0, Lovable, beberapa file HTML) tetap boleh. Salin file sumbernya ke sini, bukan hanya link. Satu page atau route = satu layar. Folder proyek React disalin tanpa `node_modules/`.

## Kalau hanya ada link

1. Unduh kode dari tool-nya (menu ekspor atau unduh ZIP), lalu salin ke sini.
2. Tidak bisa diunduh? Buka link di browser Mac dengan ukuran iPhone (Safari › Develop › Responsive Design Mode, atau Chrome › DevTools › mode perangkat), lalu simpan screenshot setiap layar ke `screenshots/`.
3. Tulis link-nya di bagian Sumber di bawah, untuk manusia. Agen bekerja dari file di folder ini.

## Data dummy

Prototype sering berisi nama dan angka yang tampak asli. Sebelum di-commit, pastikan semuanya data dummy: "Budi Contoh", Rp125.000. Tidak ada data nasabah, nomor rekening, nomor HP, email asli, atau screenshot sistem internal.

Jangan menyalin `.env` atau file berisi kunci dari ekspor (misalnya folder `src/integrations/supabase/` dari Lovable). `scripts/cek-rahasia.sh` menolak commit yang membawa kunci.

## Cek sebelum memanggil agen

- [ ] `index.html` dari sesi Dana ada di sini, bukan hanya link.
- [ ] Setiap layar Must bisa ditunjuk: judul atau `section id` sama dengan langkah di `docs/userflow.md`.
- [ ] Screenshot 390 px per layar di `screenshots/`.
- [ ] Token warna, huruf dan radius ada di `DESIGN.md` (bagian atas, di antara dua baris `---`).
- [ ] Data dummy saja.
- [ ] `contoh/` dan `screenshots/contoh.png` dihapus kalau sudah tidak dipakai.

## Sumber

- Dibuat dengan: [Kiro, prompt C2 sesi Dana / tool lain]
- Link (kalau ada): [...]
- Layar yang ada: [01 ..., 02 ...]
