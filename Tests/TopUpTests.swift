import Foundation
import Testing
@testable import Prototipe

/// Top up saldo: aturan nominal, server dummy, layar Top Up, dan saldo di Beranda dan Transfer sesudahnya.
@MainActor
struct TopUpTests {
    let navigasi = Navigasi()

    func bank(saldo: Int = 125_000_000, akunAda: Bool = true) -> BankDummy {
        BankDummy(sekarang: { AturanRisikoTests.jam(14) },
                  akun: akunAda ? Akun(namaPanggilan: "Budi", jenisTabungan: "BritAma", nomorRekening: "0", saldo: saldo) : nil,
                  riwayat: [])
    }

    func layanan(_ bank: BankDummy) -> LayananDummy {
        LayananDummy(jeda: .zero, ikutiDemoFlags: false, bank: bank)
    }

    // MARK: Aturan

    @Test("Batas nominal: kosong, di bawah Rp10.000, di atas Rp100.000.000",
          arguments: [(nil, MasalahTopUp?.some(.kosong)), (0, .kosong),
                      (9_999, .kurangDariMinimal(minimal: 10_000)), (10_000, nil), (500_000, nil),
                      (100_000_000, nil), (100_000_001, .melebihiMaksimal(maksimal: 100_000_000))])
    func aturan(nominal: Int?, masalah: MasalahTopUp?) {
        #expect(AturanTopUp.periksa(nominal: nominal) == masalah)
    }

    // MARK: Server

    @Test("Top up menambah saldo dan mengembalikan saldo baru")
    func tambahSaldo() async throws {
        let bank = bank()
        let bukti = try await bank.topUp(PermintaanTopUp(nominal: 500_000))
        #expect(bukti.saldoBaru == 125_500_000)
        #expect(bukti.waktu == AturanRisikoTests.jam(14))
        #expect(await bank.akunSaatIni()?.saldo == 125_500_000)
    }

    @Test("Mengulang id yang sama tidak menambah saldo dua kali; id sama dengan nominal lain ditolak")
    func idempoten() async throws {
        let bank = bank()
        let p = PermintaanTopUp(nominal: 500_000)
        let pertama = try await bank.topUp(p)
        let kedua = try await bank.topUp(p)
        #expect(pertama == kedua)
        #expect(await bank.akunSaatIni()?.saldo == 125_500_000)
        await #expect(throws: GalatTopUp.permintaanBerbeda) {
            try await bank.topUp(PermintaanTopUp(id: p.id, nominal: 1_000_000))
        }
        #expect(await bank.akunSaatIni()?.saldo == 125_500_000)
    }

    @Test("Server menolak nominal di luar batas walaupun layar dilewati", arguments: [5_000, 0, 100_000_001])
    func serverMenolak(nominal: Int) async {
        let bank = bank()
        await #expect(throws: GalatTopUp.nominalTidakValid) { try await bank.topUp(PermintaanTopUp(nominal: nominal)) }
        #expect(await bank.akunSaatIni()?.saldo == 125_000_000)
    }

    @Test("Tanpa rekening: ditolak")
    func tanpaRekening() async {
        await #expect(throws: GalatTopUp.tanpaRekening) {
            try await bank(akunAda: false).topUp(PermintaanTopUp(nominal: 500_000))
        }
    }

    @Test("Top up tidak masuk riwayat transfer dan tidak ikut dihitung FDS")
    func bukanTransfer() async throws {
        let bank = bank()
        _ = try await bank.topUp(PermintaanTopUp(nominal: 50_000_000))
        #expect(await bank.daftarRiwayat().isEmpty)
        let malam = BankDummy(sekarang: { AturanRisikoTests.jam(23) }, riwayat: [])
        _ = try await malam.topUp(PermintaanTopUp(nominal: 50_000_000))
        let p = PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: 10_000_000, catatan: "")
        #expect(await malam.cekRisiko(p) == .normal)
    }

    // MARK: Layar

    @Test("Field top up memakai aturan yang sama dengan Transfer")
    func field() {
        let model = TopUpModel(layanan: layanan(bank()))
        model.ubahNominal("500000")
        #expect(model.ketikanNominal == "500.000")
        model.ubahNominal("500.000a")
        #expect(model.ketikanNominal == "500.000")
        model.ubahNominal("9999999999999")
        #expect(model.ketikanNominal == "500.000")
    }

    @Test("Tombol Top Up nonaktif: kosong, di bawah minimal, di atas maksimal")
    func tombol() {
        let model = TopUpModel(layanan: layanan(bank()))
        #expect(!model.bisaTopUp)
        model.ubahNominal("5000")
        #expect(model.masalah == .kurangDariMinimal(minimal: 10_000))
        #expect(!model.bisaTopUp)
        model.ubahNominal("200000000")
        #expect(model.masalah == .melebihiMaksimal(maksimal: 100_000_000))
        #expect(!model.bisaTopUp)
        model.pilihNominal(100_000)
        #expect(model.bisaTopUp)
    }

    @Test("Beranda → Top Up Rp500.000 → selesai → Beranda dan Transfer menampilkan saldo baru")
    func alurPenuh() async throws {
        let layanan = layanan(bank())
        let beranda = BerandaModel(layanan: layanan, navigasi: navigasi)
        await beranda.muncul()
        beranda.bukaTopUp()
        #expect(navigasi.path == [.topUp])

        let model = TopUpModel(layanan: layanan, navigasi: navigasi)
        model.pilihNominal(500_000)
        await model.topUp()
        guard case .selesai(let bukti) = model.tahap else { Issue.record("Seharusnya selesai"); return }
        #expect(bukti.saldoBaru == 125_500_000)

        model.kembaliKeBeranda()
        #expect(navigasi.path.isEmpty)
        await beranda.muncul()
        #expect(beranda.status == .berhasil(Akun(namaPanggilan: "Budi", jenisTabungan: "BritAma",
                                                 nomorRekening: "0", saldo: 125_500_000)))
        let pilih = PilihRekeningModel(layanan: layanan, navigasi: navigasi)
        await pilih.muncul()
        guard case .berhasil(let data) = pilih.status else { Issue.record("Seharusnya berhasil"); return }
        #expect(data.saldo == 125_500_000)
    }

    @Test("Jawaban server hilang lalu Coba lagi: saldo bertambah sekali saja")
    func cobaLagiSekali() async throws {
        let bank = bank()
        let layanan = LayananJawabanHilang(dasar: layanan(bank))
        let model = TopUpModel(layanan: layanan)
        model.pilihNominal(500_000)
        await model.topUp()
        #expect(model.tahap == .gagal(TopUpModel.pesanKoneksi))
        #expect(model.bisaTopUp)
        await model.topUp()
        guard case .selesai(let bukti) = model.tahap else { Issue.record("Seharusnya selesai"); return }
        #expect(bukti.saldoBaru == 125_500_000)
        #expect(await bank.akunSaatIni()?.saldo == 125_500_000)
    }

    @Test("Nominal diubah setelah gagal: top up baru, bukan mengulang yang lama")
    func ubahSetelahGagal() async throws {
        let bank = bank()
        let model = TopUpModel(layanan: LayananJawabanHilang(dasar: layanan(bank)))
        model.pilihNominal(500_000)
        await model.topUp()
        model.pilihNominal(100_000)
        #expect(model.tahap == .mengisi)
        await model.topUp()
        // Rp500.000 sudah masuk sebelum jawabannya hilang, lalu Rp100.000 sebagai top up baru.
        #expect(await bank.akunSaatIni()?.saldo == 125_600_000)
    }

    @Test("Tanpa rekening dari server: pesan, saldo tetap")
    func layarTanpaRekening() async {
        let model = TopUpModel(layanan: layanan(bank(akunAda: false)))
        model.pilihNominal(500_000)
        await model.topUp()
        #expect(model.tahap == .gagal(TopUpModel.pesanTanpaRekening))
    }
}

/// Meneruskan ke `LayananDummy`, tetapi top up pertama dijalankan server lalu jawabannya "hilang" (koneksi putus).
private actor PenghitungTopUp {
    var sudahHilang = false
    func hilangkanSekali() -> Bool {
        defer { sudahHilang = true }
        return !sudahHilang
    }
}

private struct LayananJawabanHilang: LayananData {
    let dasar: LayananDummy
    private let penghitung = PenghitungTopUp()

    init(dasar: LayananDummy) {
        self.dasar = dasar
    }

    func topUp(_ permintaan: PermintaanTopUp) async throws -> BuktiTopUp {
        let bukti = try await dasar.topUp(permintaan)
        if await penghitung.hilangkanSekali() { throw GalatLayanan.koneksiTerputus }
        return bukti
    }

    func daftarContoh() async throws -> [ItemContoh] { try await dasar.daftarContoh() }
    func akun() async throws -> Akun? { try await dasar.akun() }
    func rekeningTujuan() async throws -> [Rekening] { try await dasar.rekeningTujuan() }
    func cekRisiko(_ permintaan: PermintaanTransfer) async throws -> HasilRisiko { try await dasar.cekRisiko(permintaan) }
    func periksaPIN(_ pin: String, untuk permintaan: PermintaanTransfer) async throws -> HasilPIN {
        try await dasar.periksaPIN(pin, untuk: permintaan)
    }
    func mintaTantangan(untuk permintaan: PermintaanTransfer) async throws -> Data { try await dasar.mintaTantangan(untuk: permintaan) }
    func kirimTransfer(_ permintaan: PermintaanTransfer, tandaTangan: TandaTanganTransaksi?) async throws -> BuktiTransfer {
        try await dasar.kirimTransfer(permintaan, tandaTangan: tandaTangan)
    }
    func riwayatTransfer() async throws -> [BuktiTransfer] { try await dasar.riwayatTransfer() }
    func notifikasi() async throws -> [Notifikasi] { try await dasar.notifikasi() }
    func tandaiNotifikasiDibaca() async throws { try await dasar.tandaiNotifikasiDibaca() }
}
