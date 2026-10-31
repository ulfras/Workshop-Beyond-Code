import Foundation

/// Top up saldo. Prototipe: saldo dummy bertambah langsung di server dummy, tanpa sumber dana asli.
/// Keputusan dan batasnya: docs/DECISIONS.md, 31 Okt 2026.

/// Satu top up yang diajukan. `id` baru setiap nominal berubah; "Coba lagi" setelah gagal memakai `id` yang sama,
/// jadi saldo tidak bertambah dua kali kalau jawaban server hilang di jalan.
struct PermintaanTopUp: Identifiable, Hashable, Sendable {
    let id: UUID
    let nominal: Int

    init(id: UUID = UUID(), nominal: Int) {
        self.id = id
        self.nominal = nominal
    }
}

/// Bukti top up dari server. `waktu` adalah jam server.
struct BuktiTopUp: Hashable, Sendable {
    let permintaan: PermintaanTopUp
    let saldoBaru: Int
    let waktu: Date
}

/// Masalah nominal top up. `kosong` hanya menonaktifkan tombol, tanpa pesan.
enum MasalahTopUp: Equatable, Sendable {
    case kosong
    case kurangDariMinimal(minimal: Int)
    case melebihiMaksimal(maksimal: Int)
}

enum AturanTopUp {
    static let minimal = 10_000
    static let maksimal = 100_000_000
    static let pilihanNominal = [100_000, 500_000, 1_000_000]

    /// Dipakai layar (tombol, pesan) dan server dummy (penolakan). Batas minimal dan maksimal ikut dihitung.
    static func periksa(nominal: Int?) -> MasalahTopUp? {
        guard let nominal, nominal > 0 else { return .kosong }
        if nominal < minimal { return .kurangDariMinimal(minimal: minimal) }
        if nominal > maksimal { return .melebihiMaksimal(maksimal: maksimal) }
        return nil
    }
}
