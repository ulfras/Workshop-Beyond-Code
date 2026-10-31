# Cara kerja tim

Satu **Mac** per kelompok, layarnya ditampilkan ke tim. Agen mengedit kode hanya di Mac itu. Peran digilir di setiap checkpoint.

## Peran

| Peran | Tugas |
| --- | --- |
| **Operator AI** | Satu-satunya yang mengetik ke agen. Hanya satu percakapan agen yang mengedit file pada satu waktu. Menjelaskan setiap perubahan ke tim sebelum commit (P9), menolak solusi "asal jalan": force unwrap, `@unchecked Sendable`, test dilemahkan. Commit setiap build hijau |
| **Tester** | Mengecek empat state (berhasil, memuat, kosong, gagal) di Simulator atau iPhone sendiri. Menempel temuan dan celah konteks di Miro kelompok, satu sticky per temuan; temuan teratas ditulis jadi bug report di `bugs/` (salin `bugs/_template.md`). Saat agen meleset, menambah satu baris aturan di `AGENTS.md` |
| **Product Owner** | Menjaga job story dan scope (hanya Must). Membaca rencana agen dan mencoret yang di luar task. Mengurutkan `docs/tasks.md`, memilih task berikutnya, memotong scope kalau waktu habis |

Tiga peran ini masih **draf** (usulan F3, dikonfirmasi dengan Kak Dana). Kelompok berlima: dua Tester.

## Rotasi

Peran bergeser satu orang di setiap checkpoint: **13.25 · 14.30 · 15.30 · 16.05**. Setiap orang memegang keyboard sebagai Operator minimal satu sprint.

**Yang menulis prompt, dia yang menjelaskan hasilnya.** Sebelum commit, Operator menjelaskan ke kelompok apa yang diubah agen dan kenapa, dengan kata-katanya sendiri. Kalau belum bisa menjelaskan, belum commit: minta agen menjelaskan diff-nya dulu.

Setelah rotasi, Operator yang baru menulis peran saat ini di awal prompt, misalnya: "Operator: Ayu · Tester: Sari · Product Owner: Budi." Agen lalu tahu kepada siapa diff dan cara uji ditunjukkan.

## Aturan

- Satu Mac. Satu percakapan agen yang mengedit.
- Commit setiap build hijau, setelah hasil test terbaca. Pesan commit: apa · kenapa · dampak · nama Operator, misalnya "Bagi rata dengan empat state · task T5b · alur utama lengkap · Operator: Ayu". Di showcase, `git log` menunjukkan siapa membangun bagian mana.
- Push sekitar tiap 30 menit dan di setiap checkpoint (Xcode › Integrate › Push).
- Cek daftar file sebelum commit (Xcode › Integrate › Commit). `Config/Supabase.xcconfig` dan `.env` tidak boleh ikut.
- Agen meleset? Perbaiki konteksnya (`AGENTS.md`, `DESIGN.md`, `docs/`), bukan prompt-nya.

## Laptop kedua (sidecar)

Boleh, hanya untuk pekerjaan non-kode: Supabase dashboard (jalur opsional), menulis bug report, menyiapkan cerita demo. Laptop ini **tidak mengedit Swift** dan tidak commit. Hasilnya (teks, screenshot) dikirim ke Operator lewat AirDrop atau chat.

## Opsi dua Mac

Hanya untuk kelompok dengan **dua dev Swift yang yakin**.

- **Mac 1** memegang `App/`, `Core/`, `Config/`, `Prototipe.xcodeproj` dan package. **Mac 2** hanya `Features/<X>/` (satu layar).
- Tulis pembagiannya di `AGENTS.md` › Cara kerja tim, supaya agen di kedua Mac tahu batasnya.
- `git pull --rebase` sebelum mulai task. Push hanya kalau build dan test hijau. Gabungkan di setiap checkpoint, lalu ⌘U di kedua Mac.
- Empat laptop atau empat worktree: tidak disarankan.

## Kalau terjadi merge conflict

1. Jangan `--force` dan jangan menghapus folder.
2. Konflik di file Swift atau Markdown: buka file itu, pilih isi yang benar, hapus tanda `<<<<<<<`, `=======`, `>>>>>>>`. Build dan test, lalu `git add <file>` dan `git rebase --continue`.
3. Boleh minta agen: "Ada merge conflict di <file>. Jelaskan dua versinya. Jangan pilih sendiri." Product Owner yang memutuskan.
4. Konflik di `project.pbxproj`: jangan diedit dengan tangan. `git rebase --abort`, lalu panggil mentor. Biasanya tanda pembagian folder dilanggar.
5. Ragu? `git rebase --abort` mengembalikan keadaan sebelum pull.

## Linimasa

**Jumat 30 Okt**

| Jam | Kegiatan |
| --- | --- |
| 11.40–12.00 | Setup kelompok (`docs/mulai-di-xcode.md`) |
| 12.00–13.00 | Istirahat dan salat Jumat |
| 13.00 | Sprint 0: layar inti pertama dengan empat state |
| 13.25 | Checkpoint · rotasi peran |
| 13.40 | Urutkan `docs/tasks.md`, pilih 3 task untuk sprint 1 |
| 14.10 | Sprint 1 |
| 14.30 | Checkpoint · rotasi peran |
| 14.50 | Standup |
| 15.30 | Check-in · rotasi peran |
| 15.40 | Sprint 2 |
| 16.05 | Checkpoint · rotasi peran |
| 16.25 | Siap diuji: commit, push, app jalan di Simulator |
| 16.30–16.55 | Uji silang antarkelompok |

**Sabtu 31 Okt**

| Jam | Kegiatan |
| --- | --- |
| 08.30 | Mulai: recap dan pilih temuan utama |
| 08.45 | Finalize sprint: selesaikan alur utama dulu, lalu perbaikan bug dari uji silang (skill `bug-fix-loop`). Checkpoint 09.30 |
| 10.15 | Istirahat. Commit dulu sebelum meninggalkan meja |
| 10.30 | Uji silang putaran 2: kelompok lain mengecek perbaikan |
| 11.00 | Freeze: build dibekukan |
| 11.00–12.00 | Media showcase: screenshot dan video (skill `app-demo-media`), lalu latihan pitch |
| 12.00–13.00 | Istirahat dan makan siang |
| 13.00–14.15 | Showcase |
| 14.15–14.30 | Refleksi dan penutup |
