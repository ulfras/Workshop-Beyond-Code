/// Masalah nominal di layar Transfer. `kosong` dan `nol` hanya menonaktifkan tombol, tanpa pesan.
enum MasalahNominal: Equatable, Sendable {
    case kosong
    case nol
    case melebihiSaldo(saldo: Int)
}

enum ValidasiTransfer {
    /// Batas digit ketikan, supaya nominal tidak pernah melebihi kapasitas `Int`.
    static let digitMaksimal = 12

    static func periksa(nominal: Int?, saldo: Int) -> MasalahNominal? {
        guard let nominal else { return .kosong }
        if nominal <= 0 { return .nol }
        if nominal > saldo { return .melebihiSaldo(saldo: saldo) }
        return nil
    }

    /// Teks field nominal setelah nasabah mengetik, menghapus atau menempel. Hasilnya selalu angka rupiah
    /// dengan titik ribuan ("7.500.000"), atau kosong.
    ///
    /// - Hanya digit 0–9 dan titik yang diterima. Huruf, koma, minus, spasi, emoji, "Rp", atau digit non-Latin
    ///   membuat seluruh perubahan ditolak: hasilnya `sebelumnya`, bukan dibuang diam-diam (tempel "1,5" tidak jadi 15).
    /// - Maksimal 12 digit (tanpa nol di depan). Digit ke-13, termasuk tempel angka panjang, ditolak, bukan dipotong.
    /// - Titik dari nasabah diabaikan dan dipasang ulang setiap tiga digit. Nol di depan dibuang; "0" tetap "0".
    static func rapikan(ketikan baru: String, sebelumnya lama: String) -> String {
        guard baru.allSatisfy({ $0 == "." || ("0"..."9").contains($0) }) else { return lama }
        let digit = baru.filter { $0 != "." }
        guard !digit.isEmpty else { return "" }
        let tanpaNolDepan = digit.drop { $0 == "0" }
        guard tanpaNolDepan.count <= digitMaksimal else { return lama }
        guard let nilai = Int(tanpaNolDepan.isEmpty ? "0" : String(tanpaNolDepan)) else { return lama }
        return Rupiah.angka(nilai)
    }

    /// Ketikan di field nominal ("7.500.000", "Rp7500000") menjadi angka. Selain digit diabaikan.
    static func nominal(dariKetikan teks: String) -> Int? {
        let digit = teks.filter { $0.isASCII && $0.isNumber }
        guard !digit.isEmpty else { return nil }
        return Int(digit.prefix(digitMaksimal))
    }
}
