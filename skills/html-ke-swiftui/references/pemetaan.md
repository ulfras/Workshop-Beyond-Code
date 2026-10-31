# Pemetaan HTML/CSS ke SwiftUI

Dipakai di langkah 1 (inventaris) dan langkah 3 (satu layar per loop) skill `html-ke-swiftui`. Kolom kanan adalah titik awal, bukan terjemahan wajib: pilih yang paling native untuk perilaku yang dimaksud prototype.

Nama token (`Space`, `Radius`, `Warna`, `Teks`, `Ukuran`) dan komponen (`PrimaryButton`, `KeadaanKosong`, `KeadaanGagal`, `BarisMemuat`) di bawah dipakai di repo workshop. Repo lain bisa berbeda: cek nama yang benar-benar ada di `DesignSystem/` dan `DESIGN.md`, dan jangan memanggil komponen yang tidak ada. Yang ditulis "komponen baris" atau "komponen kartu" berarti komponen yang sudah ada di `DesignSystem/` untuk peran itu.

## Struktur dan navigasi

| Di prototype | Di SwiftUI | Catatan |
| --- | --- | --- |
| `<header>` / top bar berisi judul | `.navigationTitle("Judul")` di dalam `NavigationStack` | Judul besar bawaan. `.navigationBarTitleDisplayMode(.inline)` untuk layar detail |
| Tombol kembali `←` buatan | Tidak dibangun | `NavigationStack` memberi tombol kembali dan swipe back |
| Ikon aksi di kanan header | `.toolbar { ToolbarItem(placement: .topBarTrailing) { Button { … } label: { Image(systemName: …) } } }` | Tambahkan `.accessibilityLabel` |
| Link antarlayar (`<a href>`, `navigate('/x')`, `<Link>`) | `NavigationLink(value:)` + `navigationDestination(for:)` dengan enum rute repo ini | Lihat `AGENTS.md` › Stack dan file navigasi di `Core/` |
| Tab bar bawah (`<nav class="fixed bottom-0">`) | `TabView { … .tabItem { Label("Beranda", systemImage: "house") } }` | Deployment iOS 17: pakai `.tabItem`, bukan `Tab` |
| Menu hamburger, drawer | Tidak dibangun | Pakai `TabView` atau daftar `NavigationLink`. Tanyakan kalau isinya penting |
| Breadcrumb, footer berisi link | Tidak dibangun | |
| Status bar palsu (`9:41`), home indicator, bingkai ponsel | Tidak dibangun | iOS menggambarnya sendiri |
| `<main>` berisi baris berulang | `List` | Separator, VoiceOver per baris dan swipe ikut gratis |
| `<main>` berisi kartu campuran | `ScrollView { VStack(spacing: Space.m) { … } }` | Hanya kalau isinya memang bukan daftar |
| `<section>` dengan judul kecil | `Section("Judul") { … }` di `List` atau `Form` | |
| Tombol utama `position: fixed/sticky; bottom: 0` | `.safeAreaInset(edge: .bottom) { PrimaryButton("…") { … }.padding(Space.m) }` | Lihat layar yang sudah ada di `Features/` |
| `position: sticky; top: 0` | Navigation bar, atau header `Section` | |

## Daftar, kartu dan state

| Di prototype | Di SwiftUI | Catatan |
| --- | --- | --- |
| `<ul><li>`, `items.map(i => <Row/>)` | `List(items) { … }` atau `ForEach`, dengan komponen baris | Data dari model, bukan dari view |
| Baris yang bisa dipilih (radio, centang) | `Button { model.pilih(item) } label: { … }.buttonStyle(.plain)`, tanda pilih `checkmark.circle.fill` / `circle` | Satu elemen VoiceOver dengan trait `.isSelected` |
| Baris yang membuka layar lain | `NavigationLink(value:)` | Chevron `›` muncul sendiri; jangan digambar |
| `.card` putih bersudut | Komponen kartu, atau `Section` di `List` | |
| `<hr>`, `border-bottom` antarbaris | Separator `List` (otomatis), atau `Divider()` | |
| Badge, pill (`rounded-full px-2 text-xs`) | `Text(…).font(Teks.label).padding(.horizontal, Space.s).padding(.vertical, Space.xs).background(Warna.utama.opacity(0.12), in: .capsule)` | |
| Avatar bulat | `Image(systemName: "person.crop.circle.fill")` atau gambar dengan `.clipShape(.circle)` | |
| Skeleton, spinner | `BarisMemuat()` atau `ProgressView()` | State memuat |
| Pesan "belum ada data" | `KeadaanKosong(ikon:judul:pesan:)` | State kosong |
| Pesan error + "Coba lagi" | `KeadaanGagal(pesan:) { … }` | State gagal |
| Gambar `<img>` ikon | SF Symbol | |
| Foto, ilustrasi, logo | Tanya dulu. Untuk prototipe cukup SF Symbol atau warna polos | Tidak memakai aset BRI |

## Input dan tombol

| Di prototype | Di SwiftUI | Catatan |
| --- | --- | --- |
| `<form>` | `Form { … }` | |
| `<input type="text">` + label | `TextField("Label", text: $model.teks)` | Placeholder jadi `prompt:` |
| Input nominal (`type="number"`) | `TextField("Nominal", value: $model.nominal, format: .number).keyboardType(.numberPad)` | Simpan `Int` rupiah |
| `type="search"` | `.searchable(text: $model.cari)` | |
| Checkbox, switch | `Toggle("Label", isOn: $model.aktif)` | |
| `<select>`, segmented control | `Picker` dengan `.pickerStyle(.segmented)` atau `.menu` | |
| Grup radio | `Picker` dengan `.pickerStyle(.inline)`, atau baris yang bisa dipilih | |
| `type="date"` | `DatePicker` | |
| `<textarea>` | `TextField("…", text: $model.catatan, axis: .vertical)` | |
| Teks error di bawah field | `Text(pesan).font(Teks.keterangan).foregroundStyle(Warna.gagal)` atau footer `Section` | |
| Tombol utama | `PrimaryButton("Lanjut") { model.lanjut() }` | Maksimal satu per layar. Closure, bukan method reference |
| Tombol sekunder, link teks | `Button("…") { … }.buttonStyle(.bordered)` atau `.borderless` | |
| Tombol hapus, batal | `Button("Hapus", role: .destructive) { … }` | |
| Tombol nonaktif (`disabled`, `opacity-50`) | `.disabled(!model.bisaLanjut)` | `PrimaryButton` sudah berubah abu-abu |
| Menu titik tiga | `Menu { … } label: { Image(systemName: "ellipsis") }` | |
| `onClick` di `div` | `Button` | Bukan `onTapGesture` |

## Overlay

| Di prototype | Di SwiftUI | Catatan |
| --- | --- | --- |
| Modal, `<dialog>`, overlay gelap | `.sheet(isPresented:)` atau `.sheet(item:)` | |
| Bottom sheet | `.sheet` + `.presentationDetents([.medium, .large])` | |
| Konfirmasi "Yakin?" | `.confirmationDialog` atau `.alert` | |
| Toast, snackbar | Teks status di layar, atau `.alert` kalau penting | Jangan membuat sistem toast sendiri tanpa task |
| Tooltip, efek hover | Tidak dibangun | Info penting jadi teks keterangan |

## Tata letak dan gaya

| Di prototype | Di SwiftUI | Catatan |
| --- | --- | --- |
| `display: flex` baris / kolom | `HStack` / `VStack` | |
| `justify-content: space-between` | `Spacer()` di antara elemen | |
| `gap: 8px` | `VStack(spacing: Space.s)` | Bulatkan ke skala `Space` |
| `padding: 16px` | `.padding(Space.m)` | |
| `flex: 1`, `width: 100%` | `.frame(maxWidth: .infinity)` | |
| `width: 358px`, `height: 52px` | Tidak ditulis | Pakai `maxWidth` atau token `Ukuran` |
| `display: grid` 2 kolom | `LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())])` atau `Grid` | |
| `position: absolute` (badge di ikon) | `.overlay(alignment: .topTrailing) { … }` atau `ZStack` | Hanya untuk hiasan kecil, bukan tata letak layar |
| `border-radius: 20px` | `.background(Warna.permukaan, in: .rect(cornerRadius: Radius.l))` atau `.clipShape(.rect(cornerRadius: Radius.l))` | |
| `border-radius: 9999px` | `.capsule` | |
| `box-shadow` | Tidak dipakai | `DESIGN.md`: tanpa bayangan |
| `font-size` + `font-weight` | Text style dari `Teks` | Tabel ukuran di `token.md` |
| `font-variant-numeric: tabular-nums` | `.monospacedDigit()` | Untuk nominal |
| `text-overflow: ellipsis` | `.lineLimit(1)` | Utamakan teks yang membungkus, demi Dynamic Type |
| `text-transform: uppercase` | Tidak dipakai | Kecuali header `Section` |
| `letter-spacing`, `line-height` | Tidak ditulis | SF mengatur sendiri |
| `@media (prefers-color-scheme: dark)`, `.dark` | Nilai `gelap:` di `Tokens.swift` | |
| `@media (min-width: …)` | Diabaikan | iPhone saja |
| `transition`, `animation` | Diabaikan, atau `withAnimation` untuk perubahan state yang berarti | |

## Aksesibilitas

| Di prototype | Di SwiftUI |
| --- | --- |
| `aria-label` | `.accessibilityLabel("…")` |
| `alt` gambar bermakna | `.accessibilityLabel("…")` |
| Gambar hiasan, `aria-hidden` | `.accessibilityHidden(true)` |
| Baris berisi beberapa teks | `.accessibilityElement(children: .combine)` |
| `role="button"` di `div` | `Button` |

## React/JSX (v0, Lovable)

| Di prototype | Di SwiftUI |
| --- | --- |
| `useState` | Properti di model `@Observable` |
| `useEffect(() => fetch…)` | `.task { await model.muatPertamaKali() }` |
| `loading ? <Spinner/> : …` | `switch` pada status layar di model (lihat `AGENTS.md` › State) |
| `react-router`, `next/link`, `useNavigate` | Enum rute + `NavigationLink` / `navigationDestination` |
| Redux, Zustand, React Query, Supabase client | Diabaikan. Data lewat layanan data di `Services/` |
| shadcn `<Button>` | `PrimaryButton` (utama) atau `Button` dengan `.bordered` |
| `<Card>` | Komponen kartu, atau `Section` |
| `<Input>`, `<Label>` | `TextField` di `Form` |
| `<Dialog>`, `<AlertDialog>` | `.sheet`, `.alert` |
| `<Sheet side="bottom">`, `<Drawer>` | `.sheet` + `.presentationDetents` |
| `<Tabs>` di dalam layar | `Picker` `.segmented` |
| `<Switch>`, `<Checkbox>` | `Toggle` |
| `<Select>` | `Picker` |
| `<Badge>` | `Text` dalam `.capsule` |
| `<Skeleton>` | `BarisMemuat` atau `.redacted(reason: .placeholder)` |
| `<Separator>` | `Divider()` |
| `<Avatar>` | `Image` dengan `.clipShape(.circle)` |
| `<Toast>`, `<Sonner>` | Lihat Overlay |

## Ikon: icon font ke SF Symbols

Material Symbols, Font Awesome, Lucide dan Heroicons memakai nama mirip. Ambil yang paling dekat; kalau ragu, sebutkan di laporan.

| Prototype | SF Symbol |
| --- | --- |
| `search` | `magnifyingglass` |
| `home` | `house` |
| `person`, `user` | `person` |
| `group`, `users` | `person.2` |
| `notifications`, `bell` | `bell` |
| `settings` | `gearshape` |
| `add`, `plus` | `plus` |
| `close`, `x` | `xmark` |
| `check_circle` | `checkmark.circle.fill` |
| `chevron_right` | `chevron.right` (di `NavigationLink` tidak perlu) |
| `share` | `square.and.arrow.up` |
| `send` | `paperplane` |
| `more_vert`, `more_horiz` | `ellipsis` |
| `delete`, `trash` | `trash` |
| `edit`, `pencil` | `pencil` |
| `info` | `info.circle` |
| `warning` | `exclamationmark.triangle` |
| `lock` | `lock` |
| `visibility` / `visibility_off` | `eye` / `eye.slash` |
| `history` | `clock.arrow.circlepath` |
| `qr_code` / `qr_code_scanner` | `qrcode` / `qrcode.viewfinder` |
| `credit_card` | `creditcard` |
| `payments`, `banknote` | `banknote` |
| `account_balance` | `building.columns` |
| `wallet` | `wallet.pass` |
| `bolt`, `zap` | `bolt` |
| `arrow_downward` dalam lingkaran | `arrow.down.circle` |
| `coffee` | `cup.and.saucer` |
