import Foundation
import Observation

/// Layar 6 · Riwayat: transfer berhasil, dikelompokkan per hari.
@MainActor
@Observable
final class RiwayatModel {
    static let pesanGagal = "Riwayat belum bisa dimuat. Periksa koneksi, lalu coba lagi."

    var status: StatusMuat<[KelompokRiwayat]>

    private let layanan: any LayananData
    private let sekarang: () -> Date
    private var sudahDimuat: Bool

    init(layanan: any LayananData = LayananDummy(), sekarang: @escaping () -> Date = { Date() }) {
        self.status = .memuat
        self.layanan = layanan
        self.sekarang = sekarang
        self.sudahDimuat = false
    }

    /// Untuk preview: state tetap.
    init(status: StatusMuat<[KelompokRiwayat]>) {
        self.status = status
        self.layanan = LayananDummy()
        self.sekarang = { Date() }
        self.sudahDimuat = true
    }

    /// Pertama kali dengan placeholder; sesudahnya (kembali dari detail) diperbarui tanpa placeholder.
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
            let daftar = try await layanan.riwayatTransfer()
            status = daftar.isEmpty ? .kosong : .berhasil(RiwayatHarian.kelompokkan(daftar, sekarang: sekarang()))
        } catch {
            // Gagal menyegarkan tidak menghapus daftar yang sudah tampil.
            if case .berhasil = status, !tampilkanMemuat { return }
            status = .gagal(Self.pesanGagal)
        }
    }
}

extension RiwayatModel {
    static var contoh: RiwayatModel {
        let sekarang = Date()
        return .init(status: .berhasil(RiwayatHarian.kelompokkan(
            DataTransfer.riwayatAwal(sekarang: sekarang) + [DataTransfer.buktiPasskey], sekarang: sekarang)))
    }
    static var memuat: RiwayatModel { .init(status: .memuat) }
    static var kosong: RiwayatModel { .init(status: .kosong) }
    static var gagal: RiwayatModel { .init(status: .gagal(pesanGagal)) }
}
