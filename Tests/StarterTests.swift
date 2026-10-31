import Testing
@testable import Prototipe

struct RupiahTests {
    @Test("Nominal tampil tanpa desimal, titik sebagai pemisah ribuan",
          arguments: [(125_000, "Rp125.000"), (0, "Rp0"), (500, "Rp500"), (1_250_000, "Rp1.250.000"), (-60_000, "-Rp60.000")])
    func format(nilai: Int, teks: String) {
        #expect(Rupiah.format(nilai) == teks)
    }
}

@MainActor
struct ContohModelTests {
    @Test("Memuat data dummy: state berhasil")
    func memuat() async {
        let model = ContohModel(layanan: LayananDummy(jeda: .zero, ikutiDemoFlags: false))
        await model.muat()
        guard case .berhasil(let daftar) = model.status else {
            Issue.record("State seharusnya berhasil")
            return
        }
        #expect(daftar.count == DataContoh.item.count)
    }

    @Test("Lanjut nonaktif sebelum memilih, lalu membuka layar berikutnya")
    func lanjut() {
        let navigasi = Navigasi()
        let model = ContohModel(status: .berhasil(DataContoh.item))
        #expect(!model.bisaLanjut)
        let modelDenganNavigasi = ContohModel(navigasi: navigasi)
        modelDenganNavigasi.pilih(DataContoh.item[1])
        modelDenganNavigasi.lanjut()
        #expect(navigasi.path == [Rute.detailContoh(DataContoh.item[1])])
    }
}
