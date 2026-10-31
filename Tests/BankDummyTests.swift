import CryptoKit
import Foundation
import Testing
@testable import Prototipe

/// Aturan keamanan di backend dummy. Ini yang menjamin layar tidak bisa melewati PIN atau passkey.
struct BankDummyTests {
    static let siang: Date = AturanRisikoTests.jam(14)
    static let aturan = AturanRisiko(kalender: AturanRisikoTests.kalender)
    let kunci = P256.Signing.PrivateKey()

    func bank(saldo: Int = 125_000_000, waktu: Date = Self.siang) -> BankDummy {
        BankDummy(sekarang: { waktu },
                  akun: Akun(namaPanggilan: "Budi", jenisTabungan: "BritAma", nomorRekening: "0", saldo: saldo),
                  riwayat: [], kunciPublik: kunci.publicKey.rawRepresentation, aturan: Self.aturan)
    }

    func permintaan(_ nominal: Int, catatan: String = "") -> PermintaanTransfer {
        PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: nominal, catatan: catatan)
    }

    func tandaTangan(_ p: PermintaanTransfer, tantangan: Data, kunci: P256.Signing.PrivateKey? = nil) throws -> TandaTanganTransaksi {
        let tanda = try (kunci ?? self.kunci).signature(for: p.muatanTandaTangan(tantangan: tantangan)).derRepresentation
        return TandaTanganTransaksi(tantangan: tantangan, tanda: tanda)
    }

    @Test("PIN salah: sisa 2, lalu 1, lalu terkunci; PIN benar setelah terkunci tetap ditolak")
    func pinSalah() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        #expect(try await bank.periksaPIN("111111", untuk: p.id) == .salah(sisaKesempatan: 2))
        #expect(try await bank.periksaPIN("111111", untuk: p.id) == .salah(sisaKesempatan: 1))
        #expect(try await bank.periksaPIN("111111", untuk: p.id) == .terkunci)
        #expect(try await bank.periksaPIN("000000", untuk: p.id) == .terkunci)
        await #expect(throws: GalatTransfer.pinBelumDiverifikasi) { try await bank.kirim(p, tandaTangan: nil) }
    }

    @Test("Hitungan PIN salah milik satu transfer: transfer baru mulai dari 3 kesempatan")
    func pinPerTransfer() async throws {
        let bank = bank()
        let pertama = permintaan(1_000_000)
        _ = await bank.cekRisiko(pertama)
        _ = try await bank.periksaPIN("111111", untuk: pertama.id)
        let kedua = permintaan(1_000_000)
        _ = await bank.cekRisiko(kedua)
        #expect(try await bank.periksaPIN("111111", untuk: kedua.id) == .salah(sisaKesempatan: 2))
    }

    @Test("PIN untuk transfer yang tidak didaftarkan lewat cek risiko: ditolak")
    func pinTanpaDaftar() async {
        await #expect(throws: GalatTransfer.permintaanTidakDikenal) {
            try await bank().periksaPIN("000000", untuk: UUID())
        }
    }

    @Test("Transfer normal dengan PIN benar: berhasil, metode PIN, saldo terpotong")
    func normalDenganPIN() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        #expect(await bank.cekRisiko(p) == .normal)
        #expect(try await bank.periksaPIN("000000", untuk: p.id) == .benar)
        let bukti = try await bank.kirim(p, tandaTangan: nil)
        #expect(bukti.metode == .pin)
        #expect(bukti.waktu == Self.siang)
        #expect(await bank.akunSaatIni()?.saldo == 124_000_000)
    }

    @Test("Kirim tanpa PIN: ditolak")
    func tanpaPIN() async {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        await #expect(throws: GalatTransfer.pinBelumDiverifikasi) { try await bank.kirim(p, tandaTangan: nil) }
    }

    @Test("Risiko tinggi dengan PIN saja: ditolak, butuh verifikasi tambahan")
    func tinggiTanpaPasskey() async throws {
        let bank = bank()
        let p = permintaan(75_000_000)
        #expect(await bank.cekRisiko(p) == .tinggi(.nominalBesar(nominal: 75_000_000, batas: 50_000_000)))
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        await #expect(throws: GalatTransfer.butuhVerifikasiTambahan) { try await bank.kirim(p, tandaTangan: nil) }
        #expect(await bank.akunSaatIni()?.saldo == 125_000_000)
    }

    @Test("Risiko tinggi dengan PIN + tanda tangan passkey yang benar: berhasil, metode passkey")
    func tinggiDenganPasskey() async throws {
        let bank = bank()
        let p = permintaan(75_000_000, catatan: "bayar arisan")
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let tantangan = try await bank.mintaTantangan(untuk: p.id)
        let bukti = try await bank.kirim(p, tandaTangan: try tandaTangan(p, tantangan: tantangan))
        #expect(bukti.metode == .passkey)
        #expect(await bank.akunSaatIni()?.saldo == 50_000_000)
    }

    @Test("Tantangan passkey hanya setelah PIN benar")
    func tantanganButuhPIN() async {
        let bank = bank()
        let p = permintaan(75_000_000)
        _ = await bank.cekRisiko(p)
        await #expect(throws: GalatTransfer.pinBelumDiverifikasi) { try await bank.mintaTantangan(untuk: p.id) }
    }

    @Test("Tanda tangan dari kunci lain: ditolak")
    func kunciLain() async throws {
        let bank = bank()
        let p = permintaan(75_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let tantangan = try await bank.mintaTantangan(untuk: p.id)
        let palsu = try tandaTangan(p, tantangan: tantangan, kunci: P256.Signing.PrivateKey())
        await #expect(throws: GalatTransfer.tandaTanganDitolak) { try await bank.kirim(p, tandaTangan: palsu) }
        #expect(await bank.akunSaatIni()?.saldo == 125_000_000)
    }

    @Test("Isi transfer diubah setelah didaftarkan (nominal atau tujuan): ditolak")
    func isiDiubah() async throws {
        let bank = bank()
        let asli = permintaan(1_000_000)
        _ = await bank.cekRisiko(asli)
        _ = try await bank.periksaPIN("000000", untuk: asli.id)
        let diubah = PermintaanTransfer(id: asli.id, tujuan: asli.tujuan, nominal: 75_000_000, catatan: "")
        await #expect(throws: GalatTransfer.permintaanTidakDikenal) { try await bank.kirim(diubah, tandaTangan: nil) }
    }

    @Test("Tanda tangan untuk muatan lain (nominal berbeda): ditolak")
    func muatanLain() async throws {
        let bank = bank()
        let p = permintaan(75_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let tantangan = try await bank.mintaTantangan(untuk: p.id)
        let lain = PermintaanTransfer(id: p.id, tujuan: p.tujuan, nominal: 1_000, catatan: "")
        let tanda = try tandaTangan(lain, tantangan: tantangan)
        await #expect(throws: GalatTransfer.tandaTanganDitolak) { try await bank.kirim(p, tandaTangan: tanda) }
    }

    @Test("Tantangan sekali pakai: tanda tangan lama tidak bisa dipakai lagi")
    func tantanganSekaliPakai() async throws {
        let bank = bank()
        let p = permintaan(75_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let lama = try await bank.mintaTantangan(untuk: p.id)
        _ = try await bank.mintaTantangan(untuk: p.id)
        await #expect(throws: GalatTransfer.tandaTanganDitolak) {
            try await bank.kirim(p, tandaTangan: try tandaTangan(p, tantangan: lama))
        }
    }

    @Test("Kirim ulang transfer yang sama: bukti sama, saldo terpotong sekali")
    func kirimUlang() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let pertama = try await bank.kirim(p, tandaTangan: nil)
        let kedua = try await bank.kirim(p, tandaTangan: nil)
        #expect(pertama == kedua)
        #expect(await bank.akunSaatIni()?.saldo == 124_000_000)
    }

    @Test("Saldo tidak cukup: ditolak, saldo tetap")
    func saldoKurang() async throws {
        let bank = bank(saldo: 500_000)
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        await #expect(throws: GalatTransfer.saldoTidakCukup) { try await bank.kirim(p, tandaTangan: nil) }
        #expect(await bank.akunSaatIni()?.saldo == 500_000)
    }

    @Test("Transfer berhasil masuk riwayat: malam, Rp20 juta lalu Rp15 juta → transfer kedua butuh passkey")
    func riwayatDihitung() async throws {
        let bank = bank(waktu: AturanRisikoTests.jam(23))
        let pertama = permintaan(20_000_000)
        #expect(await bank.cekRisiko(pertama) == .normal)
        _ = try await bank.periksaPIN("000000", untuk: pertama.id)
        _ = try await bank.kirim(pertama, tandaTangan: nil)
        let kedua = permintaan(15_000_000)
        #expect(await bank.cekRisiko(kedua) == .tinggi(.totalMalam(total: 35_000_000, batas: 30_000_000)))
    }

    @Test("Penandatangan perangkat cocok dengan public key terdaftar")
    func kunciPerangkat() throws {
        let muatan = Data("uji".utf8)
        let tanda = try PenandatanganPerangkat().tandatangani(muatan)
        #expect(PemeriksaTandaTangan.valid(tanda: tanda, muatan: muatan, kunciPublik: KunciPerangkat.kunciPublik))
        #expect(!PemeriksaTandaTangan.valid(tanda: tanda, muatan: Data("lain".utf8), kunciPublik: KunciPerangkat.kunciPublik))
        #expect(!PemeriksaTandaTangan.valid(tanda: Data([1, 2, 3]), muatan: muatan, kunciPublik: KunciPerangkat.kunciPublik))
    }

    @Test("Muatan tanda tangan: catatan tidak bisa menyamar sebagai field lain")
    func muatanTegas() {
        let id = UUID()
        let tujuan = DataTransfer.rekeningTujuan[0]
        let a = PermintaanTransfer(id: id, tujuan: tujuan, nominal: 1, catatan: "x\n2")
        let b = PermintaanTransfer(id: id, tujuan: tujuan, nominal: 1, catatan: "x")
        #expect(a.muatanTandaTangan(tantangan: Data([2])) != b.muatanTandaTangan(tantangan: Data([2])))
    }
}
