# Bug report · [judul singkat]

Draf v1 · 14 Okt 2026 · masih bisa diperbarui

<!-- Bug report untuk agen. Semakin lengkap, semakin sedikit agen menebak. Diisi Tester saat menemukan bug (di iPhone, Simulator, atau dari uji silang). Tempel isinya ke agen, atau simpan di folder bugs/ dan sebut path-nya di prompt. Hapus bagian contoh setelah kalian mengisi. -->

## Ringkasan

[Satu kalimat: apa yang salah, di layar mana.]

## Yang diharapkan vs yang terjadi

- Diharapkan: [...]
- Terjadi: [...]

## Langkah reproduksi

1. [...]
2. [...]
3. [...]

## Lingkungan

- Perangkat: [iPhone 15 / Simulator iPhone 17 Pro]
- iOS: [...]
- Commit: [`git rev-parse --short HEAD`]

## Screenshot

[Lampirkan. Tandai bagian yang salah.]

## Build log / console

<!-- Potongan baris error yang relevan saja, 3–10 baris. Jangan tempel seluruh log. -->

```text
[...]
```

## File terkait

- [...]

## Yang sudah dicoba

- [...]

## Batasan

- [Yang tidak boleh diubah, misalnya file atau keputusan di DECISIONS.md]

## Instruksi untuk agen

Tulis test yang gagal untuk bug ini dulu, perbaiki akar masalahnya, jangan bungkam error-nya.

---

## Contoh: Tagih teman

**Ringkasan.** Di layar Kirim link, tombol "Kirim link" tetap tidak aktif setelah memilih 3 teman.

**Yang diharapkan vs yang terjadi**

- Diharapkan: tombol "Kirim link" aktif, pratinjau pesan menyebut Ayu, Bima, Citra.
- Terjadi: tombol abu-abu, pratinjau pesan kosong.

**Langkah reproduksi**

1. Pilih transaksi "Makan malam · Warung Bu Sri · Rp240.000", tekan "Tagih teman".
2. Pilih Ayu, Bima, Citra, tekan "Lanjut".
3. Di Bagi rata, tekan "Lanjut".

**Lingkungan.** Simulator iPhone 17 Pro, iOS 27.0, commit `a1b2c3d`. Di iPhone 15 (iOS 18) sama.

**Screenshot.** `bugs/kirim-link-nonaktif.png`

**Build log / console**

```text
2026-10-31 13:05:14.902 TagihTeman[KirimLink] bisaKirim=false teman=0 total=240000
```

**File terkait.** `Features/BagiRata/BagiRataModel.swift` (`lanjut()`), `Features/KirimLink/KirimLinkModel.swift`, `Core/Navigasi.swift` (`Rute`).

**Yang sudah dicoba.** Build ulang, hapus app dari simulator. Hasil sama.

**Batasan.** Jangan ubah `SplitCalculator` (test task 2 sudah lulus). Jangan paksa `isEnabled = true`.

**Instruksi untuk agen.** Tulis test yang gagal untuk bug ini dulu, perbaiki akar masalahnya, jangan bungkam error-nya.
