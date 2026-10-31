# Token: prototype → DESIGN.md → Tokens.swift

Dipakai di langkah 2 skill `html-ke-swiftui`. Arahnya selalu satu: nilai di prototype masuk ke `DESIGN.md` (token YAML di bagian atas), lalu ke `DesignSystem/Tokens.swift`. View hanya memakai nama Swift. Tidak pernah dari prototype langsung ke view.

Peta di bagian 2 memakai nama di repo workshop (`Warna`, `Space`, `Radius`, `Teks`). Repo lain bisa memakai nama atau token lain: baca `Tokens.swift` dan `DESIGN.md` repo ini dulu, lalu pakai nama yang ada.

## 1. Di mana token ada di prototype

| Format | Tempat token | Contoh |
| --- | --- | --- |
| HTML + CSS biasa | Variabel di `:root` | `--color-primary: #5E5CE6;` |
| HTML + CSS tanpa variabel | Hex yang berulang | Hitung dengan perintah di bawah tabel |
| Tailwind v3 | `tailwind.config.js`/`.ts` › `theme.extend` (`colors`, `borderRadius`, `spacing`, `fontSize`) | `colors: { brand: '#5E5CE6' }` → class `bg-brand` |
| Tailwind lewat CDN | Blok `<script>tailwind.config = { … }</script>` di HTML | |
| Tailwind v4 | `@theme { … }` di CSS | `--color-brand: #5E5CE6;` |
| Nilai arbitrer Tailwind | Di nama class | `bg-[#5E5CE6]`, `rounded-[20px]`, `p-[18px]` |
| shadcn (v0, Lovable) | `globals.css` atau `src/index.css`, `:root` dan `.dark` | `--primary: 241 73% 63%;` (HSL tanpa `hsl()`), atau `oklch(…)` |
| `DESIGN.md` dari sesi Dana | Front matter YAML di bagian atas (di antara dua `---`): `colors`, `typography`, `rounded` | `primary: "#18737C"`, `fontSize: 20px`, `control: 4px` |
| Tidak ada sumber | Screenshot | Tunjukkan nilai yang ditebak sebagai asumsi |

Hex yang paling sering dipakai (yang teratas biasanya latar, teks dan primary):

```bash
grep -rhoE "#[0-9A-Fa-f]{6}\b|#[0-9A-Fa-f]{3}\b" prototype --include=*.html --include=*.css --include=*.jsx --include=*.tsx | sort | uniq -c | sort -rn | head -20
```

HSL dan oklch: ubah ke hex, tulis hasil ubahannya di tabel, dan sebut kalau hasilnya pembulatan.

## 2. Peta DESIGN.md ke Tokens.swift

| `DESIGN.md` | `Tokens.swift` | Peran |
| --- | --- | --- |
| `colors.primary` | `Warna.utama` | Aksi utama: tombol utama, tanda pilih, tautan |
| `colors.on-primary` | `Warna.utamaTeks` | Teks di atas primary |
| `colors.background` | `Warna.latar` | Latar layar |
| `colors.surface` | `Warna.permukaan` | Kartu, grup baris |
| `colors.text` | `Warna.teks` | Teks utama |
| `colors.text-secondary` | `Warna.teksSekunder` | Keterangan |
| `colors.separator` | `Warna.garis` | Pemisah, tombol nonaktif |
| `colors.success` / `warning` / `danger` | `Warna.sukses` / `peringatan` / `gagal` | Status dan error saja. Tidak semua repo punya `warning` |
| `rounded.sm` / `md` / `lg` | `Radius.s` / `m` / `l` | Ikon kecil / elemen sedang / kartu |
| `rounded.button: full` | `.capsule` | Tombol utama |
| `spacing.scale` 4, 8, 16, 24, 32 | `Space.xs`, `s`, `m`, `l`, `xl` | |
| `typography.title` | `Teks.nominal` | Nominal besar |
| `typography.heading` | `Teks.judul` | Judul bagian |
| `typography.body` | `Teks.isi`, `Teks.isiTebal` | Isi |
| `typography.caption` | `Teks.keterangan` | Keterangan |
| `typography.label` | `Teks.label` | Label kecil, badge |

## 3. Aturan

- **Cocokkan menurut peran, bukan nama.** Variabel `--brand`, `--accent` atau `--blue-600` yang dipakai untuk tombol utama adalah `primary`.
- **Sudah dekat? Pakai yang ada.** Warna yang hampir sama dengan token yang ada (beda beberapa angka hex) memakai token itu. Spacing dan radius dibulatkan ke skala terdekat: 12 → tanya (di antara `s` dan `m`), 15 → `Space.m`, 20 → `Radius.l`.
- **Token baru** hanya kalau nilainya dipakai di dua tempat atau lebih dengan peran yang jelas. Tambahkan ke `DESIGN.md` (YAML dan prosa di bagian Colors atau Layout) dan ke `Tokens.swift` dalam satu perubahan. Tanya dulu.
- **Mode gelap.** Ambil dari `@media (prefers-color-scheme: dark)` atau `.dark { }` kalau ada. Kalau tidak ada, pilih padanan yang terbaca di latar `#000000` dan `#1C1C1E`, lalu sebutkan sebagai asumsi.
- **Transparansi.** `rgba(94, 92, 230, 0.12)` → `Warna.utama.opacity(0.12)`, bukan warna baru.
- **Gradien dan bayangan.** Tidak dipakai di prototipe (`DESIGN.md`: tanpa bayangan). Pakai warna polos; tanyakan kalau gradien itu identitas produk.
- **Font.** Inter, Poppins, Plus Jakarta Sans atau font web lain diganti font sistem (SF) lewat `Teks`. Jangan menambah file font.
- **Ukuran teks** dipetakan ke text style, bukan ditulis sebagai angka.
- **DESIGN.md dari sesi Dana.** Satuan `px` di YAML (`20px`, `4px`) dibaca sebagai angka pt. Nama kunci bisa berbeda dari tabel di bagian 2: petakan menurut peran (`rounded.control` → `Radius.s`, `rounded.card` → `Radius.m`; `typography.heading` → `Teks.judul`, `typography.body` → `Teks.isi`). Font web seperti Rubik atau Nunito Sans tetap diganti font sistem. Kunci yang tidak punya padanan: tanya dulu, jangan buat token baru diam-diam.

## 4. Ukuran teks: px ke text style iOS

Ukuran default iOS (Large). Pilih yang terdekat, lalu pakai nama di `Teks`.

| px di prototype | Text style iOS | `Teks` |
| --- | --- | --- |
| 32–36, tebal | `.largeTitle` | `Teks.nominal` (nominal besar) |
| 26–30 | `.title` | Tanya: belum ada token |
| 22–24 | `.title2` | Tanya: belum ada token |
| 19–21 | `.title3` | `Teks.judul` |
| 17–18, semibold | `.headline` / `.body` semibold | `Teks.isiTebal`, `Teks.tombol` |
| 16–17 | `.body` | `Teks.isi` |
| 15 | `.subheadline` | `Teks.keterangan` |
| 13–14 | `.footnote` | `Teks.label` (semibold) |
| 11–12 | `.caption` / `.caption2` | Tanya: belum ada token |

Berat: 400 regular, 500 medium, 600 semibold, 700 bold.

## 5. Tailwind bawaan (kalau tidak ada config)

| Class | Nilai | Token |
| --- | --- | --- |
| `p-1` `gap-1` | 4px | `Space.xs` |
| `p-2` `gap-2` | 8px | `Space.s` |
| `p-3` | 12px | Tanya (di antara `s` dan `m`) |
| `p-4` `gap-4` `px-4` | 16px | `Space.m` |
| `p-5` | 20px | Tanya (di antara `m` dan `l`) |
| `p-6` | 24px | `Space.l` |
| `p-8` | 32px | `Space.xl` |
| `rounded-lg` | 8px | `Radius.s` |
| `rounded-xl` / `rounded-2xl` | 12px / 16px | `Radius.m` |
| `rounded-3xl` | 24px | `Radius.l` |
| `rounded-full` | 9999px | `.capsule` |
| `text-xs` | 12px | Lihat tabel ukuran teks |
| `text-sm` | 14px | `Teks.label` atau `Teks.keterangan` |
| `text-base` | 16px | `Teks.isi` |
| `text-lg` | 18px | `Teks.isiTebal` kalau semibold |
| `text-xl` | 20px | `Teks.judul` |
| `text-2xl` | 24px | Tanya |
| `text-3xl` / `text-4xl` | 30px / 36px | `Teks.nominal` untuk nominal |
| `font-medium` / `font-semibold` / `font-bold` | 500 / 600 / 700 | `.weight(…)` lewat `Teks` |
| `shadow-*` | | Diabaikan |

Warna palet Tailwind dipetakan menurut peran. Nilai di bawah adalah v3; v4 memakai oklch dengan peran yang sama.

| Class | Nilai v3 | Token |
| --- | --- | --- |
| `bg-indigo-500`, `bg-blue-600` (tombol utama) | `#6366F1`, `#2563EB` | `Warna.utama` (nilai dari `DESIGN.md`, bukan dari Tailwind) |
| `bg-white` | `#FFFFFF` | `Warna.permukaan` |
| `bg-gray-50`, `bg-gray-100` | `#F9FAFB`, `#F3F4F6` | `Warna.latar` |
| `text-gray-900` | `#111827` | `Warna.teks` |
| `text-gray-500`, `text-gray-600` | `#6B7280`, `#4B5563` | `Warna.teksSekunder` |
| `border-gray-200` | `#E5E7EB` | `Warna.garis` |
| `text-green-600` | `#16A34A` | `Warna.sukses` |
| `text-amber-600`, `text-orange-600` | `#D97706`, `#EA580C` | `Warna.peringatan` |
| `text-red-500`, `text-red-600` | `#EF4444`, `#DC2626` | `Warna.gagal` |

## 6. Hasil yang ditunjukkan ke tim

```
| Nilai di prototype | Dipakai untuk | Token DESIGN.md | Swift | Status |
| --- | --- | --- | --- | --- |
| --color-primary: #5E5CE6 | tombol Lanjut, tanda pilih | colors.primary | Warna.utama | sama |
| #F2F2F7 | latar layar | colors.background | Warna.latar | sama |
| border-radius: 20px | kartu daftar | rounded.lg | Radius.l | sama |
| padding: 12px | baris daftar | spacing.scale | Space.s atau Space.m? | tanya |
```

Setelah tim setuju dan file diubah: build, render preview komponen di `DesignSystem/`, dan pastikan cek cepat di `SKILL.md` kosong.
