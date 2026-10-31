import SwiftUI

/// Layar 3 · Masukkan PIN (prototype/screenshots/3-pin.png).
struct PINView: View {
    @State private var model: PINModel

    init(model: PINModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Masukkan PIN")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(model.tahap != .mengisi)
            .sensoryFeedback(.error, trigger: model.jumlahSalah)
            .onChange(of: model.pesan) { _, baru in
                if let baru { AccessibilityNotification.Announcement(baru).post() }
            }
    }

    @ViewBuilder
    private var konten: some View {
        switch model.tahap {
        case .dibatalkan(let pesan):
            KeadaanGagal(judul: "Transfer dibatalkan", pesan: pesan, tombol: "Kembali ke Beranda") {
                model.kembaliKeBeranda()
            }
        case .gagalKirim(let pesan):
            KeadaanGagal(judul: "Transfer belum terkirim", pesan: pesan) { Task { await model.kirim() } }
        case .mengirim:
            KeadaanMemproses(pesan: "Memproses transfer…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .mengisi, .memeriksa:
            ViewThatFits(in: .vertical) {
                susunan
                ScrollView { susunan }
            }
        }
    }

    private var susunan: some View {
        VStack(spacing: Space.l) {
            Spacer(minLength: Space.m)
            Image(systemName: "key.horizontal")
                .font(Teks.judulBesar)
                .foregroundStyle(Warna.utama)
                .accessibilityHidden(true)
            Text("Masukkan 6 digit PIN BRImo Anda")
                .font(Teks.keterangan)
                .foregroundStyle(Warna.teksSekunder)
                .multilineTextAlignment(.center)
            TitikPIN(terisi: model.jumlahDigit, panjang: PINModel.panjang)
            Group {
                if model.tahap == .memeriksa {
                    KeadaanMemproses(pesan: "Memeriksa PIN…")
                } else if let pesan = model.pesan {
                    Text(pesan)
                        .font(Teks.keterangan)
                        .foregroundStyle(Warna.gagal)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(minHeight: Ukuran.sentuhMinimal)
            Spacer(minLength: Space.m)
            KeypadPIN(aktif: model.tahap == .mengisi,
                      ketik: { angka in Task { await model.ketik(angka) } },
                      hapus: { model.hapus() })
        }
        .padding(Space.m)
    }
}

/// Enam titik PIN. VoiceOver membaca jumlah digit, bukan digitnya.
private struct TitikPIN: View {
    let terisi: Int
    let panjang: Int
    @ScaledMetric(relativeTo: .title) private var ukuran: CGFloat = 16

    var body: some View {
        HStack(spacing: Space.m) {
            ForEach(0..<panjang, id: \.self) { indeks in
                Circle()
                    .fill(indeks < terisi ? Warna.utama : Color.clear)
                    .overlay { Circle().strokeBorder(Warna.utama, lineWidth: 2) }
                    .frame(width: ukuran, height: ukuran)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("PIN")
        .accessibilityValue("\(terisi) dari \(panjang) digit terisi")
    }
}

/// Keypad angka 0–9 dan hapus.
private struct KeypadPIN: View {
    let aktif: Bool
    let ketik: (Int) -> Void
    let hapus: () -> Void

    private enum Tombol: Hashable {
        case angka(Int)
        case hapus
        case kosong
    }

    private let baris: [[Tombol]] = [
        [.angka(1), .angka(2), .angka(3)],
        [.angka(4), .angka(5), .angka(6)],
        [.angka(7), .angka(8), .angka(9)],
        [.kosong, .angka(0), .hapus]
    ]

    var body: some View {
        Grid(horizontalSpacing: Space.m, verticalSpacing: Space.m) {
            ForEach(baris, id: \.self) { isiBaris in
                GridRow {
                    ForEach(isiBaris, id: \.self) { tombol in
                        sel(tombol)
                    }
                }
            }
        }
        .disabled(!aktif)
        .opacity(aktif ? 1 : 0.6)
    }

    @ViewBuilder
    private func sel(_ tombol: Tombol) -> some View {
        switch tombol {
        case .angka(let angka):
            Button { ketik(angka) } label: {
                Text("\(angka)")
                    .font(Teks.judulBesar)
                    .foregroundStyle(Warna.teks)
                    .frame(maxWidth: .infinity, minHeight: Ukuran.tombol)
            }
            .buttonStyle(GayaTombolKeypad())
            .accessibilityLabel("\(angka)")
        case .hapus:
            Button(action: hapus) {
                Image(systemName: "delete.left")
                    .font(Teks.judul)
                    .foregroundStyle(Warna.teks)
                    .frame(maxWidth: .infinity, minHeight: Ukuran.tombol)
            }
            .buttonStyle(GayaTombolKeypad())
            .accessibilityLabel("Hapus digit")
        case .kosong:
            // Tidak ikut menentukan ukuran baris: tingginya mengikuti tombol 0 dan hapus di sebelahnya.
            Color.clear
                .gridCellUnsizedAxes([.horizontal, .vertical])
                .accessibilityHidden(true)
        }
    }
}

private struct GayaTombolKeypad: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Warna.permukaan, in: .rect(cornerRadius: Radius.l))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(.rect)
    }
}

#Preview("Berhasil") {
    NavigationStack { PINView(model: .contoh) }
}

#Preview("Memuat") {
    NavigationStack { PINView(model: .memuat) }
}

#Preview("Kosong") {
    NavigationStack { PINView(model: .kosong) }
}

#Preview("Gagal") {
    NavigationStack { PINView(model: .gagal) }
}

#Preview("PIN salah") {
    NavigationStack { PINView(model: .salah) }
}

#Preview("PIN terkunci") {
    NavigationStack { PINView(model: .terkunci) }
}

#Preview("Memproses transfer") {
    NavigationStack { PINView(model: .mengirim) }
}

#Preview("Gagal kirim") {
    NavigationStack { PINView(model: .gagalKirim) }
}

#Preview("Teks besar") {
    NavigationStack { PINView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
