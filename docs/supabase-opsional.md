# Supabase (opsional)

Default prototipe adalah **data dummy**. Supabase hanya untuk kelompok yang alur utamanya (fitur Must di PRD) sudah jalan dengan dummy dan ingin data dari database sungguhan. Tanpa langkah ini, app tetap jalan.

## Kapan pindah

- Semua layar Must punya empat state dan jalan di Simulator dengan dummy.
- Mentor sudah memberi **host proyek** dan **kunci publishable** kelompok kalian. Tabel `item_contoh`, RLS dan data dummy sudah disiapkan mentor (`supabase/`).
- Waktu sebelum "siap diuji" (Jumat 16.25) masih lebih dari 45 menit.

## Langkah

1. Xcode › Settings › Source Control: pastikan **Add and remove files automatically** mati.
2. Salin template di Terminal (atau duplikat di Finder lalu ganti namanya):

   ```bash
   cp Config/Supabase.example.xcconfig Config/Supabase.xcconfig
   ```

   **Jangan** pakai "Add Configuration File…" atau "Add Files…" di Xcode. Proyek sudah memuat file itu lewat `Config/Proyek.xcconfig`. Xcode bisa menyalin file berkunci ke tempat lain dan langsung men-stage-nya.
3. Buka `Config/Supabase.xcconfig` dan isi dua nilai dari mentor:
   - `SUPABASE_HOST = <ref>.supabase.co` (host saja, tanpa `https://`)
   - `SUPABASE_PUBLISHABLE_KEY = sb_publishable_…`
   - `SUMBER_DATA = supabase` sudah ada di template.
4. **⌘B** lalu **⌘R**. Console Xcode menulis `[Prototipe] Sumber data: Supabase`, dan layar Contoh menampilkan tiga baris dari database.
5. `git status`: `Config/Supabase.xcconfig` **tidak boleh** muncul. Pengecek rahasia juga menolaknya saat commit.

## Hanya kunci publishable

- App hanya memakai kunci **publishable** (`sb_publishable_…`) atau kunci `anon` lama. Isi app bisa dibongkar, jadi kunci di app dianggap publik. Yang menjaga data adalah Row Level Security (RLS).
- Kunci **secret** (`sb_secret_…`) dan **service_role** tidak pernah masuk app, repo, prompt, atau chat. Kalau ada yang terkirim, beri tahu mentor supaya kuncinya diganti.

## Agen dan MCP

- Setiap perubahan tabel, policy, data dummy, atau kode Supabase: sebut **"Pakai skill supabase-migrasi"** di prompt.
- Agen menulis migration baru ke `supabase/migrations/NNNN_nama.sql` dan menyamakan `LayananDummy` serta test. Kelompok lalu memanggil mentor, dan **mentor yang menerapkannya** (MCP Supabase dengan akses tulis, `supabase db push`, atau integrasi GitHub).
- MCP Supabase di Mac build hanya **read-only** dan hanya untuk proyek kelompok: agen boleh melihat tabel, menjalankan `select`, dan `get_advisors`. Agen di Xcode tidak bisa menjalankan SQL sendiri.
- Jangan mengubah tabel lewat dashboard Supabase (Table Editor atau SQL Editor). Semua perubahan lewat file migration.
- Contoh prompt: "Pakai skill supabase-migrasi. Tambah tabel riwayat tagihan sesuai docs/PRD.md. Tulis migration, samakan LayananDummy dan test, jangan terapkan sendiri."
- Console menulis `HTTP 401`, `HTTP 404` atau `permission denied`? Tempel barisnya ke agen dan ke mentor.

## Kembali ke dummy

- Ubah `SUMBER_DATA = dummy` di `Config/Supabase.xcconfig`, atau hapus file itu. ⌘B, ⌘R. Console menulis `[Prototipe] Sumber data: dummy`.
- Host atau kunci kosong atau salah format? App otomatis memakai dummy dan menulis peringatan di console.
- Preview dan test selalu memakai dummy, di mode apa pun.
