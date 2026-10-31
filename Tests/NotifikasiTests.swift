import CryptoKit
import Foundation
import Testing
@testable import Prototipe

/// Notifikasi keamanan transaksi yang dibuat server, dan layar Notifikasi serta titik di lonceng Beranda.
@MainActor
struct NotifikasiTests {
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

    @Test("Data awal: 3 notifikasi, hanya yang terbaru belum dibaca, dan terhubung ke transfernya")
    func dataAwal() async {
        let bank = bank(riwayat: nil)
        let notifikasi = await bank.daftarNotifikasi()
        #expect(notifikasi.count == 3)
        #expect(notifikasi.filter { !$0.dibaca }.count == 1)
        #expect(notifikasi.first?.bukti == (await bank.daftarRiwayat()).first)
    }

    @Test("Transfer berhasil: notifikasi 'Transfer berhasil' yang bisa dibuka ke transfernya")
    func berhasilDicatat() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let bukti = try await bank.kirim(p, tandaTangan: nil)
        let notifikasi = try #require(await bank.daftarNotifikasi().first)
        #expect(notifikasi.jenis == .berhasil)
        #expect(notifikasi.pesan == "Rp1.000.000 ke Ayu Contoh. Diotorisasi dengan PIN.")
        #expect(notifikasi.bukti == bukti)
        #expect(!notifikasi.dibaca)
    }

    @Test("Kirim ulang transfer yang sama tidak menggandakan notifikasi")
    func kirimUlangTidakGanda() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        _ = try await bank.kirim(p, tandaTangan: nil)
        _ = try await bank.kirim(p, tandaTangan: nil)
        #expect(await bank.daftarNotifikasi().count == 1)
    }

    @Test("Risiko tinggi: satu notifikasi peringatan per transfer, walaupun cek risiko diulang")
    func peringatanSekali() async {
        let bank = bank()
        let p = permintaan(75_000_000)
        _ = await bank.cekRisiko(p)
        _ = await bank.cekRisiko(p)
        let notifikasi = await bank.daftarNotifikasi()
        #expect(notifikasi.count == 1)
        #expect(notifikasi.first?.jenis == .peringatan)
        #expect(notifikasi.first?.judul == "Transaksi tidak biasa terdeteksi")
        #expect(notifikasi.first?.bukti == nil)
    }

    @Test("Transfer normal tidak membuat notifikasi peringatan")
    func normalTanpaPeringatan() async {
        let bank = bank()
        _ = await bank.cekRisiko(permintaan(1_000_000))
        #expect(await bank.daftarNotifikasi().isEmpty)
    }

    @Test("PIN salah 3 kali: satu notifikasi 'Transfer dibatalkan', tidak bertambah saat dicoba lagi")
    func pinTerkunci() async throws {
        let bank = bank()
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        for _ in 0..<4 { _ = try await bank.periksaPIN("111111", untuk: p.id) }
        let notifikasi = await bank.daftarNotifikasi()
        #expect(notifikasi.count == 1)
        #expect(notifikasi.first?.jenis == .dibatalkan)
        #expect(notifikasi.first?.pesan == "PIN salah 3 kali. Transfer Rp1.000.000 ke Ayu Contoh dibatalkan demi keamanan.")
    }

    @Test("Signature ditolak: notifikasi 'Verifikasi transaksi gagal' di atas peringatan risikonya")
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
        #expect(await bank.daftarNotifikasi().map(\.judul) == ["Verifikasi transaksi gagal", "Transaksi tidak biasa terdeteksi"])
    }

    @Test("Tandai dibaca: semua notifikasi jadi dibaca")
    func tandaiDibaca() async {
        let bank = bank(riwayat: nil)
        await bank.tandaiSemuaDibaca()
        #expect(await bank.daftarNotifikasi().allSatisfy(\.dibaca))
    }

    // MARK: Layar

    @Test("Membuka Notifikasi menandai dibaca; titik di lonceng Beranda hilang")
    func layarNotifikasi() async {
        let layanan = layanan(bank(riwayat: nil))
        let beranda = BerandaModel(layanan: layanan, navigasi: navigasi)
        await beranda.muncul()
        #expect(beranda.belumDibaca == 1)

        beranda.bukaNotifikasi()
        #expect(navigasi.path == [.notifikasi])
        let model = NotifikasiModel(layanan: layanan)
        await model.muncul()
        guard case .berhasil(let daftar) = model.status else { Issue.record("Seharusnya berhasil"); return }
        // Tanda "belum dibaca" tetap tampil di layar yang sedang dibuka.
        #expect(daftar.filter { !$0.dibaca }.count == 1)

        await beranda.muncul()
        #expect(beranda.belumDibaca == 0)
    }

    @Test("Notifikasi kosong")
    func notifikasiKosong() async {
        let model = NotifikasiModel(layanan: layanan(bank()))
        await model.muncul()
        #expect(model.status == .kosong)
    }
}
