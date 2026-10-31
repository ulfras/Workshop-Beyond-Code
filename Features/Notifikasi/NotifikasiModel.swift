import Foundation
import Observation

/// Layar 7 · Notifikasi keamanan transaksi. Membuka layar ini menandai semua notifikasi sudah dibaca;
/// tanda "belum dibaca" tetap tampil sampai layar dimuat ulang, supaya nasabah tahu mana yang baru.
@MainActor
@Observable
final class NotifikasiModel {
    static let pesanGagal = "Notifikasi belum bisa dimuat. Periksa koneksi, lalu coba lagi."

    var status: StatusMuat<[Notifikasi]>

    private let layanan: any LayananData
    private var sudahDimuat: Bool

    init(layanan: any LayananData = LayananDummy()) {
        self.status = .memuat
        self.layanan = layanan
        self.sudahDimuat = false
    }

    /// Untuk preview: state tetap.
    init(status: StatusMuat<[Notifikasi]>) {
        self.status = status
        self.layanan = LayananDummy()
        self.sudahDimuat = true
    }

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
        let daftar: [Notifikasi]
        do {
            daftar = try await layanan.notifikasi()
        } catch {
            if case .berhasil = status, !tampilkanMemuat { return }
            status = .gagal(Self.pesanGagal)
            return
        }
        status = daftar.isEmpty ? .kosong : .berhasil(daftar)
        if daftar.contains(where: { !$0.dibaca }) {
            try? await layanan.tandaiNotifikasiDibaca()
        }
    }
}

extension NotifikasiModel {
    static var contoh: NotifikasiModel { .init(status: .berhasil(DataTransfer.notifikasiContoh())) }
    static var memuat: NotifikasiModel { .init(status: .memuat) }
    static var kosong: NotifikasiModel { .init(status: .kosong) }
    static var gagal: NotifikasiModel { .init(status: .gagal(pesanGagal)) }
}
