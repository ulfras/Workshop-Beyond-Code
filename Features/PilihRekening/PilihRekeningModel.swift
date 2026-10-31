import Foundation
import Observation

/// Layar 1a · Pilih Rekening Tujuan: langkah pertama transfer (userflow #1). Memuat saldo dan daftar rekening tujuan,
/// lalu membawa keduanya ke layar Transfer lewat rute.
@MainActor
@Observable
final class PilihRekeningModel {
    struct DataLayar: Equatable {
        let saldo: Int
        let daftar: [Rekening]
    }

    static let pesanGagal = "Rekening tujuan belum bisa dimuat. Periksa koneksi, lalu coba lagi."

    var status: StatusMuat<DataLayar>

    private let layanan: any LayananData
    private let navigasi: Navigasi?
    private var sudahDimuat: Bool

    init(layanan: any LayananData = LayananDummy(), navigasi: Navigasi? = nil) {
        self.status = .memuat
        self.layanan = layanan
        self.navigasi = navigasi
        self.sudahDimuat = false
    }

    /// Untuk preview: state tetap.
    init(status: StatusMuat<DataLayar>) {
        self.status = status
        self.layanan = LayananDummy()
        self.navigasi = nil
        self.sudahDimuat = true
    }

    /// Pertama kali dengan placeholder; sesudahnya (kembali dari Transfer) saldo dan daftar diperbarui tanpa placeholder.
    func muncul() async {
        if sudahDimuat {
            await muat(tampilkanMemuat: false)
        } else {
            sudahDimuat = true
            await muat()
        }
    }

    func muat(tampilkanMemuat: Bool = true) async {
        if tampilkanMemuat { status = .memuat }
        do {
            let akun = try await layanan.akun()
            let daftar = try await layanan.rekeningTujuan()
            if let akun, !daftar.isEmpty {
                status = .berhasil(DataLayar(saldo: akun.saldo, daftar: daftar))
            } else {
                status = .kosong
            }
        } catch {
            // Gagal menyegarkan tidak menghapus daftar yang sudah tampil.
            if case .berhasil = status, !tampilkanMemuat { return }
            status = .gagal(Self.pesanGagal)
        }
    }

    /// Rute ke layar Transfer untuk rekening ini, membawa saldo yang baru dimuat.
    func rute(untuk rekening: Rekening) -> Rute? {
        guard case .berhasil(let data) = status else { return nil }
        return .transfer(rekening, saldo: data.saldo)
    }

    func pilih(_ rekening: Rekening) {
        guard let rute = rute(untuk: rekening) else { return }
        navigasi?.buka(rute)
    }
}

extension PilihRekeningModel {
    static var contoh: PilihRekeningModel {
        .init(status: .berhasil(DataLayar(saldo: DataTransfer.akun.saldo, daftar: DataTransfer.rekeningTujuan)))
    }
    static var memuat: PilihRekeningModel { .init(status: .memuat) }
    static var kosong: PilihRekeningModel { .init(status: .kosong) }
    static var gagal: PilihRekeningModel { .init(status: .gagal(pesanGagal)) }
}
