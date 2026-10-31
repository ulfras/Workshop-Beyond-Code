import SwiftUI

/// Layar contoh dengan empat state. Bukan bagian produk kalian: ganti dengan layar 01 dari docs/userflow.md.
struct ContohView: View {
    @State private var model: ContohModel

    init(model: ContohModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Contoh")
            .safeAreaInset(edge: .bottom) {
                PrimaryButton("Lanjut") { model.lanjut() }
                    .disabled(!model.bisaLanjut)
                    .padding(Space.m)
                    .background(Warna.latar)
            }
            .task { await model.muatPertamaKali() }
    }

    @ViewBuilder
    private var konten: some View {
        switch model.status {
        case .memuat:
            BarisMemuat()
        case .kosong:
            KeadaanKosong(ikon: "tray", judul: "Belum ada data", pesan: "Data contoh akan muncul di sini.")
        case .gagal(let pesan):
            KeadaanGagal(pesan: pesan) { Task { await model.muat() } }
        case .berhasil(let daftar):
            List(daftar) { item in
                Button { model.pilih(item) } label: {
                    BarisItem(ikon: item.ikon, judul: item.judul, keterangan: item.keterangan,
                              nominal: item.nominal, terpilih: model.terpilih == item)
                }
                .buttonStyle(.plain)
            }
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview("Berhasil") {
    NavigationStack { ContohView(model: .contoh) }
}

#Preview("Memuat") {
    NavigationStack { ContohView(model: .memuat) }
}

#Preview("Kosong") {
    NavigationStack { ContohView(model: .kosong) }
}

#Preview("Gagal") {
    NavigationStack { ContohView(model: .gagal) }
}
