import Foundation
import Observation

/// Beranda: saldo dan pintu masuk ke Transfer (prototype 1-beranda).
@MainActor
@Observable
final class BerandaModel {
    var status: StatusMuat<Akun>
    var saldoTersembunyi = false
    /// Titik merah di lonceng.
    private(set) var belumDibaca = 0

    private let layanan: any LayananData
    private let navigasi: Navigasi?
    private let sekarang: () -> Date
    private var sudahDimuat: Bool

    init(layanan: any LayananData = LayananDummy(), navigasi: Navigasi? = nil, sekarang: @escaping () -> Date = { Date() }) {
        self.status = .memuat
        self.layanan = layanan
        self.navigasi = navigasi
        self.sekarang = sekarang
        self.sudahDimuat = false
    }

    /// Untuk preview dan test: state tetap, tidak memuat dari layanan.
    init(status: StatusMuat<Akun>, belumDibaca: Int = 0) {
        self.status = status
        self.belumDibaca = belumDibaca
        self.layanan = LayananDummy()
        self.navigasi = nil
        self.sekarang = { Date() }
        self.sudahDimuat = true
    }

    var sapaan: String {
        Sapaan.untuk(jam: Calendar.current.component(.hour, from: sekarang()))
    }

    /// Dipanggil setiap Beranda tampil. Pertama kali memuat dengan placeholder;
    /// sesudahnya (misalnya kembali dari Transfer Berhasil) saldo diperbarui tanpa placeholder.
    func muncul() async {
        if sudahDimuat {
            await segarkan()
        } else {
            sudahDimuat = true
            await muat()
        }
        await perbaruiLencana()
    }

    /// Jumlah notifikasi belum dibaca. Gagal memuat tidak mengubah tanda yang sudah tampil.
    func perbaruiLencana() async {
        if let daftar = try? await layanan.notifikasi() {
            belumDibaca = daftar.filter { !$0.dibaca }.count
        }
    }

    func muat() async {
        status = .memuat
        do {
            if let akun = try await layanan.akun() {
                status = .berhasil(akun)
            } else {
                status = .kosong
            }
        } catch {
            status = .gagal("Saldo belum bisa dimuat. Periksa koneksi, lalu coba lagi.")
        }
    }

    private func segarkan() async {
        guard case .berhasil = status else { return }
        // Gagal menyegarkan tidak menghapus saldo yang sudah tampil.
        if let akun = try? await layanan.akun() {
            status = .berhasil(akun)
        }
    }

    /// Transfer dimulai dari memilih rekening tujuan.
    func bukaTransfer() {
        navigasi?.buka(.pilihRekening)
    }

    func bukaRiwayat() {
        navigasi?.buka(.riwayat)
    }

    func bukaNotifikasi() {
        navigasi?.buka(.notifikasi)
    }

    func bukaTopUp() {
        navigasi?.buka(.topUp)
    }

    /// QRIS di luar scope (docs/tasks.md T9).
    func buka(_ fitur: String) {
        navigasi?.buka(.belumDibangun(fitur))
    }
}

extension BerandaModel {
    static var contoh: BerandaModel { .init(status: .berhasil(DataTransfer.akun), belumDibaca: 2) }
    static var memuat: BerandaModel { .init(status: .memuat) }
    static var kosong: BerandaModel { .init(status: .kosong) }
    static var gagal: BerandaModel { .init(status: .gagal("Saldo belum bisa dimuat. Periksa koneksi, lalu coba lagi.")) }
}
