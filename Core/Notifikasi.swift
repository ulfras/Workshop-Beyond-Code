import Foundation

/// Notifikasi keamanan transaksi dari server: peringatan risiko, transfer berhasil, transfer dibatalkan.
/// Teksnya dibuat server (`BankDummy`), seperti push notification bank.
struct Notifikasi: Identifiable, Hashable, Sendable {
    enum Jenis: Hashable, Sendable {
        case berhasil
        case peringatan
        case dibatalkan
    }

    let id: UUID
    let jenis: Jenis
    let judul: String
    let pesan: String
    let waktu: Date
    var dibaca: Bool
    /// Transfer berhasil yang terkait. Kalau ada, notifikasi bisa dibuka ke detail transaksi.
    let bukti: BuktiTransfer?

    init(id: UUID = UUID(), jenis: Jenis, judul: String, pesan: String, waktu: Date,
         dibaca: Bool = false, bukti: BuktiTransfer? = nil) {
        self.id = id
        self.jenis = jenis
        self.judul = judul
        self.pesan = pesan
        self.waktu = waktu
        self.dibaca = dibaca
        self.bukti = bukti
    }
}
