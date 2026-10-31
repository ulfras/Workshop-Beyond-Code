---
name: supabase-migrasi
description: Aturan dan langkah untuk setiap perubahan Supabase di repo prototipe ini. Pakai setiap kali mengubah skema database (tabel, kolom, index, function), RLS policy, data dummy (seed), atau kode app yang memanggil Supabase (Services/LayananSupabase.swift, Info.plist, Config/*.xcconfig). Juga dipakai saat diminta "sambungkan ke Supabase", "tambah tabel", "data dari database", atau saat ada error RLS / permission denied dari Supabase.
---

# Supabase migrasi

Dibuat untuk workshop BRI x Swift Bali (Okt 2026). Balas dalam Bahasa Indonesia.

Supabase adalah jalur **opsional**. Default prototipe adalah data dummy (`Services/LayananDummy.swift`). Jangan menyambungkan app ke Supabase kalau kelompok belum memintanya dan alur Must belum jalan dengan dummy.

## 0. Baca dulu

1. `AGENTS.md` (bagian Data dan Larangan).
2. `docs/DECISIONS.md`: jangan membalik keputusan lama tanpa bertanya.
3. `supabase/README.md`, semua file di `supabase/migrations/` (urut nomor), dan `supabase/seed.sql`.
4. `Services/LayananData.swift`, `Services/LayananSupabase.swift`, `Services/LayananDummy.swift`, model terkait di `Core/`.

## 1. Aturan yang tidak boleh dilanggar

- **Satu perubahan skema = satu file migration baru** di `supabase/migrations/NNNN_nama.sql`. `NNNN` = nomor berikutnya, empat digit (`0002`, `0003`, ...). `nama` pendek, huruf kecil, garis bawah.
- **Jangan pernah mengubah migration yang sudah diterapkan.** Salah? Tulis migration baru yang memperbaikinya.
- **RLS menyala di setiap tabel**, dengan policy yang ditulis jelas: siapa (`to anon`, `to authenticated`), aksi apa (`for select`, `for insert`, ...), dan syaratnya (`using`, `with check`). Tanpa policy berarti tidak ada akses; itu yang membuat kunci publishable aman.
- **Data dummy saja.** Nama contoh "Budi Contoh", nominal contoh 125000. Tidak ada data nasabah, nomor rekening asli, email atau nomor HP asli.
- **Di app hanya kunci publishable** (`sb_publishable_...`) atau kunci `anon` lama, lewat `Config/Supabase.xcconfig` (tidak di-commit) → `Info.plist` → `SumberData.swift`.
- **Kunci secret (`sb_secret_...`) dan `service_role` tidak boleh ada di mana pun di repo**: tidak di Swift, SQL, xcconfig, JSON, prompt, atau commit. Kunci itu melewati RLS. Kalau melihatnya, berhenti dan beri tahu manusia.
- **Berhenti dan tanya** sebelum migration yang bisa menghapus data: `drop table`, `drop column`, `truncate`, `delete` tanpa `where`, mengubah tipe kolom, atau `alter ... not null` di tabel yang sudah berisi.

## 2. Menulis migration

Pola minimal untuk tabel baru:

```sql
-- 0002_riwayat_tagihan.sql · untuk layar Features/Riwayat (Core/Model.swift > Tagihan)
create table public.riwayat_tagihan (
    id text primary key,
    judul text not null,
    nominal bigint not null,          -- rupiah utuh, bukan desimal
    dibuat_pada timestamptz not null default now()
);

alter table public.riwayat_tagihan enable row level security;

grant select on public.riwayat_tagihan to anon, authenticated;

create policy "Riwayat bisa dibaca" on public.riwayat_tagihan
    for select to anon, authenticated using (true);
```

- Nama kolom sama dengan nama properti di model Swift (atau buat struct baris terpisah yang memetakan), supaya `JSONDecoder` tidak perlu tebakan.
- Nominal uang `bigint` rupiah, sama seperti `Int` di Swift. Jangan `float` atau `real`.
- Prototipe tanpa login: cukup policy baca. Policy tulis (`insert`, `update`) hanya kalau task memintanya, dan tulis syaratnya dengan jelas.
- Data dummy untuk tabel baru: tambahkan ke `supabase/seed.sql` (`insert ... on conflict (id) do nothing`). Kalau datanya harus langsung ada di proyek Supabase kelompok, tulis juga sebagai migration terpisah (`NNNN_data_dummy_nama.sql`) untuk diterapkan mentor, karena `seed.sql` tidak otomatis jalan di proyek yang sudah dibuat.

## 3. Menerapkan migration: tugas mentor

Agen kelompok **tidak** menerapkan migration. MCP Supabase di Mac kelompok **read-only**, dan agen di Xcode tidak bisa menjalankan SQL sendiri.

- **Agen kelompok:** tulis file migration, samakan dummy dan test (bagian 4), tunjukkan isinya, lalu minta kelompok memanggil mentor. Jangan mencari jalan lain (SQL Editor lewat browser, kunci lain, CLI).
- **Yang boleh lewat MCP read-only:** `list_tables`, `execute_sql` berisi `select` kecil (`limit 5`) untuk mengecek, dan `get_advisors` tipe `security`.
- **Jangan pernah mengubah tabel lewat dashboard** (Table Editor atau SQL Editor). Repo, yaitu `supabase/migrations/`, adalah sumber kebenaran database.
- **Mentor** menerapkan dengan salah satu: MCP Supabase dengan akses tulis (`apply_migration`, nama = nama file tanpa nomor dan `.sql`), `supabase db push` dari CLI, atau integrasi GitHub saat push. `execute_sql` tidak dipakai untuk DDL.
- **Setelah setiap DDL:** `get_advisors` tipe `security`. Temuan RLS (tabel tanpa RLS, policy terlalu longgar) diperbaiki dengan migration baru sebelum lanjut. Laporkan hasilnya apa adanya.

## 4. Menyamakan app

Setiap perubahan skema yang dipakai app:

1. Model di `Core/` dan struct baris (kalau ada) cocok dengan kolom baru.
2. `LayananData` mendapat fungsi baru kalau layar butuh data baru.
3. **`LayananDummy` dan `Services/DataContoh.swift` ikut diubah**, supaya mode dummy, preview dan test tetap jalan tanpa jaringan.
4. `LayananSupabase` memanggil PostgREST (`/rest/v1/<tabel>?select=...`) dengan `URLSession`. Tanpa Swift package. Header `apikey` saja dari konfigurasi; jangan menulis kunci di kode.
5. Test Swift Testing untuk logika baru memakai `LayananDummy(jeda: .zero, ikutiDemoFlags: false)`. Test tidak boleh memanggil jaringan.
6. Empat state tetap ada: kalau Supabase gagal atau RLS menolak, layar menampilkan state gagal dengan pesan yang tenang, bukan crash.

## 5. Verifikasi

1. Build, jalankan semua test (harus lulus dengan data dummy).
2. Render preview layar yang berubah dalam empat state.
3. Kalau kelompok memakai mode Supabase: jalankan app di Simulator dan baca console. Baris `[Prototipe] Sumber data: Supabase` harus muncul, tanpa baris `HTTP 401`, `HTTP 404` atau `permission denied`.
4. `git status`: pastikan `Config/Supabase.xcconfig` dan file `.env` tidak ikut staged.

## 6. Catat

Tambahkan satu entri di akhir `docs/DECISIONS.md`: tabel atau policy apa yang berubah, kenapa, nama file migration, dan dampaknya ke app (file Swift, test). Usulkan pesan commit `apa · kenapa · dampak`.

## Laporan akhir

```
Migration: supabase/migrations/NNNN_nama.sql (diterapkan / menunggu mentor)
RLS: menyala · policy: ...
get_advisors (security): ... temuan
App: file yang diubah · dummy dan test ikut disamakan
Bukti: build bersih · N test lulus · preview 4 state · console
Belum dicek: ...
```
