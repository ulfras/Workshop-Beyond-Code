import Observation

/// Langkah-langkah di docs/userflow.md. Data yang dibutuhkan layar berikutnya dibawa di sini.
/// PIN tidak pernah ikut di rute.
enum Rute: Hashable {
    /// Layar contoh starter (Features/Contoh). Tidak dipakai di alur BRImo.
    case detailContoh(ItemContoh)
    case pilihRekening
    /// Saldo dibawa dari Pilih Rekening untuk validasi di layar; server tetap memeriksa saldo saat kirim.
    case transfer(Rekening, saldo: Int)
    case pin(PermintaanTransfer, perluPasskey: Bool)
    case verifikasi(PermintaanTransfer)
    case berhasil(BuktiTransfer)
    case riwayat
    case notifikasi
    case detailTransaksi(BuktiTransfer)
    case topUp
    case belumDibangun(String)
}

@MainActor
@Observable
final class Navigasi {
    var path: [Rute] = []

    func buka(_ rute: Rute) {
        path.append(rute)
    }

    /// Transfer selesai: layar PIN dan Verifikasi dibuang dari tumpukan, jadi tidak bisa dibuka lagi lewat kembali.
    func selesai(_ bukti: BuktiTransfer) {
        path = [.berhasil(bukti)]
    }

    func kembaliKeAwal() {
        path.removeAll()
    }
}
