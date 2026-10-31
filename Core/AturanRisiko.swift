import Foundation

/// Transfer berhasil yang sudah tercatat di server. Dipakai untuk menghitung total 4 jam.
struct TransaksiTercatat: Hashable, Sendable {
    let nominal: Int
    let waktu: Date
}

enum AlasanRisiko: Hashable, Sendable {
    /// Aturan 1: nominal transfer ini lebih dari batas.
    case nominalBesar(nominal: Int, batas: Int)
    /// Aturan 2: jam malam, dan total transfer 4 jam terakhir (termasuk transfer ini) lebih dari batas.
    case totalMalam(total: Int, batas: Int)
}

enum HasilRisiko: Hashable, Sendable {
    case normal
    case tinggi(AlasanRisiko)
}

/// Fraud Detection Rule (FDS). Keputusan dan contohnya: docs/DECISIONS.md, 30 Okt 2026.
///
/// - Aturan 1: nominal > Rp50.000.000, kapan pun. Tepat Rp50.000.000 masih normal.
/// - Aturan 2: transfer pukul 22.00–05.59, dan total transfer berhasil dalam 4 jam terakhir
///   ditambah transfer ini > Rp30.000.000. Pukul 06.00 sudah bukan jam malam.
/// - Kalau keduanya terpenuhi, alasan nominal yang dipakai.
struct AturanRisiko: Sendable {
    var batasNominal = 50_000_000
    var batasTotalMalam = 30_000_000
    var jendela: TimeInterval = 4 * 60 * 60
    var jamMalamMulai = 22
    var jamMalamSelesai = 6
    var kalender = Calendar.current

    func nilai(nominal: Int, waktu: Date, riwayat: [TransaksiTercatat]) -> HasilRisiko {
        if nominal > batasNominal {
            return .tinggi(.nominalBesar(nominal: nominal, batas: batasNominal))
        }
        if jamMalam(waktu) {
            let total = totalDalamJendela(sampai: waktu, riwayat: riwayat) + nominal
            if total > batasTotalMalam {
                return .tinggi(.totalMalam(total: total, batas: batasTotalMalam))
            }
        }
        return .normal
    }

    func jamMalam(_ waktu: Date) -> Bool {
        let jam = kalender.component(.hour, from: waktu)
        return jam >= jamMalamMulai || jam < jamMalamSelesai
    }

    /// Transfer dengan waktu di (waktu − 4 jam, waktu]. Tepat 4 jam sebelumnya tidak dihitung.
    func totalDalamJendela(sampai waktu: Date, riwayat: [TransaksiTercatat]) -> Int {
        let awal = waktu.addingTimeInterval(-jendela)
        return riwayat
            .filter { $0.waktu > awal && $0.waktu <= waktu }
            .reduce(0) { $0 + $1.nominal }
    }
}
