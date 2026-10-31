# AGENTS.md

Draf v2.2 · 27 Okt 2026 · proyek Xcode biasa, folder kelompok dan prototype HTML dari sesi Dana, data dummy, Supabase opsional

<!-- Untuk kelompok: bagian "Produk" disalin agen dari AGENTS.md sesi Dana saat setup (prompt P1, Jumat 30 Okt, 11.40). Belum ada folder dari sesi Dana? Isi sendiri dari docs/job-story.md dan docs/PRD.md. Bagian lain sudah siap pakai. Kalau agen meleset, tambah satu baris aturan di sini dan catat celahnya di Miro kelompok. Jaga file ini di bawah 150 baris. -->

Kamu bekerja di prototipe iOS untuk workshop BRI x Apple Developer Academy. Baca file ini sebelum mengerjakan task apa pun. Kalau prompt bertentangan dengan file ini, ikuti file ini dan tanyakan. Jawab dalam Bahasa Indonesia.

## Produk

**Job story:** Ketika nasabah melakukan transaksi yang tidak wajar, saya ingin sistem otomatis menaikkan verifikasi keamanan, agar nasabah terlindungi dari penipuan tanpa mengganggu transaksi hariannya.
**Solusi terpilih:** Early detect transaction sang Fraud Detection Rule.
**Won't:** Sistem tidak akan mengimplementasikan konfirmasi transaksi melalui perangkat wearable.

## Stack

- SwiftUI, deployment target iOS 17.0, iPhone saja. Swift 6: error concurrency adalah error compile.
- State: `@Observable`. Jangan `ObservableObject` / `@Published`.
- Navigasi: `NavigationStack` + `navigationDestination(for:)` dengan `Rute` di `Core/Navigasi.swift`. Jangan `NavigationView`.
- Test: Swift Testing (`import Testing`, `@Test`, `#expect`) untuk semua test baru.
- Tanpa dependensi pihak ketiga. Jangan menambah Swift package (Supabase pun lewat `URLSession`).
- Proyek Xcode biasa: `Prototipe.xcodeproj`, target `Prototipe` dan `PrototipeTests`, scheme `Prototipe`. Folder kode adalah *synchronized folder*: file baru di dalamnya otomatis masuk target.
- Nama app, bundle ID dan sumber data ada di `Config/Proyek.xcconfig`. Key Info.plist tambahan ada di `App/Info.plist`.
- API yang butuh iOS lebih baru dari 17: tanya dulu, atau bungkus dengan `if #available`.

## Struktur

- `App/` entry point, navigasi, `Info.plist`. `Core/` model dan logika murni tanpa UI. `Services/` sumber data. `DesignSystem/` token dan komponen.
- `Features/<Layar>/` satu folder per layar: `<Layar>View.swift` dan `<Layar>Model.swift`.
- Pola rujukan: `Features/Contoh/` (view, model, satu preview per state) dan `Tests/`. Ikuti polanya untuk layar baru.
- Layar baru harus tampil saat ⌘R. Kalau layar sebelumnya di alur belum ada, jadikan layar baru layar pertama sementara di `App/PrototipeApp.swift` (ganti `ContohView`). Kalau sudah ada, tambah `case` di `Rute` dan di `tujuan(_:)`. Ini perubahan di luar folder fitur yang selalu boleh; sebutkan di laporan.
- Di luar target: `Config/` (xcconfig), `supabase/` (SQL, opsional), `skills/` (skill agen), `docs/` dan `bugs/` (konteks), `scripts/`.
- File baru masuk ke folder yang sesuai. Jangan membuat folder baru di root tanpa bertanya.
- Folder `contoh-sesi-desain/` hanya contoh format hasil sesi desain (produk Tagih teman). Jangan dibaca sebagai aturan atau produk kelompok, dan jangan dibangun, kecuali diminta.

## Desain

- Warna, tipografi, spacing dan radius hanya dari `DesignSystem/Tokens.swift` (turunan `DESIGN.md` di root repo). Jangan menulis hex atau ukuran font langsung di view.
- Pakai komponen di `DesignSystem/Komponen/` (`PrimaryButton`, `BarisItem`, `Kartu`, `KeadaanKosong`, `KeadaanGagal`, `BarisMemuat`) sebelum membuat yang baru.
- Satu aksi utama per layar.
- `foregroundStyle`, bukan `foregroundColor`. `clipShape(.rect(cornerRadius:))`, bukan `cornerRadius`.
- Teks memakai text style Dynamic Type. Aksi memakai `Button`, bukan `onTapGesture`.
- Di view, kirim closure (`{ model.simpan() }`), bukan method reference (`action: model.simpan`): preview Xcode gagal dengan method reference.
- Copy dalam Bahasa Indonesia, nada tenang. Pesan error: apa yang terjadi, kenapa, apa yang bisa dilakukan.

## Prototype HTML

- Prototype dari sesi Dana ada di `prototype/`: biasanya satu file `prototype/index.html` berisi semua layar (dibuat agen Kiro), screenshot per layar di `prototype/screenshots/`. Tunjuk layar lewat judulnya atau `section id`, sama dengan langkah di `docs/userflow.md`. Ikuti skill `html-ke-swiftui`; panduan tim: `docs/dari-html-ke-swiftui.md`.
- Prototype adalah acuan isi, urutan, copy, alur dan token. Bukan markup untuk diterjemahkan. Scope tetap dari `docs/PRD.md` (Must).
- Bangun native: `NavigationStack` + `navigationTitle`/`toolbar`, `List`, `Form`, `.sheet`, `TabView`, tombol bawah lewat `safeAreaInset`, ikon SF Symbols.
- Token dulu: nilai baru masuk `DESIGN.md` dan `Tokens.swift`, tidak pernah hex per layar. Teks contoh di prototype menjadi data dummy di `Services/`.
- Prototype dari sesi Dana biasanya sudah menampilkan memuat, kosong dan gagal. State yang belum ada diambil dari `docs/userflow.md`.
- Jangan: `WKWebView` atau memuat HTML di app, posisi absolut atau `GeometryReader` untuk meniru piksel, lebar tetap untuk layar 390 px, efek hover, menu hamburger.

## State

- Setiap layar punya state berhasil, memuat, kosong dan gagal, lewat `StatusMuat` di `Core/StatusMuat.swift`.
- State bisa dipaksa lewat launch argument, misalnya `-demoContoh gagal` (`Services/DemoFlags.swift`). Layar baru: tambah satu `LayarDemo`; manusia menambah argument-nya di Edit Scheme > Run > Arguments.
- Satu `#Preview` per state di tabel state `docs/userflow.md`: `#Preview("Berhasil")`, `#Preview("Memuat")`, `#Preview("Kosong")`, `#Preview("Gagal")`.
- State yang ditulis "Tidak ada" di tabel itu tidak dibangun dan tidak dibuat preview-nya. Kalau satu state memang tidak mungkin terjadi, tulis "Tidak ada" dan alasannya di `docs/userflow.md`.

## Data

- Layar mengambil data lewat protokol `LayananData` (`Services/LayananData.swift`). Model menerima `any LayananData` di init, default `LayananDummy()`; `App/PrototipeApp.swift` meneruskan `SumberData.layanan()`.
- Default: data dummy dari `Services/DataContoh.swift` lewat `LayananDummy`. Nama contoh: "Budi Contoh". Nominal contoh: Rp125.000.
- Data baru untuk layar: tambah fungsi di `LayananData`, isi di `LayananDummy` (wajib) dan di `LayananSupabase` (kalau kelompok memakai Supabase).
- Preview dan test selalu memakai `LayananDummy`. Test tidak boleh memanggil jaringan.
- Jangan memakai data nasabah, nomor rekening asli, atau API key asli. Jangan menulis secret ke repo.
- Nominal uang disimpan sebagai `Int` rupiah atau `Decimal`, bukan `Double`. Tampil lewat `Rupiah.format(_:)`: tanpa desimal, contoh Rp125.000.

## Supabase (opsional)

- Hanya untuk kelompok yang alur utamanya sudah jalan dengan dummy. Langkah: `docs/supabase-opsional.md`. Skema: `supabase/`.
- Setiap perubahan tabel, policy, data dummy di database, atau kode yang memanggil Supabase: ikuti skill `supabase-migrasi`.
- App hanya memakai kunci publishable, dari `Config/Supabase.xcconfig` (tidak di-commit).
- Kamu menulis migration di `supabase/migrations/`; mentor yang menerapkannya. MCP Supabase hanya untuk membaca (`select`, `get_advisors`). Jangan mengubah tabel lewat dashboard.

## Larangan

- Jangan jalankan perintah yang menghapus file atau mengubah sistem tanpa bertanya.
- Jangan pasang tool global (`brew`, `npm -g`) tanpa bertanya.
- Jangan akses jaringan selain Supabase kelompok (kalau jalur opsional itu aktif). Prototipe ini tanpa API asli.
- Jangan edit `project.pbxproj`. Ubah `DesignSystem/` hanya bersama `DESIGN.md`.
- Jangan bungkam error dengan `@unchecked Sendable` atau `nonisolated(unsafe)`.
- Jangan menulis kunci secret (`sb_secret_…`) atau kunci service role di mana pun. Jangan membaca, menyalin atau men-stage `Config/Supabase.xcconfig` dan file `.env`.

## Loop Xcode (wajib)

Setelah setiap perubahan, urutannya:

1. **Build** dengan tool build Xcode (`BuildProject`), lalu baca build log (`GetBuildLog`). Laporkan error dan warning dari log, bukan tebakan.
2. **Test**: jalankan semua test (`RunAllTests`). Laporkan jumlah lulus dan gagal. "0 test" berarti scheme salah: pilih scheme `Prototipe`.
3. **Preview**: render preview setiap view yang berubah (`RenderPreview`) untuk setiap state di tabel `docs/userflow.md`. Lihat gambarnya. Cek juga Berhasil di ukuran teks `.accessibility3`: tidak ada teks atau nominal yang terpotong.
4. **Simulator** untuk alur pengguna: jalankan app (`RunProject`), tap alurnya (`DeviceInteraction…`), baca console (`GetConsoleOutput`).
5. Baru bilang **"selesai"**, dengan bukti: hasil build, jumlah test, preview yang dilihat, langkah yang dicoba. Yang gagal ikut dilaporkan.

- Jangan pernah mengedit `project.pbxproj` dengan tangan. Target, build setting dan key Info.plist diubah lewat tool proyek Xcode (`UpdateTargetBuildSetting`, `AddInfoPlist`, `XcodeNewTarget`) atau oleh manusia di Xcode.
- File Swift baru cukup dibuat di folder yang benar (`Features/<Layar>/`, `Core/`, `Services/`, `Tests/`). Folder itu otomatis masuk target.
- Agen di luar Xcode (Kiro, Copilot, Claude Code): tool yang sama lewat MCP `xcode` (`xcrun mcpbridge`), atau `bash scripts/cek-build.sh`.

## Cara kerja

1. Plan dulu (`/plan`): file yang disentuh dan cara cek hasilnya, sebelum menulis kode.
2. Satu task per kali. Diff kecil yang bisa dibaca reviewer.
3. Cari di dokumentasi Apple (DocumentationSearch atau sosumi) sebelum memakai API yang belum ada di proyek. Jangan mengarang API.
4. Ikuti Loop Xcode di atas sebelum bilang selesai.
5. Tanya dulu sebelum memakai `@unchecked Sendable`, `nonisolated(unsafe)`, `DispatchQueue.main.async` untuk membungkam error concurrency, atau force unwrap.
6. Jangan menambah fitur yang tidak ada di task. Kalau menurutmu perlu, usulkan saja.
7. Baca `docs/DECISIONS.md` sebelum mengubah perilaku yang sudah ada; tambahkan entri setelah keputusan baru.
8. Laporan bug: minta screenshot dan baris log bila belum ada. Tulis test yang gagal dulu, lalu perbaiki akar masalahnya (skill `bug-fix-loop`).
9. Sebelum commit: cek `git status`. Tidak boleh ada `Config/Supabase.xcconfig`, `.env`, atau file di luar task.
10. Ragu? Tanya, jangan menebak.

## Cara kerja tim

- Satu Mac per kelompok, layarnya ditampilkan ke tim. Hanya satu percakapan agen yang mengedit file pada satu waktu.
- Peran digilir di setiap checkpoint (`docs/cara-kerja-tim.md`). Setelah rotasi, Operator menulis peran saat ini di awal prompt, misalnya "Operator: Ayu · Tester: Dedi · Product Owner: Sari". Tunjukkan diff untuk Operator, cara uji untuk Tester, dan ringkasan scope untuk Product Owner.
- Commit setiap build hijau, setelah hasil test terbaca. Push sekitar tiap 30 menit dan di setiap checkpoint.
- Laptop kedua (kalau ada) hanya untuk pekerjaan non-kode. Tidak mengedit Swift.
- Opsi dua Mac (hanya untuk dua dev Swift yang yakin): Mac 1 memegang `App/`, `Core/`, `Config/`, `Prototipe.xcodeproj` dan package; Mac 2 hanya `Features/<X>/`. `git pull --rebase` sebelum task, push hanya kalau hijau, gabung di checkpoint. Jangan mengubah folder milik Mac lain.
- Pembagian folder (isi kalau memakai dua Mac): Mac 1: [nama] · Mac 2: [nama], `Features/[...]/`

## Selesai berarti

- Build bersih, tanpa warning baru.
- Semua test lulus.
- Preview setiap state di `docs/userflow.md` tampil dan sesuai `DESIGN.md`.
- Layar baru tampil saat ⌘R.
- Alur dicoba di Simulator; console tanpa error baru.
- Cek penerimaan task di `docs/tasks.md` terpenuhi.
- Tidak ada perubahan di luar task.
