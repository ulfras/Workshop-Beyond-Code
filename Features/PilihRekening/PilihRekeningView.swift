import SwiftUI

/// Layar 1a · Pilih Rekening Tujuan (tidak ada di prototype; dibangun dari DESIGN.md).
/// Dibuka dari aksi cepat Transfer di Beranda. Satu ketukan pada rekening membuka layar Transfer.
struct PilihRekeningView: View {
    @State private var model: PilihRekeningModel

    init(model: PilihRekeningModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Pilih Rekening Tujuan")
            .navigationBarTitleDisplayMode(.inline)
            .task { await model.muncul() }
    }

    @ViewBuilder
    private var konten: some View {
        switch model.status {
        case .memuat:
            BarisMemuat(jumlah: 3)
        case .kosong:
            KeadaanKosong(ikon: "person.crop.circle.badge.questionmark", judul: "Belum ada rekening tujuan",
                          pesan: "Belum ada rekening tujuan tersimpan.")
        case .gagal(let pesan):
            KeadaanGagal(pesan: pesan) { Task { await model.muat() } }
        case .berhasil(let data):
            List {
                Section {
                    ForEach(data.daftar) { rekening in
                        if let rute = model.rute(untuk: rekening) {
                            NavigationLink(value: rute) {
                                BarisRekening(rekening: rekening)
                            }
                            .listRowBackground(Warna.permukaan)
                            .accessibilityHint("Membuka transfer ke rekening ini")
                        }
                    }
                } header: {
                    Text("Rekening tersimpan")
                        .font(Teks.label)
                        .foregroundStyle(Warna.teksSekunder)
                }
            }
            .scrollContentBackground(.hidden)
            .refreshable { await model.muat(tampilkanMemuat: false) }
        }
    }
}

/// Satu rekening tujuan: nama, bank, nomor. Nomor rekening di baris sendiri dan tidak pernah patah
/// (pada teks besar boleh mengecil); ikon disembunyikan pada teks besar supaya ruangnya cukup.
private struct BarisRekening: View {
    let rekening: Rekening
    @Environment(\.dynamicTypeSize) private var ukuranTeks

    var body: some View {
        HStack(spacing: Space.m) {
            if !ukuranTeks.isAccessibilitySize {
                Image(systemName: "person.fill")
                    .font(Teks.isi)
                    .foregroundStyle(Warna.utama)
                    .frame(width: Ukuran.ikon, height: Ukuran.ikon)
                    .background(Warna.latar, in: .rect(cornerRadius: Radius.s))
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: Space.xs) {
                Text(rekening.nama)
                    .font(Teks.isiTebal)
                    .foregroundStyle(Warna.teks)
                Text(rekening.bank)
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.teksSekunder)
                Text(rekening.nomor)
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.teksSekunder)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(ukuranTeks.isAccessibilitySize ? 0.6 : 1)
            }
            Spacer(minLength: 0)
        }
        .frame(minHeight: Ukuran.sentuhMinimal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(rekening.nama), \(rekening.bank), nomor rekening \(rekening.nomor)")
    }
}

#Preview("Berhasil") {
    NavigationStack { PilihRekeningView(model: .contoh) }
}

#Preview("Memuat") {
    NavigationStack { PilihRekeningView(model: .memuat) }
}

#Preview("Kosong") {
    NavigationStack { PilihRekeningView(model: .kosong) }
}

#Preview("Gagal") {
    NavigationStack { PilihRekeningView(model: .gagal) }
}

#Preview("Teks besar") {
    NavigationStack { PilihRekeningView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
