# BRImo · Transfer Aman

Prototipe iOS (SwiftUI) untuk workshop BRI × Apple Developer Academy, kelompok 3. Ketika nasabah melakukan transfer yang tidak wajar, app otomatis menaikkan verifikasi keamanan: Fraud Detection Rule (FDS) menilai risiko, lalu transfer berisiko tinggi wajib PIN **dan** Passkey + biometrik. Transfer harian tetap cukup dengan PIN.

Semua data adalah data dummy. Tidak ada API bank asli, tidak ada data nasabah. Logo BRImo adalah merek dagang BRI dan hanya dipakai untuk prototipe workshop ini (lihat [Batasan](#batasan)).

## Produk

- **Job story:** Ketika nasabah melakukan transaksi yang tidak wajar, saya ingin sistem otomatis menaikkan verifikasi keamanan, agar nasabah terlindungi dari penipuan tanpa mengganggu transaksi hariannya.
- **Solusi terpilih:** early detect transaction dengan Fraud Detection Rule, plus step-up Passkey untuk transaksi berisiko tinggi.
- **Kriteria sukses** (`docs/PRD.md`):
  1. ≥ 90% transaksi berisiko tinggi (uji skenario) terdeteksi dan memicu step-up Passkey, dengan false-positive ≤ 10% pada transaksi normal.
  2. Transaksi normal selesai ≤ 15 detik tanpa friksi tambahan, dan step-up selesai ≤ 30 detik, diukur pada 5–8 peserta usability test.
- **Won't:** konfirmasi transaksi lewat perangkat wearable.

Detail: `docs/job-story.md` · `docs/PRD.md` · alur dan state: `docs/userflow.md` · task: `docs/tasks.md` · keputusan: `docs/DECISIONS.md` · desain: `DESIGN.md`.

## Alur

| Jalur | Urutan |
| --- | --- |
| Normal | Beranda › Pilih Rekening Tujuan › Transfer › "Memeriksa keamanan transaksi…" › PIN › Transfer Berhasil ("Diotorisasi dengan PIN") |
| Risiko tinggi | Beranda › Pilih Rekening Tujuan › Transfer › sheet "Transaksi Tidak Biasa Terdeteksi" › PIN › Verifikasi Biometrik › Transfer Berhasil ("Diotorisasi dengan Passkey + Biometrik") |

| Layar | Folder | Isi |
| --- | --- | --- |
| Beranda | `Features/Beranda/` | Header BRImo (logo, lonceng dengan titik belum dibaca), sapaan, saldo (bisa disembunyikan), aksi cepat, banner Transfer Aman |
| Pilih Rekening Tujuan | `Features/PilihRekening/` | Tiga rekening tersimpan dummy: Ayu, Citra, Dimas Contoh |
| Transfer | `Features/Transfer/` | Field nominal dengan titik ribuan, chip nominal, catatan, cek FDS, sheet peringatan dengan "Batalkan transfer" |
| Masukkan PIN | `Features/PIN/` | Keypad, 6 titik, dikirim otomatis; maksimal 3 kali salah per transfer |
| Verifikasi Biometrik | `Features/Verifikasi/` | Face ID / Touch ID asli, lalu tanda tangan passkey (simulasi); "Coba lagi" setelah gagal |
| Transfer Berhasil | `Features/Berhasil/` | Bukti: penerima, waktu, catatan, metode otorisasi. Push "Transfer Berhasil" dengan jingle BRImo |
| Riwayat dan Detail Transaksi | `Features/Riwayat/` | Transfer berhasil per hari (Hari ini, Kemarin, tanggal) |
| Notifikasi | `Features/Notifikasi/` | Peringatan risiko, transfer berhasil, transfer dibatalkan |
| Top Up | `Features/TopUp/` | Menambah saldo dummy (Rp10.000–Rp100.000.000 per top up) |

Setiap layar punya state berhasil, memuat, kosong dan gagal (atau "Tidak ada" dengan alasannya), lengkap dengan copy-nya, di tabel state `docs/userflow.md`.

## Keamanan

**Aturan FDS** (`Core/AturanRisiko.swift`). Transaksi berisiko tinggi kalau salah satu terpenuhi:

1. Nominal **lebih dari Rp50.000.000**, kapan pun. Tepat Rp50.000.000 masih normal.
2. Transfer pukul **22.00–05.59**, dan total transfer berhasil dalam **4 jam terakhir plus transfer ini lebih dari Rp30.000.000**.

**Semua aturan dicek di server**, bukan di layar (`Services/BankDummy.swift`). Layar yang dimanipulasi tetap tidak bisa melewati PIN atau passkey:

- Transfer harus didaftarkan lewat cek risiko dulu, dan isinya tidak boleh berubah setelah itu.
- PIN wajib untuk semua transfer.
- FDS dinilai ulang saat kirim. Risiko tinggi tanpa tanda tangan passkey ditolak.
- Tantangan passkey sekali pakai, jadi tanda tangan lama tidak bisa diputar ulang.
- Kirim ulang tidak memotong saldo dua kali.
- Kalau cek FDS, Face ID atau tanda tangan gagal, transfer **berhenti**. Tidak ada jalan pintas ke jalur normal.

**Passkey disimulasikan, biometrik asli.**
- Face ID / Touch ID memakai LocalAuthentication.
- Tanda tangannya memakai kunci P-256 CryptoKit di memori perangkat, lalu diverifikasi backend dummy dengan public key terdaftar (`Services/Passkey.swift`, `Services/Biometrik.swift`).

**Push "Transfer Berhasil"** (`Services/PushNotifikasi.swift`): server dummy mengirim tepat satu push setelah transfer berhasil, lengkap dengan banner dan jingle BRImo (`App/Suara/notif_brimo.caf`), juga saat app dibuka. Ini disimulasikan dengan notifikasi lokal; push asli lewat APNs butuh server dan capability Push Notifications.

Passkey asli belum bisa dibangun karena butuh domain, entitlement Associated Domains dan server relying party. Alasannya di `docs/DECISIONS.md`.

## Menjalankan

1. Buka `Prototipe.xcodeproj`, scheme **Prototipe**, simulator **iPhone 17 Pro** (iOS 17 atau lebih baru).
2. **⌘R** membuka Beranda. **⌘U** menjalankan semua test (Swift Testing).
3. Dari Terminal: `bash scripts/cek-build.sh` (build + test).

Untuk mencoba:

- **PIN dummy: `000000`.** PIN lain dihitung salah; salah 3 kali membatalkan transfer itu.
- **Saldo dummy:** Rp125.000.000. Riwayat dummy berisi satu transfer Rp20.000.000 satu jam sebelum app dibuka.
- **Jalur risiko tinggi:** chip Rp75.000.000.
- **Jalur jam malam:** jalankan dengan argument `-demoJam 23:00`, lalu ketik Rp15.000.000.
- **Face ID di Simulator:** centang Features › Face ID › Enrolled. Saat prompt muncul, pilih Matching Face (lulus) atau Non-matching Face (gagal).
  - Simulator tidak punya kamera. Setelah "Try Face ID Again" diketuk, iOS menunggu kalian memilih wajah lagi dari menu. Selama menunggu, layar Verifikasi menampilkan petunjuknya (hanya di Simulator).
- **Top Up:** Beranda › Top Up › chip Rp500.000 › "Top Up".
- **Push dengan jingle:** transfer pertama yang berhasil meminta izin notifikasi (ketuk Allow). Untuk mendengar jingle tanpa transfer: `xcrun simctl push booted id.workshop.f3.kelompok3 scripts/push-transfer-berhasil.apns`.

**Memaksa state** lewat Xcode › Product › Scheme › Edit Scheme › Run › Arguments, atau `bash scripts/simulator-demo.sh paksa <flag> <nilai>`:

| Flag | Nilai | Untuk |
| --- | --- | --- |
| `-demoBeranda` | `memuat` / `kosong` / `gagal` | Beranda |
| `-demoRekening` | `memuat` / `kosong` / `gagal` | Pilih Rekening Tujuan |
| `-demoFDS` | `gagal` | Cek risiko setelah Lanjutkan |
| `-demoPin` | `gagal` | PIN tidak bisa diperiksa (koneksi) |
| `-demoKirim` | `gagal` | Transfer belum terkirim |
| `-demoSignature` | `gagal` | Server menolak tanda tangan passkey |
| `-demoRiwayat`, `-demoNotifikasi` | `memuat` / `kosong` / `gagal` | Riwayat, Notifikasi |
| `-demoTopUp` | `memuat` / `kosong` / `gagal` | Kirim top up |
| `-demoJam` | `23:00` | Jam server dummy |
| `-demoMulai` | `rekening` / `transfer` / `pin` / `verifikasi` / `berhasil` / `riwayat` / `notifikasi` / `topup` | Build debug: membuka layar itu langsung, untuk screenshot dan cek tata letak |

## Dari starter sampai sekarang

Proyek ini dimulai dari starter workshop (proyek Xcode `Prototipe`, satu layar contoh dengan empat state, aturan agen, 45 skill, template `docs/`). Urutan pengerjaan:

1. **Setup kelompok.**
   - Nama app **BRImo**, bundle ID `id.workshop.f3.kelompok3` (`Config/Proyek.xcconfig`).
   - Bagian Produk di `AGENTS.md` dari sesi desain.
   - Job story, MoSCoW, asumsi dan kriteria sukses dari board sesi desain ke `docs/`.
2. **Prototype.** Prototype dari Lovable, disimpan sebagai tujuh screenshot di `prototype/screenshots/` (1-beranda sampai 7-berhasil-pin). Dari situ dibuat inventaris layar dan daftar celah.
3. **Token** dari screenshot ke `DESIGN.md` dan `DesignSystem/Tokens.swift`. Biru BRI dan oranye aksen digelapkan sedikit supaya lolos kontras WCAG AA di mode terang dan gelap.
4. **Alur transfer:** Beranda, Transfer, PIN, Verifikasi, Berhasil, dengan aturan FDS dan backend dummy. Semua keputusan produk (batas Rp50 juta, aturan jam malam, FDS sebelum PIN, PIN dummy, passkey simulasi, isi state gagal) dicatat di `docs/DECISIONS.md`.
5. **Branding:** logo BRImo dari PDF vektor tim untuk ikon app, launch screen dan header Beranda (`scripts/buat-aset-logo.swift`).
6. **Fitur tambahan atas permintaan PO:**
   - Riwayat dan Notifikasi.
   - Aturan field nominal: titik ribuan langsung, maksimal 12 digit, hanya angka.
   - Top Up.
   - Layar Pilih Rekening Tujuan dengan tiga rekening.
   - Tombol "Coba lagi" di Verifikasi.
   - Push "Transfer Berhasil" dengan jingle BRImo.

Beda yang disengaja dari prototype tercatat di `docs/userflow.md`:
- sheet peringatan muncul sebelum PIN;
- Face ID menggantikan sidik jari;
- nominal tampil "Rp7.500.000" tanpa spasi;
- gradasi hanya di header Beranda;
- tanpa bayangan.

## Status

- Build bersih tanpa warning. **109 fungsi test lulus** (172 run termasuk test berparameter), 0 gagal. Test meliputi aturan FDS, backend dummy (PIN, passkey, tantangan, idempotensi), alur layar, Riwayat, Notifikasi, Top Up dan push.
- Dicek di Simulator iPhone 17 Pro: Beranda, Pilih Rekening, Transfer, PIN, Riwayat, Notifikasi dan Top Up dalam mode terang dan gelap. Sebagian juga dicek dengan teks besar.
- **Belum** dicek manusia:
  - preview di Canvas Xcode;
  - alur penuh dengan ketukan di Simulator;
  - Face ID dengan menu Simulator;
  - usability test untuk kriteria sukses 2.

  Cek penerimaan per task ada di `docs/tasks.md`.

## Batasan

- **Passkey simulasi.** Kunci ada di memori dan hilang saat app ditutup, bukan di Secure Enclave. Sebelum produksi, ganti dengan passkey asli (`ASAuthorizationController`) dan server relying party.
- **Push simulasi.** Notifikasi lokal yang dipicu server dummy, bukan APNs.
- **Jingle BRImo** (dari file `nada_notif_brimo-www_tiengdong_com.mp3`) adalah aset BRI. Pakai hanya untuk prototipe workshop.
- **Backend dummy.** State hanya di memori. Jalur Supabase (`docs/supabase-opsional.md`) belum punya tabel transfer, jadi alur transfer tetap memakai backend dummy.
- **Belum dibangun:** aturan FDS lokasi/device dan velocity (T2b, butuh ambang dari tim), QRIS (T9), top up dari sumber dana asli.
- **Logo BRImo** adalah merek dagang BRI. Pakai hanya untuk prototipe workshop, dan jangan unggah ke App Store atau TestFlight publik tanpa izin BRI.

## Peta repo

```
App/                 entry point (PrototipeApp), Info.plist, Assets.xcassets (ikon, logo, launch screen)
Config/              Proyek.xcconfig (nama app, bundle ID, ikon, sumber data), Supabase.example.xcconfig
Core/                model dan logika murni: Transfer, AturanRisiko (FDS), ValidasiTransfer, TopUp,
                     Riwayat, Notifikasi, Navigasi (Rute), Rupiah, StatusMuat, Sapaan
DesignSystem/        Tokens.swift dan komponen: PrimaryButton, BarisItem, Kartu, Keadaan*, IkonLingkaran,
                     FieldNominal, PilihanNominal, RincianTransfer, LogoBRImo
Features/            satu folder per layar (lihat tabel Alur); Contoh/ = layar contoh starter, tidak dipakai di alur
Services/            LayananData (protokol), LayananDummy + BankDummy (backend dummy), Passkey, Biometrik,
                     DataTransfer (data dummy), DemoFlags, LayananSupabase, SumberData
Tests/               Swift Testing: AturanRisiko, BankDummy, AlurTransfer, Riwayat, Notifikasi, TopUp, starter
docs/                job-story, PRD, userflow, tasks, DECISIONS, panduan workshop (mulai-di-xcode, kartu-prompt, ...)
DESIGN.md            design system BRImo: token YAML + aturan
prototype/           screenshot prototype Lovable (acuan, bukan kode)
scripts/             cek-build.sh, cek-rahasia.sh, simulator-demo.sh, buat-aset-logo.swift, mulai.sh, pasang-skill.sh, impor-dana.sh
skills/              45 skill agen (plug-in Xcode); lisensi di skills/README.md
supabase/            migration dan data dummy untuk jalur opsional (layar contoh)
contoh-sesi-desain/  contoh hasil sesi desain dari starter (produk lain: Tagih teman), bukan bagian produk ini
AGENTS.md            aturan untuk semua agen (GEMINI.md, CLAUDE.md, .github/, .kiro/ merujuk ke sini)
```

Nama target dan scheme tetap "Prototipe"; nama yang tampil di layar adalah **BRImo** (`NAMA_APP`).

## Bekerja dengan agen

| Agen | File aturan | Skill |
| --- | --- | --- |
| Antigravity di Xcode | `GEMINI.md`, lalu `AGENTS.md` | Plug-in Xcode dari `skills/` |
| Claude Agent, Codex di Xcode | `AGENTS.md` (Claude lewat `CLAUDE.md`) | Plug-in Xcode dari `skills/` |
| Kiro | `AGENTS.md`, plus `.kiro/steering/` dan MCP di `.kiro/settings/mcp.json` | `bash scripts/pasang-skill.sh kiro` |
| Copilot for Xcode | `.github/copilot-instructions.md` | Sebut isi skill di prompt |
| Claude Code, Copilot CLI, Gemini CLI | `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | `bash scripts/pasang-skill.sh claude` atau `agents` |

Sebelum mengubah perilaku yang sudah ada, baca `docs/DECISIONS.md`, karena banyak hal di app ini sengaja dibuat begitu. Setup Mac, agen dan izin ada di `docs/mulai-di-xcode.md`. Peran tim ada di `docs/cara-kerja-tim.md`.

## Aturan repo

- Satu task, satu commit, setelah test terbaca hijau. Pesan commit: apa · kenapa · dampak.
- `Prototipe.xcodeproj` di-commit, tapi tidak diedit dengan tangan.
- Jangan commit data nasabah, kunci, `Config/Supabase.xcconfig` atau `.env`. `scripts/cek-rahasia.sh` menolaknya sebelum commit.
- Hasil screenshot dan video agen masuk `marketing/` (tidak di-commit).

## Sumber dan lisensi skill

Skill di `skills/` ditulis oleh penulisnya masing-masing dan disalin apa adanya dari repo asalnya, pada commit yang tercatat di `skills/SKILLS.lock`. Lisensi tiap skill ada di foldernya (`LICENSE.upstream`, `LICENSE.txt`), dan ringkasannya di `skills/README.md`. Sebagian besar MIT; `skill-creator` Apache 2.0; `remotion-best-practices` memakai Remotion License.
