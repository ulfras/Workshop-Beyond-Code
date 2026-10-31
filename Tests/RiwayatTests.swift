import CryptoKit
import Foundation
import Testing
@testable import Prototipe

/// Riwayat transfer yang dicatat server, pengelompokan per hari, dan layar Riwayat.
@MainActor
struct RiwayatTests {
    static let aturan = AturanRisiko(kalender: AturanRisikoTests.kalender)
    let navigasi = Navigasi()

    func bank(waktu: Date = AturanRisikoTests.jam(14), riwayat: [BuktiTransfer]? = [],
              kunciPublik: Data = KunciPerangkat.kunciPublik) -> BankDummy {
        BankDummy(sekarang: { waktu }, riwayat: riwayat, kunciPublik: kunciPublik, aturan: Self.aturan)
    }

    func permintaan(_ nominal: Int) -> PermintaanTransfer {
        PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: nominal, catatan: "")
    }

    func layanan(_ bank: BankDummy) -> LayananDummy {
        LayananDummy(jeda: .zero, ikutiDemoFlags: false, bank: bank)
    }

    // MARK: Server

    @Test("Data awal: 3 transfer lama, terbaru di atas")
    func dataAwal() async {
        let riwayat = await bank(riwayat: nil).daftarRiwayat()
        #expect(riwayat.map(\.permintaan.nominal) == [20_000_000, 250_000, 1_500_000])
    }

    @Test("Data awal ikut dihitung FDS: pukul 23.00, Rp15 juta setelah Rp20 juta sejam lalu → tinggi")
    func dataAwalUntukFDS() async {
        let bank = bank(waktu: AturanRisikoTests.jam(23), riwayat: nil)
        #expect(await bank.cekRisiko(permintaan(15_000_000)) == .tinggi(.totalMalam(total: 35_000_000, batas: 30_000_000)))
    }

    @Test("Transfer berhasil masuk riwayat paling atas")
    func berhasilDicatat() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let bukti = try await bank.kirim(p, tandaTangan: nil)
        #expect(await bank.daftarRiwayat().first == bukti)
    }

    @Test("Kirim ulang transfer yang sama tidak menggandakan riwayat")
    func kirimUlangTidakGanda() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        _ = try await bank.kirim(p, tandaTangan: nil)
        _ = try await bank.kirim(p, tandaTangan: nil)
        #expect(await bank.daftarRiwayat().count == 1)
    }

    @Test("PIN salah 3 kali: transfer tidak masuk riwayat")
    func pinTerkunci() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        for _ in 0..<4 { _ = try await bank.periksaPIN("111111", untuk: p.id) }
        #expect(await bank.daftarRiwayat().isEmpty)
    }

    @Test("Signature ditolak: transfer tidak masuk riwayat")
    func signatureDitolak() async throws {
        let bank = bank(kunciPublik: P256.Signing.PrivateKey().publicKey.rawRepresentation)
        let p = permintaan(75_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let tantangan = try await bank.mintaTantangan(untuk: p.id)
        let tanda = try PenandatanganPerangkat().tandatangani(p.muatanTandaTangan(tantangan: tantangan))
        await #expect(throws: GalatTransfer.tandaTanganDitolak) {
            try await bank.kirim(p, tandaTangan: TandaTanganTransaksi(tantangan: tantangan, tanda: tanda))
        }
        #expect(await bank.daftarRiwayat().isEmpty)
    }

    // MARK: Pengelompokan

    @Test("Riwayat per hari: Hari ini, Kemarin, lalu tanggal; terbaru di atas")
    func kelompokHari() {
        let k = AturanRisikoTests.kalender
        func b(_ waktu: Date) -> BuktiTransfer { BuktiTransfer(permintaan: permintaan(1), metode: .pin, waktu: waktu) }
        let pagi = b(AturanRisikoTests.jam(9))
        let siang = b(AturanRisikoTests.jam(13))
        let kemarin = b(AturanRisikoTests.jam(20, hari: 29))
        let lama = b(AturanRisikoTests.jam(10, hari: 27))
        let hasil = RiwayatHarian.kelompokkan([lama, pagi, kemarin, siang], sekarang: AturanRisikoTests.jam(14), kalender: k)
        #expect(hasil.count == 3)
        #expect(hasil[0].judul == "Hari ini")
        #expect(hasil[0].transaksi == [siang, pagi])
        #expect(hasil[1].judul == "Kemarin")
        #expect(hasil[1].transaksi == [kemarin])
        #expect(hasil[2].judul != "Hari ini" && hasil[2].judul != "Kemarin")
        #expect(hasil[2].transaksi == [lama])
        #expect(RiwayatHarian.kelompokkan([], sekarang: AturanRisikoTests.jam(14), kalender: k).isEmpty)
    }

    // MARK: Layar

    @Test("Riwayat kosong lalu terisi setelah transfer")
    func layarRiwayat() async throws {
        let layanan = layanan(bank())
        let model = RiwayatModel(layanan: layanan, sekarang: { AturanRisikoTests.jam(14) })
        await model.muncul()
        #expect(model.status == .kosong)
        let p = permintaan(1_000_000)
        _ = try await layanan.cekRisiko(p)
        _ = try await layanan.periksaPIN("000000", untuk: p)
        let bukti = try await layanan.kirimTransfer(p, tandaTangan: nil)
        await model.muncul()
        #expect(model.status == .berhasil([KelompokRiwayat(judul: "Hari ini", transaksi: [bukti])]))
    }

    @Test("Riwayat di Beranda membuka layar Riwayat")
    func bukaRiwayat() {
        let beranda = BerandaModel(layanan: layanan(bank()), navigasi: navigasi)
        beranda.bukaRiwayat()
        #expect(navigasi.path == [.riwayat])
    }
}
