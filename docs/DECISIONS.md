# DECISIONS.md · [Nama kelompok]

Draf v1 · 14 Okt 2026 · masih bisa diperbarui

<!-- Log keputusan. Agen tidak ingat kenapa sebuah perubahan dibuat di sesi sebelumnya. Tanpa catatan ini, agen bisa "memperbaiki" keputusan yang disengaja.

- Satu entri per keputusan yang mengubah perilaku app, scope, atau arsitektur. Perubahan kecil tidak perlu dicatat.
- Entri terbaru di bawah, supaya agen cukup menambah di akhir file.
- Boleh ditulis agen ("Setelah selesai, tambahkan satu entri di DECISIONS.md"), tapi Operator yang memeriksa.
- Commit message memakai format: apa · kenapa · dampak.

Hapus contoh setelah kalian menulis entri pertama. -->

## [Tanggal] · [Keputusan singkat]

- **Keputusan:** [...]
- **Alasan:** [...]
- **Alternatif yang ditolak:** [...]
- **Dampak:** [file, layar, atau test yang terpengaruh]
- **Commit:** [`hash`]

---

## Contoh: Tagih teman

## 30 Okt 2026 · Bagi rata dulu, bagi per item nanti

- **Keputusan:** prototipe hanya mendukung bagi rata. Bagi per item masuk Could di MoSCoW.
- **Alasan:** kriteria sukses adalah mengirim tagihan dalam 60 detik. Bagi per item menambah satu layar dan input per item, dan belum ada bukti pengguna membutuhkannya.
- **Alternatif yang ditolak:** bagi per item sejak awal; scan struk.
- **Dampak:** tidak ada layar input item. Agen tidak boleh menambah pilihan "per item" di layar Bagi rata tanpa entri baru di sini.
- **Commit:** `9c0d7b3` · `Batasi Bagi rata ke pembagian rata · fokus ke kriteria 60 detik · layar input item tidak dibuat`

## 30 Okt 2026 · Pembulatan ke atas untuk teman

- **Keputusan:** bagian tiap teman dibulatkan ke atas ke rupiah penuh; bagian pengirim = total dikurangi bagian semua teman.
- **Alasan:** aturan produk di PRD. Jumlah semua bagian selalu sama dengan total, dan teman tidak pernah ditagih kurang.
- **Alternatif yang ditolak:** pembulatan biasa (jumlah bisa selisih Rp1 dari total); membagi sisa ke teman pertama (terasa tidak adil bagi satu orang).
- **Dampak:** `Core/SplitCalculator.swift`, `Tests/SplitCalculatorTests.swift`, layar Bagi rata. Rp100.000 untuk 3 orang: teman Rp33.334, pengirim Rp33.332.
- **Commit:** `4f2e9a1` · `Bulatkan bagian teman ke atas · jumlah bagian harus sama dengan total · bagian pengirim bisa Rp1–2 lebih kecil`

---

## 30 Okt 2026 · Token BRImo dari prototype, disesuaikan untuk kontras

- **Keputusan:** token warna diambil dari screenshot prototype Lovable (`prototype/screenshots/`). Empat warna digelapkan sedikit supaya lolos WCAG AA (teks 4,5:1, ikon dan grafis 3:1): `accent` #F66B17 → #DF5A09, `success` #1EAB53 → #167F3E, `text-secondary` #62748E → #5B6B84, `danger` #FF453A → #DE0C00. Oranye `accent` hanya untuk isian, ikon dan garis, tidak untuk teks. Mode gelap: `primary` #5AA9FF dengan `on-primary` #002B54 (biru tua di atas biru muda), karena biru yang terbaca di latar hitam terlalu terang untuk teks putih. Ikon di atas `success` dan `accent` memakai `Warna.latar`.
- **Alasan:** app bank dipakai semua umur. Warna asli prototype gagal kontras: teks hijau Otorisasi 2,7:1, ikon oranye 3,0:1, teks sekunder di kartu 4,3:1, label tombol di mode gelap 3,7:1. Pergeseran warnanya kecil, identitas biru dan oranye tetap.
- **Keputusan lain di langkah token:** tanpa gradasi (header memakai navigation bar bawaan iOS, area sapaan Beranda `primary` polos); tanpa bayangan; margin samping 20 dan jarak keypad 12 dibulatkan ke `Space.m`, supaya tidak ada nilai di luar skala.
- **Alternatif yang ditolak:** memakai hex prototype apa adanya (gagal kontras); token warna terpisah khusus teks (`aksenTeks`, `suksesTeks`), karena menambah token yang hanya dipakai di satu tempat; teks putih di atas biru #0A84FF di mode gelap (3,7:1); menambah token spacing 12 dan 20.
- **Dampak:** `DESIGN.md`, `DesignSystem/Tokens.swift`, `DesignSystem/Komponen/Keadaan.swift` (label "Coba lagi" memakai `Warna.utamaTeks`). Layar baru mengikuti aturan di DESIGN.md › Colors. Agen tidak boleh mengembalikan hex prototype atau memakai `Warna.aksen` untuk teks tanpa entri baru di sini.
- **Commit:** [`hash`]

## 30 Okt 2026 · Batas nominal Rp50 juta

- **Keputusan:** transfer dengan nominal lebih dari Rp50.000.000 berisiko tinggi dan wajib passkey. Tepat Rp50.000.000 masih normal. Copy petunjuk "Batas kewajaran: Rp50.000.000". Chip nominal Rp1.000.000, Rp10.000.000, Rp75.000.000. Saldo dummy Rp125.000.000.
- **Alasan:** brief terbaru menyebut 50 juta. Chip dipilih supaya kedua jalur bisa didemokan dengan satu ketukan; saldo dinaikkan supaya Rp75 juta tidak ditolak karena saldo kurang.
- **Alternatif yang ditolak:** batas Rp5.000.000 seperti di prototype.
- **Dampak:** `Core/AturanRisiko.swift`, `Features/Transfer/`, `Services/DataTransfer.swift`.
- **Commit:** [`hash`]

## 30 Okt 2026 · Aturan FDS kedua: jam malam + total 4 jam

- **Keputusan:** risiko tinggi juga kalau transfer pukul 22.00–05.59 dan total transfer berhasil dalam 4 jam terakhir ditambah transfer ini lebih dari Rp30.000.000. Jendela 4 jam dihitung mundur dari sekarang tanpa melihat jam malam; transfer tepat 4 jam lalu tidak dihitung; transfer gagal atau batal tidak dihitung; total tepat Rp30.000.000 normal; zona waktu perangkat. Kalau dua aturan terpenuhi, alasan nominal yang ditampilkan.
- **Alasan:** aturan dari tim FDS. Transfer yang sedang dibuat ikut dihitung, supaya satu transfer Rp45 juta pukul 23.00 tidak lolos.
- **Alternatif yang ditolak:** aturan lokasi/device dan velocity sekarang (ditunda ke T2b, butuh ambang dari tim).
- **Dampak:** `Core/AturanRisiko.swift`, `Services/BankDummy.swift` (riwayat di memori), `-demoJam`, riwayat dummy Rp20 juta satu jam sebelumnya. Test: `Tests/AturanRisikoTests.swift`.
- **Commit:** [`hash`]

## 30 Okt 2026 · Cek FDS sebelum PIN

- **Keputusan:** FDS dicek saat Lanjutkan di layar Transfer, sesuai `docs/userflow.md`. Urutan risiko tinggi: sheet peringatan → PIN → Verifikasi biometrik → Berhasil. Tombol sheet "Lanjutkan ke PIN" (prototype: "Verifikasi dengan Biometrik"), isi sheet ditambah "Setelah memasukkan PIN, Anda akan diminta verifikasi biometrik." Server tetap menilai ulang saat kirim; kalau berubah jadi tinggi, alur dipaksa ke Verifikasi.
- **Alasan:** pilihan PO. Tombol tidak boleh menjanjikan langkah yang belum terjadi.
- **Alternatif yang ditolak:** urutan prototype (PIN dulu, sheet di atas PIN); sheet → biometrik → PIN.
- **Dampak:** `Features/Transfer/`, `Features/PIN/PINModel.swift`.
- **Commit:** [`hash`]

## 30 Okt 2026 · Passkey disimulasikan, biometrik asli

- **Keputusan:** Face ID/Touch ID asli lewat LocalAuthentication (tanpa fallback kode sandi). Passkey disimulasikan: kunci P-256 CryptoKit di memori perangkat menandatangani isi transfer + tantangan sekali pakai dari server; `BankDummy` memverifikasi dengan public key terdaftar. Label "Diamankan dengan Passkey" dan "Diotorisasi dengan Passkey + Biometrik" tetap dipakai.
- **Alasan:** passkey asli butuh domain, entitlement Associated Domains dan server relying party yang belum ada. Secure Enclave tidak ada di Simulator.
- **Alternatif yang ditolak:** `ASAuthorizationController` sekarang; biometrik juga disimulasikan.
- **Dampak:** `Services/Passkey.swift`, `Services/Biometrik.swift`, `App/Info.plist` (`NSFaceIDUsageDescription`). Kunci hilang saat app ditutup. Sebelum produksi: ganti dengan passkey asli dan kunci Secure Enclave.
- **Commit:** [`hash`]

## 30 Okt 2026 · Semua aturan keamanan di server, gagal = berhenti

- **Keputusan:** layar tidak memutuskan apa pun soal keamanan. `BankDummy` mewajibkan: transfer terdaftar lewat cek risiko dengan isi yang sama persis; PIN benar untuk semua transfer (3 kali salah per transfer → terkunci); tanda tangan valid untuk risiko tinggi; tantangan sekali pakai; kirim ulang dengan id yang sama tidak memotong saldo dua kali. Cek FDS, Face ID atau signature yang gagal menghentikan transfer, tidak pernah diteruskan ke jalur normal.
- **Alasan:** layar bisa dimanipulasi; server tidak.
- **Alternatif yang ditolak:** hitungan PIN dan keputusan passkey di model layar.
- **Dampak:** `Services/BankDummy.swift`, `Tests/BankDummyTests.swift`. Agen tidak boleh menambah jalan pintas (misalnya PIN saja kalau Face ID tidak tersedia) tanpa entri baru di sini.
- **Commit:** [`hash`]

## 30 Okt 2026 · PIN dummy dan PIN salah

- **Keputusan:** PIN dummy 000000, hanya di `BankDummy`. Dikirim otomatis di digit ke-6, titik langsung dikosongkan. PIN tidak ikut di `Rute` dan tidak di-log. Salah: "PIN salah. Sisa N kesempatan." + getar; salah ke-3 membatalkan transfer itu. Koneksi putus tidak dihitung salah.
- **Alasan:** pilihan PO (000000). Blokir berwaktu adalah urusan backend asli.
- **Alternatif yang ditolak:** 123456; blokir berwaktu.
- **Dampak:** `Features/PIN/`, `Services/BankDummy.swift`.
- **Commit:** [`hash`]

## 30 Okt 2026 · Tombol Batalkan di sheet peringatan

- **Keputusan:** sheet punya tombol teks "Batalkan transfer" di bawah "Lanjutkan ke PIN"; kembali ke Transfer dengan isian utuh. Sheet tidak bisa digeser. Layar Verifikasi juga punya "Batalkan transfer" (ke Beranda).
- **Alasan:** nasabah yang sadar sedang ditipu harus punya jalan keluar yang jelas. Tetap satu aksi utama per layar.
- **Alternatif yang ditolak:** satu tombol seperti prototype; batal langsung ke Beranda.
- **Dampak:** `Features/Transfer/TransferView.swift`, `Features/Verifikasi/VerifikasiView.swift`.
- **Commit:** [`hash`]

## 30 Okt 2026 · Komponen, Contoh dan rekening tujuan

- **Keputusan:** komponen baru di `DesignSystem/` hanya kalau dipakai dua layar atau lebih: `IkonLingkaran`, `KeadaanMemproses`, parameter `tombol` di `KeadaanGagal` (`Kartu` sudah ada). Sisanya di folder layar. `Features/Contoh` tidak dihapus, hanya tidak lagi jadi layar pertama, karena dipakai docs, Supabase dan test. Rekening tujuan satu dan tetap, seperti prototype. Data tampak asli diganti dummy ("Ayu Contoh", "0000000002", "0000 01 000000 00 1"). Layar Verifikasi menampilkan nominal dan penerima yang diotorisasi.
- **Alasan:** aturan DESIGN.md; perubahan sekecil mungkin di luar alur transfer; nasabah harus melihat apa yang ia tanda tangani.
- **Alternatif yang ditolak:** `KeypadPIN` di DesignSystem (belum ada layar kedua); menghapus Contoh; pemilih rekening tujuan.
- **Dampak:** `DesignSystem/Komponen/`, `App/PrototipeApp.swift`, `Services/DataTransfer.swift`.
- **Commit:** [`hash`]

## 30 Okt 2026 · Logo BRImo, ikon app, launch screen dan header Beranda

- **Keputusan:** logo dari `~/Downloads/BrimoIcon.pdf` (vektor, diberikan tim) dipakai di tiga tempat, semuanya dibuat oleh `scripts/buat-aset-logo.swift` ke `App/Assets.xcassets`: ikon app (latar gradasi biru, "BRI" putih, "mo" biru muda), launch screen (`UILaunchScreen` di Info.plist: logo di atas `WarnaLaunch` #00529C), dan komponen `LogoBRImo` di navigation bar Beranda. Header Beranda: navigation bar biru `Warna.kepala` dengan logo dan lonceng tanpa gelembung kaca, lalu pita gradasi `kepala` → `kepalaTua` berisi sapaan dan kartu saldo. Token `header`, `header-deep` dan `on-header` sengaja sama di mode terang dan gelap. `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` diatur di `Config/Proyek.xcconfig`, bukan di pbxproj.
- **Alasan:** permintaan PO agar Beranda bernuansa BRImo. Warna header adaptif membuat navigation bar (berskema gelap) dan pita di bawahnya berbeda warna. Ini satu-satunya gradasi di app; layar lain tetap memakai navigation bar bawaan.
- **Alternatif yang ditolak:** menggambar ulang logo di SwiftUI; menyalin warna "mo" (#4EC7EB) sebagai token (hanya dipakai di logo); launch screen storyboard.
- **Dampak:** `App/Assets.xcassets/`, `App/Info.plist`, `Config/Proyek.xcconfig`, `DesignSystem/Tokens.swift`, `DesignSystem/Komponen/LogoBRImo.swift`, `Features/Beranda/BerandaView.swift`, `DESIGN.md`. Logo BRImo adalah merek dagang BRI: hanya untuk prototipe workshop, jangan diunggah ke App Store atau TestFlight publik tanpa izin BRI. Kalau logo diganti, jalankan ulang skrip dan cek `batasBRI` (60%) di skrip dan di `LogoBRImo.swift`.
- **Commit:** [`hash`]

## 31 Okt 2026 · Aturan field nominal

- **Keputusan:** field nominal di layar Transfer selalu menampilkan angka rupiah dengan titik ribuan, diperbarui setiap digit diketik atau dihapus. Maksimal 12 digit. Hanya digit 0–9 yang diterima; perubahan yang membawa karakter lain (huruf, koma, minus, spasi, "Rp", digit non-Latin) atau digit ke-13 ditolak utuh, sehingga angka tetap seperti sebelumnya. Aturannya di `ValidasiTransfer.rapikan(ketikan:sebelumnya:)`; field dibind langsung ke `TransferModel.ketikanNominal` dan dirapikan di `onChange`.
- **Alasan:** permintaan PO. Dengan binding get/set sebelumnya, ketikan yang ditolak tetap terlihat di field karena nilai model tidak berubah; tempel "1,5" diam-diam menjadi Rp15 dan tempel 13 digit dipotong menjadi 12 digit pertama, jadi nominal bisa beda dari maksud nasabah.
- **Alternatif yang ditolak:** membuang karakter yang tidak valid lalu memakai sisanya (bisa mengubah nominal tanpa disadari); memotong digit berlebih; menerima "Rp" saat menempel; menampilkan pesan error untuk ketikan yang ditolak.
- **Dampak:** `Core/ValidasiTransfer.swift`, `Features/Transfer/TransferModel.swift`, `Features/Transfer/TransferView.swift`, test di `Tests/AturanRisikoTests.swift` dan `Tests/AlurTransferTests.swift`. Kursor pindah ke akhir setiap kali angka dirapikan (perilaku bawaan TextField saat teks diganti).
- **Commit:** [`hash`]

## 31 Okt 2026 · Pesan saldo tidak cukup tanpa angka saldo

- **Keputusan:** di layar Transfer, nominal yang melebihi saldo hanya menampilkan "Saldo tidak cukup." tanpa menyebut saldo.
- **Alasan:** permintaan PO. Saldo sudah tampil di Beranda, dan pesan pendek lebih cepat dibaca.
- **Alternatif yang ditolak:** "Saldo tidak cukup. Saldo Anda Rp…".
- **Dampak:** `Features/Transfer/TransferView.swift`. `MasalahNominal.melebihiSaldo(saldo:)` tetap membawa saldo untuk test.
- **Commit:** [`hash`]

## 31 Okt 2026 · Tombol "Coba lagi" di Verifikasi Biometrik

- **Keputusan:** saat wajah atau sidik jari tidak dikenali, atau prompt ditutup, layar Verifikasi menampilkan tombol "Coba lagi" yang memanggil Face ID/Touch ID lagi. Pesan menjadi "Wajah tidak dikenali." / "Sidik jari tidak dikenali." (tanpa "Coba lagi." di teks). Lingkaran ikon tetap bisa diketuk.
- **Alasan:** laporan PO: "try again tidak melakukan apapun". Sebelumnya "Coba lagi." hanya teks, bukan tombol. Di Simulator, "Try Face ID Again" di prompt sistem menunggu pilihan Matching/Non-matching Face dari menu Features › Face ID, jadi terlihat seperti tidak terjadi apa-apa.
- **Alternatif yang ditolak:** memulai Face ID otomatis lagi tanpa ketukan (nasabah kehilangan kendali dan bisa terkena lockout).
- **Dampak:** `Features/Verifikasi/`, test `cobaLagiAutentikasiUlang` dan `cobaLagiBerulang` di `Tests/AlurTransferTests.swift`. Permintaan sebelumnya ("biometrik dibatalkan → mundur ke halaman sebelumnya") belum diputuskan dan belum dibangun.
- **Commit:** [`hash`]

## 31 Okt 2026 · Top Up saldo

- **Keputusan:** aksi cepat Top Up di Beranda membuka layar Top Up. Nominal memakai field yang sama dengan Transfer (aturan ketikan sama), chip Rp100.000 / Rp500.000 / Rp1.000.000, minimal Rp10.000 dan maksimal Rp100.000.000 per top up, dicek di layar dan di server. Saldo dummy bertambah langsung di `BankDummy`, tanpa PIN dan tanpa sumber dana. Setiap top up punya id; "Coba lagi" setelah gagal memakai id yang sama, jadi saldo tidak bertambah dua kali kalau jawaban server hilang. Top up tidak masuk Riwayat, tidak membuat notifikasi, dan tidak ikut dihitung FDS.
- **Alasan:** permintaan PO, untuk menambah saldo akun saat demo. Menambah saldo tidak berisiko bagi nasabah, jadi tanpa PIN dan passkey. Riwayat dan notifikasi di app ini khusus transfer dan keamanan transaksi.
- **Alternatif yang ditolak:** PIN untuk top up; sumber dana atau virtual account; top up tanpa batas (hanya dibatasi 12 digit); mencatat top up di Riwayat.
- **Dampak:** `Core/TopUp.swift`, `Features/TopUp/`, `Services/BankDummy.swift`, `Services/LayananData.swift` (dan `LayananDummy`, `LayananSupabase`), `Rute.topUp`, `-demoTopUp`, `DesignSystem/Komponen/FieldNominal.swift` (field dan chip dipindah dari Transfer karena dipakai dua layar), `Tests/TopUpTests.swift`. Batasnya konstanta di `AturanTopUp`.
- **Commit:** [`hash`]

## 31 Okt 2026 · Layar Pilih Rekening Tujuan sebelum Transfer

- **Keputusan:** aksi cepat Transfer di Beranda membuka layar Pilih Rekening Tujuan, berisi 3 rekening tersimpan dummy (Ayu Contoh 0000000002, Citra Contoh 0000000003, Dimas Contoh 0000000004, semua Bank BRI). Satu ketukan membuka Transfer ke rekening itu. Layar ini memuat saldo dan daftar rekening, lalu membawa keduanya ke Transfer lewat `Rute.transfer(_:saldo:)`; state memuat, kosong dan gagal pindah dari Transfer ke sini. Flag `-demoTransfer` diganti `-demoRekening`. Server tetap memeriksa saldo saat kirim. Nomor rekening di baris sendiri dan tidak pernah patah; pada teks besar ikon disembunyikan dan nomor boleh mengecil.
- **Alasan:** permintaan PO. Sebelumnya rekening tujuan satu dan tetap (keputusan 30 Okt, "Komponen, Contoh dan rekening tujuan"), jadi tidak ada cara memilih penerima.
- **Alternatif yang ditolak:** pemilih rekening di dalam layar Transfer (sheet atau menu); input nomor rekening baru (butuh cek nama pemilik rekening, belum ada); Transfer memuat saldo lagi sendiri (dua layar memuat hal yang sama).
- **Dampak:** `Features/PilihRekening/`, `Features/Transfer/TransferModel.swift` dan `TransferView.swift` (tanpa state muat), `Core/Navigasi.swift` (`Rute.pilihRekening`, `Rute.transfer(_:saldo:)`), `Features/Beranda/BerandaModel.swift`, `App/PrototipeApp.swift`, `Services/DataTransfer.swift` (`rekeningTujuan` = 3 kontak), `Services/DemoFlags.swift`, `Services/LayananDummy.swift`, test di `Tests/AlurTransferTests.swift` dan `Tests/TopUpTests.swift`.
- **Commit:** [`hash`]

## 31 Okt 2026 · "Try Face ID Again" di Simulator dan petunjuk khusus Simulator

- **Keputusan:** biometrik dibatalkan tetap di layar Verifikasi (pilihan PO; permintaan "mundur ke halaman sebelumnya" ditutup). Tombol "Try Face ID Again" di alert sistem tidak diubah. Selama Face ID menunggu, layar Verifikasi menampilkan petunjuk "Simulator: Face ID sedang menunggu wajah. Pilih Features › Face ID › Matching Face atau Non-matching Face.", hanya saat `targetEnvironment(simulator)`.
- **Alasan:** laporan PO: "Try Face ID Again" tidak melakukan apa-apa. Alert itu digambar iOS (LocalAuthentication) dan tidak bisa diubah app. Setelah tombol diketuk, iOS memindai ulang di dalam panggilan `evaluatePolicy` yang sama; Simulator menunggu input wajah dari menu dan tidak menampilkan animasi Face ID, jadi terlihat diam. Di iPhone asli tombol itu memindai ulang.
- **Alternatif yang ditolak:** menghilangkan "Try Face ID Again" (tidak ada API-nya); membatalkan evaluasi sendiri dengan timer lalu memulai ulang (memotong pemindaian yang sedang berjalan di iPhone asli); menampilkan petunjuk di build iPhone.
- **Dampak:** `Features/Verifikasi/VerifikasiView.swift`, `docs/userflow.md` (Untuk Tester).
- **Commit:** [`hash`]

## 31 Okt 2026 · Push "Transfer Berhasil" dengan jingle BRImo

- **Keputusan:** setiap transfer berhasil memunculkan push "Transfer Berhasil" (nominal, penerima, metode otorisasi) dengan jingle BRImo. Push dikirim oleh server dummy (`BankDummy.kirim`), tepat sekali per transfer, setelah saldo terpotong. Kirim ulang dengan id yang sama tidak mengirim lagi, dan transfer gagal atau top up tidak mengirim push. Di app, push ditampilkan sebagai notifikasi lokal (`PengirimPushLokal`); banner dan bunyi juga muncul saat app dibuka (`PenanganNotifikasi`). Izin notifikasi diminta saat transfer pertama berhasil, bukan saat app dibuka. Jingle dari `nada_notif_brimo-www_tiengdong_com.mp3` dikonversi ke `App/Suara/notif_brimo.caf` (IMA4, 3,7 detik), karena iOS tidak memutar MP3 sebagai bunyi notifikasi dan bunyi harus ≤ 30 detik di bundle app.
- **Alasan:** permintaan PO. Push asli lewat APNs butuh capability Push Notifications (diubah di Xcode, bukan di pbxproj), sertifikat dan server; prototipe belum punya itu. Push dari server dummy menjaga logikanya di tempat yang sama dengan push asli: server yang tahu transfer benar-benar berhasil, dan tidak mengirim dua kali.
- **Alternatif yang ditolak:** memicu notifikasi dari layar PIN dan Verifikasi (dua tempat, dan bisa dobel saat kirim ulang); meminta izin saat app pertama dibuka; memakai bunyi default iOS.
- **Dampak:** `Services/PushNotifikasi.swift`, `Services/BankDummy.swift` (`push`), `Services/LayananDummy.swift`, `Services/SumberData.swift` (hanya app yang memakai `PengirimPushLokal`; test dan preview tanpa push), `App/PrototipeApp.swift` (delegate), `App/Suara/notif_brimo.caf`, `scripts/push-transfer-berhasil.apns`, `Tests/PushNotifikasiTests.swift`. Jingle adalah aset BRI: hanya untuk prototipe workshop. File MP3 asli masih di akar repo.
- **Commit:** [`hash`]

## 31 Okt 2026 · Jingle transfer berhasil diputar app saat app dibuka

- **Keputusan:** saat transfer berhasil dan app aktif, jingle BRImo diputar app sendiri (`JingleBRImo`, System Sound Services, ikut volume dering dan mode senyap). Banner yang tampil saat app dibuka tidak lagi membawa bunyi (`PenanganNotifikasi.opsiSaatDibuka = [.banner, .list]`), supaya jingle tidak dobel. Saat app di latar belakang, iOS tetap memutar jingle lewat notifikasi. Ditambah `-demoJingle YES` (build debug) untuk mengecek audio tanpa transfer.
- **Alasan:** laporan PO: suara notifikasi tidak terdengar. Diagnosis di Simulator: app tidak punya izin notifikasi (log SpringBoard `effective section info hasResult: 0`), jadi iOS tidak menampilkan banner maupun bunyi; izin hanya bisa diberikan dengan mengetuk Allow, dan izin hilang setiap app dihapus. Sebelumnya jingle hanya dibunyikan notifikasi, sehingga tanpa izin tidak pernah terdengar. Transfer berhasil selalu terjadi di dalam app, jadi pemutaran dari app adalah jalur yang selalu jalan.
- **Alternatif yang ditolak:** meminta izin notifikasi saat app dibuka (mengganggu sebelum nasabah butuh); AVAudioPlayer (perlu mengatur audio session, dan tidak ikut mode senyap); memutar jingle dari app dan notifikasi bersamaan (dobel).
- **Dampak:** `Services/PushNotifikasi.swift`, `Services/DemoFlags.swift`, `App/PrototipeApp.swift`, test `jingleBisaDiputar` dan `bannerTanpaBunyiGanda` di `Tests/PushNotifikasiTests.swift`.
- **Commit:** [`hash`]
