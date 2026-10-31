import SwiftUI

/// Layar 6 · Riwayat (tidak ada di prototype; dibangun dari DESIGN.md). Dibuka dari aksi cepat Riwayat di Beranda.
struct RiwayatView: View {
    @State private var model: RiwayatModel

    init(model: RiwayatModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Riwayat")
            .navigationBarTitleDisplayMode(.inline)
            .task { await model.muncul() }
    }

    @ViewBuilder
    private var konten: some View {
        switch model.status {
        case .memuat:
            BarisMemuat()
        case .kosong:
            KeadaanKosong(ikon: "clock.arrow.circlepath", judul: "Belum ada transaksi",
                          pesan: "Transfer yang berhasil akan muncul di sini.")
        case .gagal(let pesan):
            KeadaanGagal(pesan: pesan) { Task { await model.muat() } }
        case .berhasil(let kelompok):
            List {
                ForEach(kelompok) { hari in
                    Section {
                        ForEach(hari.transaksi, id: \.permintaan.id) { bukti in
                            NavigationLink(value: Rute.detailTransaksi(bukti)) {
                                BarisItem(ikon: "arrow.up.right",
                                          judul: bukti.permintaan.tujuan.nama,
                                          keterangan: "\(FormatWaktu.jam(bukti.waktu)) · \(bukti.metode.singkat)",
                                          nominal: -bukti.permintaan.nominal)
                            }
                            .listRowBackground(Warna.permukaan)
                        }
                    } header: {
                        Text(hari.judul)
                            .font(Teks.label)
                            .foregroundStyle(Warna.teksSekunder)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .refreshable { await model.muat(tampilkanMemuat: false) }
        }
    }
}

#Preview("Berhasil") {
    NavigationStack { RiwayatView(model: .contoh) }
}

#Preview("Memuat") {
    NavigationStack { RiwayatView(model: .memuat) }
}

#Preview("Kosong") {
    NavigationStack { RiwayatView(model: .kosong) }
}

#Preview("Gagal") {
    NavigationStack { RiwayatView(model: .gagal) }
}

#Preview("Teks besar") {
    NavigationStack { RiwayatView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
