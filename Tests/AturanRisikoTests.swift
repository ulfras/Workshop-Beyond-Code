import Foundation
import Testing
@testable import Prototipe

/// Contoh di tabel keputusan FDS (docs/DECISIONS.md, 30 Okt 2026). Riwayat: Rp20 juta satu jam sebelumnya.
struct AturanRisikoTests {
    static let kalender: Calendar = {
        var k = Calendar(identifier: .gregorian)
        k.timeZone = TimeZone(identifier: "Asia/Jakarta")!
        return k
    }()
    let aturan = AturanRisiko(kalender: Self.kalender)

    static func jam(_ jam: Int, _ menit: Int = 0, hari: Int = 30) -> Date {
        kalender.date(from: DateComponents(year: 2026, month: 10, day: hari, hour: jam, minute: menit))!
    }

    func riwayat20JutaSejamSebelum(_ waktu: Date) -> [TransaksiTercatat] {
        [TransaksiTercatat(nominal: 20_000_000, waktu: waktu.addingTimeInterval(-3600))]
    }

    @Test("Siang, Rp75 juta: tinggi karena nominal")
    func siangNominalBesar() {
        let waktu = Self.jam(14)
        #expect(aturan.nilai(nominal: 75_000_000, waktu: waktu, riwayat: riwayat20JutaSejamSebelum(waktu))
                == .tinggi(.nominalBesar(nominal: 75_000_000, batas: 50_000_000)))
    }

    @Test("Siang, Rp10 juta: normal walaupun total 4 jam Rp30 juta lebih")
    func siangNormal() {
        let waktu = Self.jam(14)
        let riwayat = [TransaksiTercatat(nominal: 40_000_000, waktu: waktu.addingTimeInterval(-600))]
        #expect(aturan.nilai(nominal: 10_000_000, waktu: waktu, riwayat: riwayat) == .normal)
    }

    @Test("Batas nominal: tepat Rp50 juta normal, Rp50 juta + 1 tinggi")
    func batasNominal() {
        let waktu = Self.jam(14)
        #expect(aturan.nilai(nominal: 50_000_000, waktu: waktu, riwayat: []) == .normal)
        #expect(aturan.nilai(nominal: 50_000_001, waktu: waktu, riwayat: [])
                == .tinggi(.nominalBesar(nominal: 50_000_001, batas: 50_000_000)))
    }

    @Test("23.00, Rp10 juta + Rp20 juta: total tepat Rp30 juta masih normal")
    func malamTepatBatas() {
        let waktu = Self.jam(23)
        #expect(aturan.nilai(nominal: 10_000_000, waktu: waktu, riwayat: riwayat20JutaSejamSebelum(waktu)) == .normal)
    }

    @Test("Jam malam dengan total Rp35 juta: tinggi", arguments: [(23, 0), (5, 59), (22, 0), (0, 30)])
    func malamTinggi(jam: Int, menit: Int) {
        let waktu = Self.jam(jam, menit)
        #expect(aturan.nilai(nominal: 15_000_000, waktu: waktu, riwayat: riwayat20JutaSejamSebelum(waktu))
                == .tinggi(.totalMalam(total: 35_000_000, batas: 30_000_000)))
    }

    @Test("Di luar jam malam dengan total Rp35 juta: normal", arguments: [(6, 0), (21, 59), (12, 0)])
    func bukanMalam(jam: Int, menit: Int) {
        let waktu = Self.jam(jam, menit)
        #expect(aturan.nilai(nominal: 15_000_000, waktu: waktu, riwayat: riwayat20JutaSejamSebelum(waktu)) == .normal)
    }

    @Test("Transfer sebelum pukul 22.00 ikut dihitung: Rp20 juta pukul 21.30 + Rp15 juta pukul 23.00")
    func jendelaMelewatiJam22() {
        let riwayat = [TransaksiTercatat(nominal: 20_000_000, waktu: Self.jam(21, 30))]
        #expect(aturan.nilai(nominal: 15_000_000, waktu: Self.jam(23), riwayat: riwayat)
                == .tinggi(.totalMalam(total: 35_000_000, batas: 30_000_000)))
    }

    @Test("Transfer tepat 4 jam lalu atau lebih lama tidak dihitung")
    func jendelaEmpatJam() {
        let waktu = Self.jam(23)
        let riwayat = [
            TransaksiTercatat(nominal: 20_000_000, waktu: waktu.addingTimeInterval(-4 * 3600)),
            TransaksiTercatat(nominal: 20_000_000, waktu: waktu.addingTimeInterval(-5 * 3600))
        ]
        #expect(aturan.totalDalamJendela(sampai: waktu, riwayat: riwayat) == 0)
        #expect(aturan.nilai(nominal: 15_000_000, waktu: waktu, riwayat: riwayat) == .normal)
    }

    @Test("Satu transfer malam di atas Rp30 juta tanpa riwayat: tinggi karena total malam")
    func malamTanpaRiwayat() {
        #expect(aturan.nilai(nominal: 45_000_000, waktu: Self.jam(23), riwayat: [])
                == .tinggi(.totalMalam(total: 45_000_000, batas: 30_000_000)))
    }

    @Test("Kedua aturan terpenuhi: alasan nominal yang dipakai")
    func keduanya() {
        let waktu = Self.jam(23)
        #expect(aturan.nilai(nominal: 75_000_000, waktu: waktu, riwayat: riwayat20JutaSejamSebelum(waktu))
                == .tinggi(.nominalBesar(nominal: 75_000_000, batas: 50_000_000)))
    }
}

struct ValidasiTransferTests {
    @Test("Nominal kosong, nol, melebihi saldo, dan pas saldo")
    func periksa() {
        #expect(ValidasiTransfer.periksa(nominal: nil, saldo: 100) == .kosong)
        #expect(ValidasiTransfer.periksa(nominal: 0, saldo: 100) == .nol)
        #expect(ValidasiTransfer.periksa(nominal: 101, saldo: 100) == .melebihiSaldo(saldo: 100))
        #expect(ValidasiTransfer.periksa(nominal: 100, saldo: 100) == nil)
    }

    @Test("Ketikan menjadi angka; selain digit diabaikan; maksimal 12 digit",
          arguments: [("7.500.000", 7_500_000), ("Rp1000", 1000), ("000", 0), ("1234567890123", 123_456_789_012)])
    func ketikan(teks: String, nominal: Int) {
        #expect(ValidasiTransfer.nominal(dariKetikan: teks) == nominal)
    }

    @Test("Ketikan tanpa digit: kosong")
    func ketikanKosong() {
        #expect(ValidasiTransfer.nominal(dariKetikan: "") == nil)
        #expect(ValidasiTransfer.nominal(dariKetikan: "Rp.") == nil)
    }

    // MARK: Field nominal: rapikan(ketikan:sebelumnya:)

    @Test("Titik ribuan langsung ikut setiap digit yang diketik",
          arguments: [("", "1", "1"), ("1", "10", "10"), ("10", "100", "100"), ("100", "1000", "1.000"),
                      ("1.000", "1.0000", "10.000"), ("10.000", "10.0000", "100.000"),
                      ("100.000", "100.0000", "1.000.000"), ("1.000.000", "1.000.0005", "10.000.005")])
    func ketikBertahap(lama: String, baru: String, hasil: String) {
        #expect(ValidasiTransfer.rapikan(ketikan: baru, sebelumnya: lama) == hasil)
    }

    @Test("Menghapus digit: titik ribuan ikut bergeser; hapus semua jadi kosong",
          arguments: [("1.000", "1.00", "100"), ("10.000", "10.00", "1.000"), ("1", "", ""),
                      ("1.000.000", "1000.000", "1.000.000")])
    func hapus(lama: String, baru: String, hasil: String) {
        #expect(ValidasiTransfer.rapikan(ketikan: baru, sebelumnya: lama) == hasil)
    }

    @Test("Maksimal 12 digit: digit ke-13 ditolak, angka tetap seperti sebelumnya")
    func maksimal12Digit() {
        let dua_belas = "999.999.999.999"
        #expect(ValidasiTransfer.rapikan(ketikan: "99999999999", sebelumnya: "9.999.999.999") == "99.999.999.999")
        #expect(ValidasiTransfer.rapikan(ketikan: "99.999.999.9999", sebelumnya: "99.999.999.999") == dua_belas)
        #expect(ValidasiTransfer.rapikan(ketikan: dua_belas + "9", sebelumnya: dua_belas) == dua_belas)
        // Tempel 13 digit sekaligus juga ditolak, bukan dipotong.
        #expect(ValidasiTransfer.rapikan(ketikan: "1234567890123", sebelumnya: "5.000") == "5.000")
    }

    @Test("Selain angka rupiah ditolak, angka tetap seperti sebelumnya",
          arguments: ["1.000a", "1.000-", "-1.000", "1.000,5", "1,5", "1 000", "Rp1.000", "1.000🙂", "١٢٣", "１２３", "1e5", "+1000"])
    func selainRupiahDitolak(baru: String) {
        #expect(ValidasiTransfer.rapikan(ketikan: baru, sebelumnya: "1.000") == "1.000")
    }

    @Test("Nol di depan dibuang; nol saja tetap 0; titik saja jadi kosong",
          arguments: [("05", "5"), ("0", "0"), ("000", "0"), ("0.001", "1"), (".", ""), ("...", "")])
    func nolDanTitik(baru: String, hasil: String) {
        #expect(ValidasiTransfer.rapikan(ketikan: baru, sebelumnya: "") == hasil)
    }

    @Test("Hasil rapikan selalu stabil: dirapikan lagi tidak berubah")
    func stabil() {
        for teks in ["1.000", "999.999.999.999", "0", ""] {
            #expect(ValidasiTransfer.rapikan(ketikan: teks, sebelumnya: teks) == teks)
        }
    }

    @Test("Rupiah.angka tanpa Rp", arguments: [(7_500_000, "7.500.000"), (0, "0"), (999, "999")])
    func angka(nilai: Int, teks: String) {
        #expect(Rupiah.angka(nilai) == teks)
    }
}

struct SapaanDemoTests {
    @Test("Sapaan menurut jam", arguments: [(4, "Selamat pagi,"), (10, "Selamat pagi,"), (11, "Selamat siang,"),
                                            (14, "Selamat siang,"), (15, "Selamat sore,"), (18, "Selamat malam,"), (2, "Selamat malam,")])
    func sapaan(jam: Int, teks: String) {
        #expect(Sapaan.untuk(jam: jam) == teks)
    }

    @Test("-demoJam diurai HH:mm; nilai tidak valid diabaikan")
    func uraiJam() {
        let jam = DemoFlags.uraiJam("23:00")
        #expect(jam?.jam == 23 && jam?.menit == 0)
        #expect(DemoFlags.uraiJam("24:00") == nil)
        #expect(DemoFlags.uraiJam("23") == nil)
        #expect(DemoFlags.uraiJam("ab:cd") == nil)
    }
}
