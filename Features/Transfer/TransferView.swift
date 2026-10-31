import SwiftUI

/// Layar 2 · Transfer (prototype/screenshots/2-transfer.png) dan sheet peringatan (4-peringatan-keamanan.png).
struct TransferView: View {
    @State private var model: TransferModel
    @FocusState private var fokusNominal: Bool
    @FocusState private var fokusCatatan: Bool

    init(model: TransferModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(model.pemeriksaan == .memeriksa)
            .sheet(isPresented: $model.peringatanTampil, onDismiss: { model.sheetTertutup() }) {
                if let alasan = model.alasanPeringatan {
                    PeringatanRisikoSheet(alasan: alasan,
                                          lanjut: { model.lanjutkanKePIN() },
                                          batal: { model.batalkan() })
                }
            }
    }

    /// Data dibawa dari Pilih Rekening Tujuan, jadi tidak ada state memuat, kosong atau gagal saat dibuka.
    private var konten: some View {
        formulir(model.data)
    }

    private func formulir(_ data: TransferModel.DataLayar) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.l) {
                bagian("Rekening Tujuan") {
                    Kartu {
                        Text("\(data.tujuan.nomor) - \(data.tujuan.nama)")
                            .font(Teks.isi)
                            .foregroundStyle(Warna.teks)
                        Text(data.tujuan.bank)
                            .font(Teks.keterangan)
                            .foregroundStyle(Warna.teksSekunder)
                    }
                    .accessibilityElement(children: .combine)
                }
                bagian("Nominal") {
                    FieldNominal(teks: $model.ketikanNominal, labelAksesibilitas: "Nominal transfer dalam rupiah",
                                 fokus: $fokusNominal) { lama, baru in
                        model.ubahNominal(baru, sebelumnya: lama)
                    }
                    petunjukNominal
                    PilihanNominal(pilihan: TransferModel.pilihanNominal, terpilih: model.nominal) {
                        model.pilihNominal($0)
                    }
                }
                bagian("Catatan (opsional)") {
                    TextField("Contoh: bayar arisan", text: $model.catatan)
                        .font(Teks.isi)
                        .foregroundStyle(Warna.teks)
                        .focused($fokusCatatan)
                        .submitLabel(.done)
                        .padding(Space.m)
                        .background(Warna.permukaan, in: .rect(cornerRadius: Radius.l))
                        .overlay { garisFokus(fokusCatatan) }
                }
            }
            .padding(Space.m)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { tombolBawah }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Selesai") { tutupKeyboard() }
            }
        }
    }

    private func tutupKeyboard() {
        fokusNominal = false
        fokusCatatan = false
    }

    private func bagian<Isi: View>(_ judul: String, @ViewBuilder isi: () -> Isi) -> some View {
        VStack(alignment: .leading, spacing: Space.s) {
            Text(judul)
                .font(Teks.isiTebal)
                .foregroundStyle(Warna.teks)
                .accessibilityAddTraits(.isHeader)
            isi()
        }
    }

    @ViewBuilder
    private var petunjukNominal: some View {
        // Saldo tidak disebutkan di pesan (keputusan PO, docs/DECISIONS.md 31 Okt 2026).
        if case .melebihiSaldo = model.masalah {
            Label("Saldo tidak cukup.", systemImage: "exclamationmark.circle")
                .font(Teks.keterangan)
                .foregroundStyle(Warna.gagal)
        } else {
            Label {
                Text("Batas kewajaran: \(Rupiah.format(model.batasKewajaran))")
                    .foregroundStyle(Warna.teksSekunder)
            } icon: {
                Image(systemName: "checkmark.shield")
                    .foregroundStyle(Warna.aksen)
            }
            .font(Teks.keterangan)
        }
    }

    private func garisFokus(_ aktif: Bool) -> some View {
        RoundedRectangle(cornerRadius: Radius.l)
            .strokeBorder(aktif ? Warna.utama : Color.clear, lineWidth: 2)
    }

    private var tombolBawah: some View {
        VStack(spacing: Space.s) {
            if case .gagal(let pesan) = model.pemeriksaan {
                Text(pesan)
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.gagal)
                    .multilineTextAlignment(.center)
            }
            if model.pemeriksaan == .memeriksa {
                KeadaanMemproses(pesan: "Memeriksa keamanan transaksi…")
                    .frame(maxWidth: .infinity, minHeight: Ukuran.tombol)
            } else {
                PrimaryButton(model.pemeriksaan == .siap ? "Lanjutkan" : "Coba lagi") {
                    tutupKeyboard()
                    Task { await model.lanjutkan() }
                }
                .disabled(!model.bisaLanjut)
            }
        }
        .padding(Space.m)
        .background(Warna.latar)
    }
}

/// Sheet "Transaksi Tidak Biasa Terdeteksi". Tidak bisa digeser untuk ditutup: nasabah memilih salah satu tombol.
struct PeringatanRisikoSheet: View {
    let alasan: AlasanRisiko
    let lanjut: () -> Void
    let batal: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Space.m) {
                IkonLingkaran(ikon: "exclamationmark.shield", warna: Warna.aksen)
                Text("Transaksi Tidak Biasa Terdeteksi")
                    .font(Teks.judul)
                    .foregroundStyle(Warna.teks)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(alasan.pesan)
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.teksSekunder)
                    .multilineTextAlignment(.center)
                Text("Setelah memasukkan PIN, Anda akan diminta verifikasi biometrik.")
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.teksSekunder)
                    .multilineTextAlignment(.center)
                PrimaryButton("Lanjutkan ke PIN", aksi: lanjut)
                    .padding(.top, Space.s)
                Button("Batalkan transfer", action: batal)
                    .font(Teks.tombol)
                    .foregroundStyle(Warna.utama)
                    .frame(maxWidth: .infinity, minHeight: Ukuran.sentuhMinimal)
                    .buttonStyle(.borderless)
            }
            .padding(Space.l)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled()
    }
}

#Preview("Berhasil") {
    NavigationStack { TransferView(model: .contoh) }
}

#Preview("Nominal kosong") {
    NavigationStack { TransferView(model: .kosongIsian) }
}

#Preview("Rekening lain") {
    NavigationStack { TransferView(model: .tujuanLain) }
}

#Preview("Melebihi saldo") {
    NavigationStack { TransferView(model: .melebihiSaldo) }
}

#Preview("Memeriksa FDS") {
    NavigationStack { TransferView(model: .memeriksa) }
}

#Preview("FDS gagal") {
    NavigationStack { TransferView(model: .fdsGagal) }
}

#Preview("Peringatan risiko") {
    Color.clear.sheet(isPresented: .constant(true)) {
        PeringatanRisikoSheet(alasan: .nominalBesar(nominal: 75_000_000, batas: 50_000_000), lanjut: {}, batal: {})
    }
}

#Preview("Teks besar") {
    NavigationStack { TransferView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
