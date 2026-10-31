-- 0001_contoh.sql · tabel untuk layar contoh (Features/Contoh, model Core/Model.swift > ItemContoh).
-- Jalur Supabase opsional. Mentor menerapkan file ini ke proyek Supabase kelompok.
-- Jangan ubah file ini setelah diterapkan. Perubahan berikutnya: file baru 0002_nama.sql (skill supabase-migrasi).

create table public.item_contoh (
    id text primary key,
    judul text not null check (char_length(judul) between 1 and 80),
    keterangan text not null default '',
    nominal bigint not null,                  -- rupiah utuh (Int di Swift), bukan desimal
    ikon text not null default 'circle',      -- nama SF Symbol
    dibuat_pada timestamptz not null default now()
);

comment on table public.item_contoh is 'Data dummy untuk layar contoh. Tidak ada data nasabah.';

-- RLS wajib di setiap tabel. Tanpa policy, tidak ada yang bisa membaca atau menulis.
alter table public.item_contoh enable row level security;

-- Prototipe tanpa login: pemegang kunci publishable (peran anon) hanya boleh MEMBACA.
-- Tidak ada policy insert, update atau delete, jadi app tidak bisa mengubah tabel ini.
grant select on public.item_contoh to anon, authenticated;

create policy "Item contoh bisa dibaca semua"
    on public.item_contoh
    for select
    to anon, authenticated
    using (true);
