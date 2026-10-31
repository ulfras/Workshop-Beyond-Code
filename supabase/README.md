# supabase/

Jalur **opsional**. Default prototipe adalah data dummy (`Services/LayananDummy.swift`). Pindah ke Supabase hanya setelah alur utama jalan dengan dummy. Langkah untuk kelompok: `docs/supabase-opsional.md`.

| File | Isi |
| --- | --- |
| `migrations/0001_contoh.sql` | Tabel `item_contoh` untuk layar contoh, RLS menyala, policy baca saja |
| `seed.sql` | Tiga baris dummy, sama dengan `Services/DataContoh.swift` |

## Aturan

- Setiap perubahan skema adalah file baru `migrations/NNNN_nama.sql` (`0002_…`, `0003_…`). File yang sudah diterapkan tidak diubah lagi.
- RLS menyala di setiap tabel, dengan policy yang jelas.
- Data dummy saja. Tidak ada data nasabah.
- Di app hanya kunci publishable, lewat `Config/Supabase.xcconfig` yang tidak di-commit. Kunci secret dan kunci service role tidak pernah masuk repo.
- Agen mengikuti skill `supabase-migrasi` untuk semua perubahan di folder ini dan di `Services/LayananSupabase.swift`. Agen menulis migration; mentor yang menerapkannya.
- Tidak ada perubahan tabel lewat dashboard Supabase.

## Untuk mentor: menyiapkan proyek kelompok

1. Buat satu proyek Supabase per kelompok (region Singapura paling dekat).
2. Terapkan `migrations/0001_contoh.sql` dan `seed.sql` sekali: `supabase db push --include-seed` dari CLI, atau MCP Supabase dengan akses tulis (`apply_migration` untuk migration, lalu isi `seed.sql`). Jangan membuat tabel lewat Table Editor.
3. Cek Advisors > Security: tidak ada temuan RLS.
4. Beri kelompok host proyek (`<ref>.supabase.co`) dan kunci **publishable**. Bukan kunci secret.
5. MCP Supabase di Mac kelompok: read-only dan dibatasi ke proyek itu, misalnya server remote `https://mcp.supabase.com/mcp?project_ref=<ref>&read_only=true` (untuk Kiro sudah ada, nonaktif, di `.kiro/settings/mcp.json`). Migration baru dari kelompok diterapkan oleh mentor, lalu cek Advisors > Security lagi.
