-- seed.sql · data dummy untuk proyek Supabase kelompok. Sama dengan Services/DataContoh.swift.
-- Nama dan nominal contoh, bukan data nasabah. Aman dijalankan ulang (on conflict do nothing).
-- Mentor menjalankannya sekali setelah 0001_contoh.sql. Supabase tidak menjalankan file ini otomatis
-- di proyek yang sudah ada; data dummy baru setelah itu ditulis sebagai migration baru.

insert into public.item_contoh (id, judul, keterangan, nominal, ikon) values
    ('ITM-01', 'Budi Contoh', 'Transfer masuk · Hari ini', 125000, 'arrow.down.circle'),
    ('ITM-02', 'Tagihan listrik', 'Jatuh tempo 5 Nov', 350000, 'bolt'),
    ('ITM-03', 'Ngopi sore', 'Kedai Kopi Senja · Kemarin', 86000, 'cup.and.saucer')
on conflict (id) do nothing;
