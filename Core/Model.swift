import Foundation

/// Model contoh untuk layar `Features/Contoh`. Ganti atau hapus setelah model kalian ada.
/// Nominal selalu `Int` rupiah, tidak pernah `Double`.
/// `Codable` supaya `LayananSupabase` bisa membaca baris tabel `item_contoh` (nama kolom = nama properti).
struct ItemContoh: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let judul: String
    let keterangan: String
    let nominal: Int
    let ikon: String
}
