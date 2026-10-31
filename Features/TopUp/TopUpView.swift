import SwiftUI

/// Layar 8 · Top Up (tidak ada di prototype; dibangun dari DESIGN.md dan pola layar Transfer).
/// Tidak memuat apa pun saat dibuka, jadi tanpa state memuat/kosong saat muat (docs/userflow.md).
struct TopUpView: View {
    @State private var model: TopUpModel
    @FocusState private var fokusNominal: Bool

    init(model: TopUpModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Top Up")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(model.sibuk || model.tahap.selesai)
    }

    @ViewBuilder
    private var konten: some View {
        if case .selesai(let bukti) = model.tahap {
            berhasil(bukti)
        } else {
            formulir
        }
    }

    private var formulir: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.s) {
                Text("Nominal top up")
                    .font(Teks.isiTebal)
                    .foregroundStyle(Warna.teks)
                    .accessibilityAddTraits(.isHeader)
                FieldNominal(teks: $model.ketikanNominal, labelAksesibilitas: "Nominal top up dalam rupiah",
                             fokus: $fokusNominal) { lama, baru in
                    model.ubahNominal(baru, sebelumnya: lama)
                }
                .disabled(model.sibuk)
                petunjuk
                PilihanNominal(pilihan: AturanTopUp.pilihanNominal, terpilih: model.nominal) {
                    model.pilihNominal($0)
                }
                .disabled(model.sibuk)
            }
            .padding(Space.m)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { tombolBawah }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Selesai") { fokusNominal = false }
            }
        }
    }

    @ViewBuilder
    private var petunjuk: some View {
        switch model.masalah {
        case .kurangDariMinimal(let minimal):
            Label("Minimal top up \(Rupiah.format(minimal)).", systemImage: "exclamationmark.circle")
                .font(Teks.keterangan)
                .foregroundStyle(Warna.gagal)
        case .melebihiMaksimal(let maksimal):
            Label("Maksimal top up \(Rupiah.format(maksimal)).", systemImage: "exclamationmark.circle")
                .font(Teks.keterangan)
                .foregroundStyle(Warna.gagal)
        case .kosong, nil:
            Text("Minimal \(Rupiah.format(AturanTopUp.minimal)), maksimal \(Rupiah.format(AturanTopUp.maksimal)) per top up.")
                .font(Teks.keterangan)
                .foregroundStyle(Warna.teksSekunder)
        }
    }

    private var tombolBawah: some View {
        VStack(spacing: Space.s) {
            if case .gagal(let pesan) = model.tahap {
                Text(pesan)
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.gagal)
                    .multilineTextAlignment(.center)
            }
            if model.sibuk {
                KeadaanMemproses(pesan: "Memproses top up…")
                    .frame(maxWidth: .infinity, minHeight: Ukuran.tombol)
            } else {
                PrimaryButton(judulTombol) {
                    fokusNominal = false
                    Task { await model.topUp() }
                }
                .disabled(!model.bisaTopUp)
            }
        }
        .padding(Space.m)
        .background(Warna.latar)
    }

    private var judulTombol: String {
        if case .gagal = model.tahap { return "Coba lagi" }
        return "Top Up"
    }

    private func berhasil(_ bukti: BuktiTopUp) -> some View {
        ScrollView {
            VStack(spacing: Space.l) {
                IkonLingkaran(ikon: "checkmark", warna: Warna.sukses, gaya: .penuh)
                    .padding(.top, Space.xl)
                VStack(spacing: Space.xs) {
                    Text("Top Up Berhasil")
                        .font(Teks.judulBesar)
                        .foregroundStyle(Warna.teks)
                        .accessibilityAddTraits(.isHeader)
                    Text(Rupiah.format(bukti.permintaan.nominal))
                        .font(Teks.nominal)
                        .foregroundStyle(Warna.utama)
                        .monospacedDigit()
                }
                .multilineTextAlignment(.center)
                Kartu {
                    VStack(spacing: Space.m) {
                        BarisRincian(label: "Saldo sekarang", nilai: Rupiah.format(bukti.saldoBaru))
                        BarisRincian(label: "Waktu", nilai: FormatWaktu.lengkap(bukti.waktu))
                    }
                }
            }
            .padding(Space.m)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton("Kembali ke Beranda") { model.kembaliKeBeranda() }
                .padding(Space.m)
                .background(Warna.latar)
        }
        .onAppear { AccessibilityNotification.Announcement("Top up berhasil").post() }
    }
}

private extension TopUpModel.Tahap {
    var selesai: Bool {
        if case .selesai = self { return true }
        return false
    }
}

#Preview("Berhasil") {
    NavigationStack { TopUpView(model: .contoh) }
}

#Preview("Nominal kosong") {
    NavigationStack { TopUpView(model: .kosongIsian) }
}

#Preview("Kurang dari minimal") {
    NavigationStack { TopUpView(model: .kurangDariMinimal) }
}

#Preview("Melebihi maksimal") {
    NavigationStack { TopUpView(model: .melebihiMaksimal) }
}

#Preview("Memproses") {
    NavigationStack { TopUpView(model: .memproses) }
}

#Preview("Gagal") {
    NavigationStack { TopUpView(model: .gagal) }
}

#Preview("Tanpa rekening") {
    NavigationStack { TopUpView(model: .tanpaRekening) }
}

#Preview("Top up berhasil") {
    NavigationStack { TopUpView(model: .selesai) }
}

#Preview("Teks besar") {
    NavigationStack { TopUpView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
