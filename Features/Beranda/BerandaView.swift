import SwiftUI

/// Layar 0 · Beranda (prototype/screenshots/1-beranda.png).
/// Header BRImo: navigation bar bawaan berwarna `Warna.kepala` (status bar ikut putih) dengan logo dan lonceng,
/// lalu pita bergradasi berisi sapaan dan kartu saldo. Gradasi hanya di sini (DESIGN.md › Colors).
struct BerandaView: View {
    @State private var model: BerandaModel
    @Environment(\.dynamicTypeSize) private var ukuranTeks

    init(model: BerandaModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Beranda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarKepala(belumDibaca: model.belumDibaca) { model.bukaNotifikasi() }
                // Judul "Beranda" tetap ada untuk VoiceOver dan tombol kembali; yang tampil logo.
                ToolbarItem(placement: .principal) {
                    Text("Beranda").hidden().accessibilityHidden(true)
                }
            }
            .toolbarBackground(Warna.kepala, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { await model.muncul() }
    }

    @ViewBuilder
    private var konten: some View {
        switch model.status {
        case .memuat:
            isi(akun: DataTransfer.akunPlaceholder)
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Memuat saldo")
        case .kosong:
            KeadaanKosong(ikon: "creditcard", judul: "Belum ada rekening", pesan: "Belum ada rekening yang terhubung.")
        case .gagal(let pesan):
            KeadaanGagal(pesan: pesan) { Task { await model.muat() } }
        case .berhasil(let akun):
            isi(akun: akun)
        }
    }

    private func isi(akun: Akun) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.l) {
                kepala(akun)
                Group {
                    aksiCepat
                    BannerInfo(judul: "Fitur Baru: Transfer Aman",
                               pesan: "Transaksi berisiko tinggi kini dilindungi Passkey + Biometrik.")
                }
                .padding(.horizontal, Space.m)
            }
            .padding(.bottom, Space.l)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    /// Pita biru: sapaan + kartu saldo.
    private func kepala(_ akun: Akun) -> some View {
        VStack(alignment: .leading, spacing: Space.l) {
            VStack(alignment: .leading, spacing: Space.xs) {
                Text(model.sapaan)
                    .font(Teks.isi)
                Text("Halo, \(akun.namaPanggilan) 👋")
                    .font(Teks.judulBesar)
            }
            .foregroundStyle(Warna.kepalaTeks)
            .accessibilityElement(children: .combine)
            kartuSaldo(akun)
        }
        .padding(.horizontal, Space.m)
        .padding(.top, Space.s)
        .padding(.bottom, Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { LatarKepala() }
    }

    private func kartuSaldo(_ akun: Akun) -> some View {
        Kartu {
            HStack(alignment: .center) {
                Text("Saldo Rekening · \(akun.jenisTabungan)")
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.teksSekunder)
                Spacer(minLength: Space.s)
                Button { model.saldoTersembunyi.toggle() } label: {
                    Image(systemName: model.saldoTersembunyi ? "eye.slash" : "eye")
                        .frame(minWidth: Ukuran.sentuhMinimal, minHeight: Ukuran.sentuhMinimal)
                }
                .foregroundStyle(Warna.teksSekunder)
                .accessibilityLabel(model.saldoTersembunyi ? "Tampilkan saldo" : "Sembunyikan saldo")
            }
            Text(model.saldoTersembunyi ? "Rp••••••••" : Rupiah.format(akun.saldo))
                .font(Teks.nominal)
                .foregroundStyle(Warna.utama)
                .monospacedDigit()
                .accessibilityLabel(model.saldoTersembunyi ? "Saldo disembunyikan" : "Saldo \(Rupiah.format(akun.saldo))")
            Text(akun.nomorRekening)
                .font(Teks.keterangan)
                .foregroundStyle(Warna.teksSekunder)
                .accessibilityLabel("Nomor rekening \(akun.nomorRekening)")
        }
    }

    private var aksiCepat: some View {
        let kolom = Array(repeating: GridItem(.flexible(), spacing: Space.m, alignment: .top),
                          count: ukuranTeks.isAccessibilitySize ? 2 : 4)
        return LazyVGrid(columns: kolom, spacing: Space.m) {
            AksiCepat(judul: "Transfer", ikon: "arrow.left.arrow.right", menonjol: true) { model.bukaTransfer() }
            AksiCepat(judul: "Top Up", ikon: "iphone", menonjol: false) { model.bukaTopUp() }
            AksiCepat(judul: "QRIS", ikon: "qrcode", menonjol: false) { model.buka("QRIS") }
            AksiCepat(judul: "Riwayat", ikon: "clock.arrow.circlepath", menonjol: false) { model.bukaRiwayat() }
        }
    }
}

/// Logo di kiri dan lonceng di kanan navigation bar. Di iOS 26 tanpa gelembung kaca,
/// supaya keduanya duduk langsung di atas biru seperti header BRImo.
private struct ToolbarKepala: ToolbarContent {
    let belumDibaca: Int
    let bukaNotifikasi: () -> Void

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarLeading) { logo }
                .sharedBackgroundVisibility(.hidden)
            ToolbarItem(placement: .topBarTrailing) { lonceng }
                .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .topBarLeading) { logo }
            ToolbarItem(placement: .topBarTrailing) { lonceng }
        }
    }

    private var logo: some View {
        LogoBRImo(latar: .gelap, tinggi: 28, tinggiMaks: 34)
    }

    private var lonceng: some View {
        Button(action: bukaNotifikasi) {
            Image(systemName: "bell")
                .font(Teks.judul)
                .foregroundStyle(Warna.kepalaTeks)
                .frame(minWidth: Ukuran.sentuhMinimal, minHeight: Ukuran.sentuhMinimal)
                .overlay(alignment: .topTrailing) {
                    // Titik merah bercincin putih: tetap terlihat di atas biru header.
                    if belumDibaca > 0 {
                        Circle()
                            .fill(Warna.gagal)
                            .overlay { Circle().strokeBorder(Warna.kepalaTeks, lineWidth: 2) }
                            .frame(width: 12, height: 12)
                            .padding(Space.xs)
                    }
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Notifikasi")
        .accessibilityValue(belumDibaca > 0 ? "\(belumDibaca) belum dibaca" : "")
    }
}

/// Latar pita header: gradasi `kepala` → `kepalaTua`, sudut bawah membulat.
/// Bagian polos di atasnya ikut terlihat kalau daftar ditarik ke bawah, jadi tidak ada celah putih di bawah navigation bar.
private struct LatarKepala: View {
    private let perpanjangan: CGFloat = 600

    var body: some View {
        VStack(spacing: 0) {
            Warna.kepala.frame(height: perpanjangan)
            LinearGradient(colors: [Warna.kepala, Warna.kepalaTua], startPoint: .top, endPoint: .bottom)
        }
        .padding(.top, -perpanjangan)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: Radius.xl, bottomTrailingRadius: Radius.xl))
        .accessibilityHidden(true)
    }
}

/// Tombol aksi cepat di Beranda. Transfer menonjol (aksen), yang lain lembut.
private struct AksiCepat: View {
    let judul: String
    let ikon: String
    let menonjol: Bool
    let aksi: () -> Void

    /// Tinggi area ikon sama untuk semua aksi, supaya kotak dan label sejajar walaupun simbolnya beda tinggi.
    @ScaledMetric(relativeTo: .title2) private var tinggiIkon: CGFloat = 36

    var body: some View {
        Button(action: aksi) {
            VStack(spacing: Space.s) {
                Image(systemName: ikon)
                    .font(Teks.judulBesar)
                    .foregroundStyle(menonjol ? Warna.latar : Warna.utama)
                    .frame(maxWidth: .infinity, minHeight: tinggiIkon, maxHeight: tinggiIkon)
                    .padding(.vertical, Space.m)
                    .background(menonjol ? Warna.aksen : Warna.utama.opacity(0.1), in: .rect(cornerRadius: Radius.l))
                Text(judul)
                    .font(Teks.label)
                    .foregroundStyle(Warna.teks)
                    .multilineTextAlignment(.center)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(judul)
        .accessibilityAddTraits(.isButton)
    }
}

/// Banner info fitur. Judul memakai `Warna.teks`: oranye tidak dipakai untuk teks (DESIGN.md › Colors).
private struct BannerInfo: View {
    let judul: String
    let pesan: String

    var body: some View {
        HStack(alignment: .top, spacing: Space.m) {
            Image(systemName: "checkmark.shield.fill")
                .font(Teks.judul)
                .foregroundStyle(Warna.aksen)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Space.xs) {
                Text(judul)
                    .font(Teks.isiTebal)
                    .foregroundStyle(Warna.teks)
                Text(pesan)
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.teksSekunder)
            }
            Spacer(minLength: 0)
        }
        .padding(Space.m)
        .background(Warna.aksen.opacity(0.1), in: .rect(cornerRadius: Radius.l))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.l)
                .strokeBorder(Warna.aksen.opacity(0.4))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Berhasil") {
    NavigationStack { BerandaView(model: .contoh) }
}

#Preview("Memuat") {
    NavigationStack { BerandaView(model: .memuat) }
}

#Preview("Kosong") {
    NavigationStack { BerandaView(model: .kosong) }
}

#Preview("Gagal") {
    NavigationStack { BerandaView(model: .gagal) }
}

#Preview("Teks besar") {
    NavigationStack { BerandaView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
