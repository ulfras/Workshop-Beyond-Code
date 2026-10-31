import Observation

/// Pola rujukan untuk setiap layar: model `@Observable`, `StatusMuat`, `LayananData`, navigasi.
/// Salin polanya untuk layar pertama kalian, lalu hapus folder Contoh kalau sudah tidak dipakai.
@MainActor
@Observable
final class ContohModel {
    var status: StatusMuat<[ItemContoh]>
    var terpilih: ItemContoh?

    private let layanan: any LayananData
    private let navigasi: Navigasi?
    private var sudahDimuat: Bool

    /// Default `LayananDummy`, supaya preview dan test tidak pernah memanggil jaringan.
    /// App meneruskan `SumberData.layanan()` dari `PrototipeApp`.
    init(layanan: any LayananData = LayananDummy(), navigasi: Navigasi? = nil) {
        self.status = .memuat
        self.layanan = layanan
        self.navigasi = navigasi
        self.sudahDimuat = false
    }

    /// Untuk preview dan test: state tetap, tidak memuat dari layanan.
    init(status: StatusMuat<[ItemContoh]>, terpilih: ItemContoh? = nil) {
        self.status = status
        self.terpilih = terpilih
        self.layanan = LayananDummy()
        self.navigasi = nil
        self.sudahDimuat = true
    }

    var bisaLanjut: Bool { terpilih != nil }

    func muatPertamaKali() async {
        guard !sudahDimuat else { return }
        sudahDimuat = true
        await muat()
    }

    func muat() async {
        status = .memuat
        do {
            let daftar = try await layanan.daftarContoh()
            status = daftar.isEmpty ? .kosong : .berhasil(daftar)
        } catch {
            status = .gagal("Data belum bisa dimuat. Periksa koneksi, lalu coba lagi.")
        }
    }

    func pilih(_ item: ItemContoh) {
        terpilih = item
    }

    func lanjut() {
        guard let terpilih else { return }
        navigasi?.buka(.detailContoh(terpilih))
    }
}

extension ContohModel {
    static var contoh: ContohModel { .init(status: .berhasil(DataContoh.item), terpilih: DataContoh.item[0]) }
    static var memuat: ContohModel { .init(status: .memuat) }
    static var kosong: ContohModel { .init(status: .kosong) }
    static var gagal: ContohModel { .init(status: .gagal("Data belum bisa dimuat. Periksa koneksi, lalu coba lagi.")) }
}
