# Contoh hasil sesi desain · Tagih teman

Folder ini contoh lengkap apa yang dibawa dari sesi desain ke starter: satu produk kecil, **Tagih teman** (menagih bagian teman setelah makan bersama), dari job story sampai prototype HTML yang bisa diklik. Pakai untuk melihat bentuk dan tingkat detailnya, lalu isi versi kelompok kalian di `docs/`, `DESIGN.md`, dan `prototype/` di root repo.

**Ini hanya contoh.** Jangan dibangun dan jangan dijadikan aturan, kecuali kelompok kalian belum punya hasil sesi desain dan memutuskan memakai Tagih teman sebagai latihan.

## Isi

| File | Isinya | Di starter masuk ke |
| --- | --- | --- |
| `AGENTS.md` | Bagian **Produk**: job story, pengguna, kriteria sukses, scope | Disalin agen ke bagian Produk di `AGENTS.md` root (prompt P1). Jangan menimpa file `AGENTS.md` root |
| `docs/job-story.md` | Job story dan kriteria sukses | `docs/` |
| `docs/PRD.md` | Produk, feature scope MoSCoW, kriteria sukses | `docs/` |
| `docs/userflow.md` | Lima layar, dan state memuat, kosong, gagal per layar | `docs/` |
| `docs/tasks.md` | Task berurutan dengan cek penerimaan | `docs/` |
| `DESIGN.md` | Design system: token warna, huruf, jarak, radius, dan aturannya | `DESIGN.md` |
| `prototype/` | Prototype HTML 390 px: `index.html` menautkan lima layar, `style.css` berisi token, `screenshots/` satu PNG per layar | `prototype/` |

Buka `prototype/index.html` di Safari untuk mengeklik alurnya. Prototype hanya menunjukkan state berhasil; state lain ada di tabel `docs/userflow.md`.

## Memakai contoh ini sebagai titik awal

Kalau kelompok belum punya hasil sesi desain, seret **isi** folder `contoh-sesi-desain/docs/` ke `docs/` di root (Replace), lalu `DESIGN.md` dan folder `prototype/`. `AGENTS.md` tidak diseret: jalankan prompt P1 supaya agen menyalin bagian Produk. Sama seperti langkah 4 di `README.md` root.
