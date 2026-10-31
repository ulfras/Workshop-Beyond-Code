/// Format nominal untuk layar: tanpa desimal, titik sebagai pemisah ribuan.
/// `Rupiah.format(240_000)` → "Rp240.000"
enum Rupiah {
    static func format(_ nilai: Int) -> String {
        (nilai < 0 ? "-" : "") + "Rp" + angka(nilai)
    }

    /// Angka saja dengan pemisah ribuan, tanpa "Rp" dan tanpa tanda minus. Dipakai di field nominal.
    /// `Rupiah.angka(7_500_000)` → "7.500.000"
    static func angka(_ nilai: Int) -> String {
        var digit = String(nilai.magnitude)
        var hasil = ""
        while digit.count > 3 {
            hasil = "." + String(digit.suffix(3)) + hasil
            digit.removeLast(3)
        }
        return digit + hasil
    }
}
