import SwiftUI

/// Layar 4 · Verifikasi biometrik (prototype/screenshots/5-biometrik-passkey.png).
/// Latar `Warna.utama` dengan teks `Warna.utamaTeks`, seperti prototype. Prompt Face ID digambar iOS.
struct VerifikasiView: View {
    @State private var model: VerifikasiModel
    @ScaledMetric(relativeTo: .largeTitle) private var lingkaran: CGFloat = 144

    init(model: VerifikasiModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .navigationTitle("Verifikasi")
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: model.tahap) { _, baru in
                if case .ulang(let pesan) = baru { AccessibilityNotification.Announcement(pesan).post() }
            }
    }

    @ViewBuilder
    private var konten: some View {
        switch model.tahap {
        case .dibatalkan(let pesan):
            KeadaanGagal(judul: "Transfer dibatalkan", pesan: pesan, tombol: "Kembali ke Beranda") { model.batalkan() }
                .background(Warna.latar)
        case .gagalKirim(let pesan):
            KeadaanGagal(judul: "Transfer belum terkirim", pesan: pesan) { Task { await model.kirim() } }
                .background(Warna.latar)
        case .mengirim:
            KeadaanMemproses(pesan: "Memproses transfer…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Warna.latar)
        case .siap, .memverifikasi, .ulang:
            ViewThatFits(in: .vertical) {
                layarBiometrik
                ScrollView { layarBiometrik }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Warna.utama)
            .foregroundStyle(Warna.utamaTeks)
        }
    }

    private var layarBiometrik: some View {
        VStack(spacing: Space.l) {
            Spacer(minLength: Space.l)
            VStack(spacing: Space.s) {
                Text("Verifikasi Biometrik")
                    .font(Teks.judul)
                    .accessibilityAddTraits(.isHeader)
                Text(model.instruksi)
                    .font(Teks.isi)
                    .multilineTextAlignment(.center)
                // Nasabah melihat apa yang ia otorisasi sebelum memindai.
                Text("Transfer \(Rupiah.format(model.permintaan.nominal)) ke \(model.permintaan.tujuan.nama)")
                    .font(Teks.isiTebal)
                    .multilineTextAlignment(.center)
            }
            Button { Task { await model.verifikasi() } } label: {
                Image(systemName: model.ikon)
                    .resizable()
                    .scaledToFit()
                    .padding(lingkaran * 0.28)
                    .frame(width: lingkaran, height: lingkaran)
                    .background(Warna.utamaTeks.opacity(0.12), in: .circle)
                    .overlay { Circle().strokeBorder(Warna.utamaTeks.opacity(0.4), lineWidth: 2) }
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)
            .disabled(model.sibuk)
            .accessibilityLabel("Verifikasi dengan \(model.namaBiometrik)")
            Group {
                if model.tahap == .memverifikasi {
                    VStack(spacing: Space.s) {
                        ProgressView()
                            .tint(Warna.utamaTeks)
                            .accessibilityLabel("Memverifikasi")
                        #if targetEnvironment(simulator)
                        // Simulator tidak punya kamera dan tidak menampilkan animasi Face ID: setelah "Try Face ID Again"
                        // iOS menunggu wajah dari menu. Tidak ada di build iPhone (docs/DECISIONS.md, 31 Okt 2026).
                        Text("Simulator: Face ID sedang menunggu wajah. Pilih Features › Face ID › Matching Face atau Non-matching Face.")
                            .font(Teks.keterangan)
                            .multilineTextAlignment(.center)
                        #endif
                    }
                } else if case .ulang = model.tahap {
                    EmptyView()
                } else {
                    Text("Ketuk untuk memindai")
                        .font(Teks.isiTebal)
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: Ukuran.sentuhMinimal)
            if case .ulang(let pesan) = model.tahap {
                Label(pesan, systemImage: "exclamationmark.circle")
                    .font(Teks.keterangan)
                    .multilineTextAlignment(.center)
                // Autentikasi ulang: memanggil Face ID / Touch ID lagi. Putih di atas biru, teks biru (kontras ≥ 7:1).
                Button { Task { await model.verifikasi() } } label: {
                    Text("Coba lagi")
                        .font(Teks.tombol)
                        .foregroundStyle(Warna.utama)
                        .frame(maxWidth: .infinity, minHeight: Ukuran.tombol)
                        .background(Warna.utamaTeks, in: .capsule)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Coba lagi dengan \(model.namaBiometrik)")
            }
            Spacer(minLength: Space.l)
            Button("Batalkan transfer") { model.batalkan() }
                .font(Teks.tombol)
                .frame(minHeight: Ukuran.sentuhMinimal)
                .buttonStyle(.borderless)
                .disabled(model.sibuk)
            Label("Diamankan dengan Passkey", systemImage: "key.horizontal")
                .font(Teks.keterangan)
        }
        .padding(Space.l)
    }
}

#Preview("Berhasil") {
    NavigationStack { VerifikasiView(model: .contoh) }
}

#Preview("Memuat") {
    NavigationStack { VerifikasiView(model: .memuat) }
}

#Preview("Kosong") {
    // Tidak ada data yang dimuat; "kosong" = Face ID tidak tersedia, transfer dihentikan.
    NavigationStack {
        VerifikasiView(model: .init(tahap: .dibatalkan("Face ID belum diaktifkan di iPhone ini. Transfer ini butuh verifikasi biometrik, jadi belum bisa diproses.")))
    }
}

#Preview("Gagal") {
    NavigationStack { VerifikasiView(model: .gagal) }
}

#Preview("Wajah tidak dikenali") {
    NavigationStack { VerifikasiView(model: .ulang) }
}

#Preview("Signature ditolak") {
    NavigationStack { VerifikasiView(model: .ditolak) }
}

#Preview("Touch ID") {
    NavigationStack { VerifikasiView(model: .touchID) }
}

#Preview("Teks besar") {
    NavigationStack { VerifikasiView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
