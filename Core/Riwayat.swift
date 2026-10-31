import Foundation

/// Satu hari di layar Riwayat: "Hari ini", "Kemarin", atau tanggal.
struct KelompokRiwayat: Identifiable, Hashable, Sendable {
    var id: String { judul }
    let judul: String
    /// Terbaru di atas.
    let transaksi: [BuktiTransfer]
}

enum RiwayatHarian {
    /// Mengelompokkan transfer per hari, hari terbaru di atas, transfer terbaru di atas.
    static func kelompokkan(_ daftar: [BuktiTransfer], sekarang: Date, kalender: Calendar = .current) -> [KelompokRiwayat] {
        let urut = daftar.sorted { $0.waktu > $1.waktu }
        var hasil: [KelompokRiwayat] = []
        var hari: Date?
        var isi: [BuktiTransfer] = []
        for bukti in urut {
            let awal = kalender.startOfDay(for: bukti.waktu)
            if let hari, hari != awal {
                hasil.append(KelompokRiwayat(judul: judul(hari: hari, sekarang: sekarang, kalender: kalender), transaksi: isi))
                isi = []
            }
            hari = awal
            isi.append(bukti)
        }
        if let hari, !isi.isEmpty {
            hasil.append(KelompokRiwayat(judul: judul(hari: hari, sekarang: sekarang, kalender: kalender), transaksi: isi))
        }
        return hasil
    }

    static func judul(hari: Date, sekarang: Date, kalender: Calendar = .current) -> String {
        if kalender.isDate(hari, inSameDayAs: sekarang) { return "Hari ini" }
        if let kemarin = kalender.date(byAdding: .day, value: -1, to: sekarang),
           kalender.isDate(hari, inSameDayAs: kemarin) { return "Kemarin" }
        return FormatWaktu.tanggal(hari, kalender: kalender)
    }
}

/// Format waktu di layar, Bahasa Indonesia: "30 Okt 2026, 14.05", "14.05", "28 Okt 2026".
enum FormatWaktu {
    static let lokal = Locale(identifier: "id_ID")

    static func lengkap(_ waktu: Date) -> String {
        waktu.formatted(.dateTime.day().month(.abbreviated).year().hour().minute().locale(lokal))
    }

    static func jam(_ waktu: Date) -> String {
        waktu.formatted(.dateTime.hour().minute().locale(lokal))
    }

    static func tanggal(_ waktu: Date, kalender: Calendar = .current) -> String {
        var gaya = Date.FormatStyle.dateTime.day().month(.abbreviated).year().locale(lokal)
        gaya.calendar = kalender
        gaya.timeZone = kalender.timeZone
        return waktu.formatted(gaya)
    }
}
