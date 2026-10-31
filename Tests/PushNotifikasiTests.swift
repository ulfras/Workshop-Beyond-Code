import AVFoundation
import CryptoKit
import Foundation
import os
import Testing
import UserNotifications
@testable import Prototipe

/// Push "Transfer berhasil" dari server dummy: kapan dikirim, isinya, dan jingle BRImo di bundle app.
@MainActor
struct PushNotifikasiTests {
    let kunci = P256.Signing.PrivateKey()

    func bank(saldo: Int = 125_000_000, push: PencatatPush) -> BankDummy {
        BankDummy(sekarang: { AturanRisikoTests.jam(14) },
                  akun: Akun(namaPanggilan: "Budi", jenisTabungan: "BritAma", nomorRekening: "0", saldo: saldo),
                  riwayat: [], kunciPublik: kunci.publicKey.rawRepresentation,
                  aturan: AturanRisiko(kalender: AturanRisikoTests.kalender), push: push)
    }

    func permintaan(_ nominal: Int) -> PermintaanTransfer {
        PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[1], nominal: nominal, catatan: "bayar kos")
    }

    // MARK: Kapan dikirim

    @Test("Transfer normal berhasil: tepat satu push; kirim ulang id yang sama tidak menambah push")
    func normalSekali() async throws {
        let push = PencatatPush()
        let bank = bank(push: push)
        let p = permintaan(1_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let bukti = try await bank.kirim(p, tandaTangan: nil)
        _ = try await bank.kirim(p, tandaTangan: nil)
        #expect(push.terkirim == [bukti])
    }

    @Test("Transfer risiko tinggi berhasil dengan passkey: satu push, metode passkey")
    func passkeySekali() async throws {
        let push = PencatatPush()
        let bank = bank(push: push)
        let p = permintaan(75_000_000)
        _ = await bank.cekRisiko(p)
        _ = try await bank.periksaPIN("000000", untuk: p.id)
        let tantangan = try await bank.mintaTantangan(untuk: p.id)
        let tanda = try kunci.signature(for: p.muatanTandaTangan(tantangan: tantangan)).derRepresentation
        _ = try await bank.kirim(p, tandaTangan: TandaTanganTransaksi(tantangan: tantangan, tanda: tanda))
        #expect(push.terkirim.map(\.metode) == [.passkey])
    }

    @Test("Transfer tidak berhasil: tanpa push (PIN terkunci, butuh passkey, signature ditolak, saldo kurang)")
    func gagalTanpaPush() async throws {
        let push = PencatatPush()
        let bank = bank(saldo: 2_000_000, push: push)

        let terkunci = permintaan(1_000_000)
        _ = await bank.cekRisiko(terkunci)
        for _ in 0..<3 { _ = try await bank.periksaPIN("111111", untuk: terkunci.id) }
        await #expect(throws: GalatTransfer.pinBelumDiverifikasi) { try await bank.kirim(terkunci, tandaTangan: nil) }

        let besar = permintaan(75_000_000)
        _ = await bank.cekRisiko(besar)
        _ = try await bank.periksaPIN("000000", untuk: besar.id)
        await #expect(throws: GalatTransfer.butuhVerifikasiTambahan) { try await bank.kirim(besar, tandaTangan: nil) }
        let tantangan = try await bank.mintaTantangan(untuk: besar.id)
        let palsu = try P256.Signing.PrivateKey().signature(for: besar.muatanTandaTangan(tantangan: tantangan)).derRepresentation
        await #expect(throws: GalatTransfer.tandaTanganDitolak) {
            try await bank.kirim(besar, tandaTangan: TandaTanganTransaksi(tantangan: tantangan, tanda: palsu))
        }

        let kurang = permintaan(5_000_000)
        _ = await bank.cekRisiko(kurang)
        _ = try await bank.periksaPIN("000000", untuk: kurang.id)
        await #expect(throws: GalatTransfer.saldoTidakCukup) { try await bank.kirim(kurang, tandaTangan: nil) }

        #expect(push.terkirim.isEmpty)
    }

    @Test("Top up tidak mengirim push transfer")
    func topUpTanpaPush() async throws {
        let push = PencatatPush()
        _ = try await bank(push: push).topUp(PermintaanTopUp(nominal: 500_000))
        #expect(push.terkirim.isEmpty)
    }

    @Test("Alur layar: PIN 000000 di jalur normal → Berhasil dan satu push")
    func alurLayar() async throws {
        let push = PencatatPush()
        let layanan = LayananDummy(jeda: .zero, ikutiDemoFlags: false, bank: bank(push: push))
        let navigasi = Navigasi()
        let p = permintaan(1_000_000)
        _ = try await layanan.cekRisiko(p)
        let model = PINModel(permintaan: p, perluPasskey: false, layanan: layanan, navigasi: navigasi)
        for _ in 0..<6 { await model.ketik(0) }
        guard case .berhasil(let bukti) = navigasi.path.last else { Issue.record("Seharusnya Berhasil"); return }
        #expect(push.terkirim == [bukti])
    }

    // MARK: Isi

    @Test("Isi push: judul, nominal, penerima, metode, jingle BRImo, id = id transfer")
    func isi() {
        let bukti = BuktiTransfer(permintaan: permintaan(7_500_000), metode: .passkey, waktu: AturanRisikoTests.jam(14))
        let req = PushNotifikasi.permintaan(untuk: bukti)
        #expect(req.identifier == bukti.permintaan.id.uuidString)
        #expect(req.trigger == nil)
        #expect(req.content.title == "Transfer Berhasil")
        #expect(req.content.body == "Rp7.500.000 ke Citra Contoh. Diotorisasi dengan Passkey + Biometrik.")
        #expect(req.content.sound != nil)
        #expect(req.content.sound != .default)
        #expect(req.content.threadIdentifier == PushNotifikasi.kategoriTransfer)
        #expect(req.content.userInfo["idTransfer"] as? String == bukti.permintaan.id.uuidString)
    }

    @Test("Jingle bisa dimuat sebagai system sound untuk diputar app saat transfer berhasil")
    func jingleBisaDiputar() {
        #expect(JingleBRImo.tersedia)
    }

    @Test("Banner saat app dibuka tanpa bunyi notifikasi, supaya jingle dari app tidak dobel")
    func bannerTanpaBunyiGanda() {
        #expect(PenanganNotifikasi.opsiSaatDibuka.contains(.banner))
        #expect(!PenanganNotifikasi.opsiSaatDibuka.contains(.sound))
    }

    @Test("Jingle BRImo ada di bundle app, format CAF, di bawah batas 30 detik iOS")
    func jingleDiBundle() async throws {
        let nama = PushNotifikasi.namaSuara
        let url = try #require(Bundle.main.url(forResource: (nama as NSString).deletingPathExtension,
                                               withExtension: (nama as NSString).pathExtension))
        #expect(url.deletingLastPathComponent().standardizedFileURL == Bundle.main.bundleURL.standardizedFileURL,
                "Bunyi notifikasi harus di akar bundle supaya UNNotificationSound(named:) menemukannya")
        let durasi = try await AVURLAsset(url: url).load(.duration)
        #expect(durasi.seconds > 1 && durasi.seconds <= 30)
    }
}

/// Pengganti push untuk test: mencatat setiap bukti yang dikirim server.
final class PencatatPush: PengirimPush {
    private let isi = OSAllocatedUnfairLock(initialState: [BuktiTransfer]())

    var terkirim: [BuktiTransfer] { isi.withLock { $0 } }

    func transferBerhasil(_ bukti: BuktiTransfer) {
        isi.withLock { $0.append(bukti) }
    }
}
