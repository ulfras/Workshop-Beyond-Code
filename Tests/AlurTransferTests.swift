import CryptoKit
import Foundation
import Testing
@testable import Prototipe

/// Alur layar dari Transfer sampai Berhasil, dengan backend dummy tanpa jeda dan jam tetap.
@MainActor
struct AlurTransferTests {
    let navigasi = Navigasi()

    func layanan(jam: Date = AturanRisikoTests.jam(14), riwayat: [BuktiTransfer] = [],
                 kunciPublik: Data = KunciPerangkat.kunciPublik) -> LayananDummy {
        let bank = BankDummy(sekarang: { jam }, riwayat: riwayat, kunciPublik: kunciPublik,
                             aturan: AturanRisiko(kalender: AturanRisikoTests.kalender))
        return LayananDummy(jeda: .zero, ikutiDemoFlags: false, bank: bank)
    }

    /// Seperti app: saldo dari server, rekening dari daftar Pilih Rekening Tujuan.
    func modelTransfer(_ layanan: LayananDummy, tujuan: Rekening = DataTransfer.rekeningTujuan[0]) async -> TransferModel {
        let saldo = (try? await layanan.akun())?.saldo ?? 0
        return TransferModel(tujuan: tujuan, saldo: saldo, layanan: layanan, navigasi: navigasi)
    }

    func ketikPIN(_ pin: String, di model: PINModel) async {
        for karakter in pin {
            await model.ketik(Int(String(karakter))!)
        }
    }

    // MARK: Pilih Rekening Tujuan

    @Test("Pilih Rekening memuat saldo dan 3 rekening tujuan dummy")
    func muatRekening() async {
        let model = PilihRekeningModel(layanan: layanan(), navigasi: navigasi)
        await model.muncul()
        #expect(model.status == .berhasil(.init(saldo: 125_000_000, daftar: DataTransfer.rekeningTujuan)))
        #expect(DataTransfer.rekeningTujuan.map(\.nama) == ["Ayu Contoh", "Citra Contoh", "Dimas Contoh"])
        #expect(Set(DataTransfer.rekeningTujuan.map(\.nomor)).count == 3)
    }

    @Test("Memilih rekening membuka Transfer ke rekening itu dengan saldo yang dimuat", arguments: [0, 1, 2])
    func pilihRekening(indeks: Int) async {
        let model = PilihRekeningModel(layanan: layanan(), navigasi: navigasi)
        await model.muncul()
        let tujuan = DataTransfer.rekeningTujuan[indeks]
        model.pilih(tujuan)
        #expect(navigasi.path == [.transfer(tujuan, saldo: 125_000_000)])
    }

    @Test("Belum dimuat atau gagal: tidak ada rute ke Transfer")
    func pilihSebelumDimuat() {
        let model = PilihRekeningModel(status: .gagal(PilihRekeningModel.pesanGagal))
        #expect(model.rute(untuk: DataTransfer.rekeningTujuan[0]) == nil)
    }

    @Test("Daftar rekening kosong dari server: state kosong")
    func rekeningKosong() async {
        let bank = BankDummy(tujuan: [], riwayat: [])
        let model = PilihRekeningModel(layanan: LayananDummy(jeda: .zero, ikutiDemoFlags: false, bank: bank))
        await model.muncul()
        #expect(model.status == .kosong)
    }

    @Test("Transfer memakai rekening yang dipilih, bukan rekening pertama")
    func transferKeRekeningDipilih() async throws {
        let tujuan = DataTransfer.rekeningTujuan[2]
        let model = await modelTransfer(layanan(), tujuan: tujuan)
        model.pilihNominal(1_000_000)
        await model.lanjutkan()
        guard case .pin(let p, _) = try #require(navigasi.path.last) else { Issue.record("Seharusnya ke PIN"); return }
        #expect(p.tujuan == tujuan)
    }

    // MARK: Transfer

    @Test("Field nominal: titik ribuan langsung, digit ke-13 dan huruf ditolak tanpa mengubah nominal")
    func fieldNominal() async {
        let model = await modelTransfer(layanan())
        for ketikan in ["7", "75", "750", "7500", "7.5000", "75.0000"] {
            model.ubahNominal(ketikan)
        }
        #expect(model.ketikanNominal == "750.000")
        #expect(model.nominal == 750_000)

        model.ubahNominal("750.000x")
        #expect(model.ketikanNominal == "750.000")

        // Seperti TextField: binding sudah menulis teks mentah, onChange memberi teks sebelumnya.
        model.ketikanNominal = "750.000,5"
        model.ubahNominal(model.ketikanNominal, sebelumnya: "750.000")
        #expect(model.ketikanNominal == "750.000")

        model.ubahNominal("999999999999")
        #expect(model.ketikanNominal == "999.999.999.999")
        model.ubahNominal("9999999999999")
        #expect(model.ketikanNominal == "999.999.999.999")
    }

    @Test("Lanjutkan nonaktif: nominal kosong, nol, dan melebihi saldo")
    func lanjutkanNonaktif() async {
        let model = await modelTransfer(layanan())
        #expect(!model.bisaLanjut)
        model.ubahNominal("0")
        #expect(model.masalah == .nol)
        #expect(!model.bisaLanjut)
        model.ubahNominal("200000000")
        #expect(model.masalah == .melebihiSaldo(saldo: 125_000_000))
        #expect(!model.bisaLanjut)
        model.pilihNominal(1_000_000)
        #expect(model.ketikanNominal == "1.000.000")
        #expect(model.bisaLanjut)
    }

    @Test("Nominal normal: langsung ke PIN tanpa passkey, tanpa sheet")
    func normalKePIN() async throws {
        let model = await modelTransfer(layanan())
        model.pilihNominal(1_000_000)
        await model.lanjutkan()
        #expect(!model.peringatanTampil)
        guard case .pin(let p, let perluPasskey) = try #require(navigasi.path.last) else {
            Issue.record("Seharusnya ke PIN"); return
        }
        #expect(p.nominal == 1_000_000)
        #expect(!perluPasskey)
    }

    @Test("Nominal Rp75 juta: sheet peringatan, lalu Lanjutkan ke PIN dengan passkey")
    func tinggiSheetLaluPIN() async throws {
        let model = await modelTransfer(layanan())
        model.pilihNominal(75_000_000)
        await model.lanjutkan()
        #expect(model.peringatanTampil)
        #expect(model.alasanPeringatan == .nominalBesar(nominal: 75_000_000, batas: 50_000_000))
        #expect(navigasi.path.isEmpty)
        model.lanjutkanKePIN()
        model.sheetTertutup()
        guard case .pin(_, let perluPasskey) = try #require(navigasi.path.last) else {
            Issue.record("Seharusnya ke PIN"); return
        }
        #expect(perluPasskey)
    }

    @Test("Batalkan transfer di sheet: tetap di Transfer, isian utuh")
    func batalkanSheet() async {
        let model = await modelTransfer(layanan())
        model.pilihNominal(75_000_000)
        model.catatan = "bayar arisan"
        await model.lanjutkan()
        model.batalkan()
        model.sheetTertutup()
        #expect(navigasi.path.isEmpty)
        #expect(model.ketikanNominal == "75.000.000")
        #expect(model.catatan == "bayar arisan")
    }

    @Test("Jam malam, total 4 jam Rp35 juta: sheet dengan alasan total malam")
    func malamTotal() async {
        let jam = AturanRisikoTests.jam(23)
        let lama = BuktiTransfer(permintaan: PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: 20_000_000, catatan: ""),
                                 metode: .pin, waktu: jam.addingTimeInterval(-3600))
        let model = await modelTransfer(layanan(jam: jam, riwayat: [lama]))
        model.ubahNominal("15000000")
        await model.lanjutkan()
        #expect(model.alasanPeringatan == .totalMalam(total: 35_000_000, batas: 30_000_000))
    }

    // MARK: PIN

    @Test("Jalur normal: PIN 000000 → Berhasil dengan otorisasi PIN; layar PIN dibuang dari tumpukan")
    func jalurNormal() async throws {
        let layanan = layanan()
        let p = PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: 1_000_000, catatan: "")
        _ = try await layanan.cekRisiko(p)
        let model = PINModel(permintaan: p, perluPasskey: false, layanan: layanan, navigasi: navigasi)
        await ketikPIN("000000", di: model)
        guard case .berhasil(let bukti) = try #require(navigasi.path.last) else {
            Issue.record("Seharusnya Berhasil"); return
        }
        #expect(bukti.metode == .pin)
        #expect(navigasi.path.count == 1)
    }

    @Test("PIN salah: titik dikosongkan dan pesan sisa kesempatan; salah ketiga membatalkan transfer")
    func pinSalah() async throws {
        let layanan = layanan()
        let p = PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: 1_000_000, catatan: "")
        _ = try await layanan.cekRisiko(p)
        let model = PINModel(permintaan: p, perluPasskey: false, layanan: layanan, navigasi: navigasi)
        await ketikPIN("123456", di: model)
        #expect(model.jumlahDigit == 0)
        #expect(model.pesan == "PIN salah. Sisa 2 kesempatan.")
        await ketikPIN("123456", di: model)
        #expect(model.pesan == "PIN salah. Sisa 1 kesempatan.")
        await ketikPIN("123456", di: model)
        #expect(model.tahap == .dibatalkan(PINModel.pesanTerkunci))
        #expect(model.jumlahSalah == 3)
        await model.ketik(0)
        #expect(model.jumlahDigit == 0)
        #expect(navigasi.path.isEmpty)
    }

    @Test("Hapus digit dan batas 6 digit")
    func hapusDigit() async {
        let model = PINModel(permintaan: DataTransfer.permintaanNormal, perluPasskey: false,
                             layanan: layanan(), navigasi: navigasi)
        await model.ketik(1)
        await model.ketik(2)
        model.hapus()
        #expect(model.jumlahDigit == 1)
    }

    @Test("Risiko tinggi: PIN benar → Verifikasi, belum ada transfer")
    func pinLaluVerifikasi() async throws {
        let layanan = layanan()
        let p = PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: 75_000_000, catatan: "")
        _ = try await layanan.cekRisiko(p)
        let model = PINModel(permintaan: p, perluPasskey: true, layanan: layanan, navigasi: navigasi)
        await ketikPIN("000000", di: model)
        #expect(navigasi.path.last == .verifikasi(p))
        #expect(try await layanan.akun()?.saldo == 125_000_000)
    }

    @Test("Layar memanipulasi perluPasskey = false untuk transfer besar: server menolak, alur dipaksa ke Verifikasi")
    func tidakBisaMelewatiPasskey() async throws {
        let layanan = layanan()
        let p = PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: 75_000_000, catatan: "")
        _ = try await layanan.cekRisiko(p)
        let model = PINModel(permintaan: p, perluPasskey: false, layanan: layanan, navigasi: navigasi)
        await ketikPIN("000000", di: model)
        #expect(navigasi.path.last == .verifikasi(p))
        #expect(try await layanan.akun()?.saldo == 125_000_000)
    }

    // MARK: Verifikasi

    func siapVerifikasi(_ layanan: LayananDummy) async throws -> PermintaanTransfer {
        let p = PermintaanTransfer(tujuan: DataTransfer.rekeningTujuan[0], nominal: 75_000_000, catatan: "bayar arisan")
        _ = try await layanan.cekRisiko(p)
        #expect(try await layanan.periksaPIN("000000", untuk: p) == .benar)
        return p
    }

    @Test("Face ID lulus + tanda tangan perangkat: Berhasil dengan otorisasi Passkey + Biometrik")
    func jalurPasskey() async throws {
        let layanan = layanan()
        let p = try await siapVerifikasi(layanan)
        let model = VerifikasiModel(permintaan: p, layanan: layanan, biometrik: BiometrikDummy(), navigasi: navigasi)
        await model.verifikasi()
        guard case .berhasil(let bukti) = try #require(navigasi.path.last) else {
            Issue.record("Seharusnya Berhasil"); return
        }
        #expect(bukti.metode == .passkey)
        #expect(try await layanan.akun()?.saldo == 50_000_000)
    }

    @Test("Coba lagi setelah wajah tidak dikenali: Face ID dipanggil ulang, lalu transfer terkirim")
    func cobaLagiAutentikasiUlang() async throws {
        let layanan = layanan()
        let p = try await siapVerifikasi(layanan)
        let biometrik = BiometrikUrutan([.tidakCocok, nil])
        let model = VerifikasiModel(permintaan: p, layanan: layanan, biometrik: biometrik, navigasi: navigasi)
        await model.verifikasi()
        #expect(model.tahap == .ulang("Wajah tidak dikenali."))
        #expect(await biometrik.jumlahPanggilan == 1)
        #expect(navigasi.path.isEmpty)

        await model.verifikasi()
        #expect(await biometrik.jumlahPanggilan == 2)
        guard case .berhasil(let bukti) = try #require(navigasi.path.last) else {
            Issue.record("Seharusnya Berhasil"); return
        }
        #expect(bukti.metode == .passkey)
    }

    @Test("Coba lagi setelah prompt ditutup dan setelah gagal dua kali: tetap memanggil Face ID lagi")
    func cobaLagiBerulang() async throws {
        let layanan = layanan()
        let p = try await siapVerifikasi(layanan)
        let biometrik = BiometrikUrutan([.dibatalkan, .tidakCocok, .tidakCocok, nil])
        let model = VerifikasiModel(permintaan: p, layanan: layanan, biometrik: biometrik, navigasi: navigasi)
        for _ in 0..<3 {
            await model.verifikasi()
            guard case .ulang = model.tahap else { Issue.record("Seharusnya bisa diulang"); return }
        }
        await model.verifikasi()
        #expect(await biometrik.jumlahPanggilan == 4)
        guard case .berhasil = navigasi.path.last else { Issue.record("Seharusnya Berhasil"); return }
    }

    @Test("Wajah tidak dikenali dan prompt ditutup: tetap di layar, bisa diulang")
    func biometrikUlang() async throws {
        let layanan = layanan()
        let p = try await siapVerifikasi(layanan)
        let gagal = VerifikasiModel(permintaan: p, layanan: layanan, biometrik: BiometrikDummy(galat: .tidakCocok), navigasi: navigasi)
        await gagal.verifikasi()
        #expect(gagal.tahap == .ulang("Wajah tidak dikenali."))
        let batal = VerifikasiModel(permintaan: p, layanan: layanan, biometrik: BiometrikDummy(galat: .dibatalkan), navigasi: navigasi)
        await batal.verifikasi()
        #expect(batal.tahap == .ulang("Verifikasi dibatalkan. Transfer belum diproses."))
        #expect(navigasi.path.isEmpty)
    }

    @Test("Face ID tidak tersedia atau terkunci: transfer dihentikan, tanpa jalan pintas", arguments: [GalatBiometrik.tidakTersedia, .terkunci])
    func biometrikTidakBisa(galat: GalatBiometrik) async throws {
        let layanan = layanan()
        let p = try await siapVerifikasi(layanan)
        let model = VerifikasiModel(permintaan: p, layanan: layanan, biometrik: BiometrikDummy(galat: galat), navigasi: navigasi)
        await model.verifikasi()
        guard case .dibatalkan = model.tahap else { Issue.record("Seharusnya dibatalkan"); return }
        #expect(try await layanan.akun()?.saldo == 125_000_000)
    }

    @Test("Kunci perangkat tidak terdaftar di server: signature ditolak, transfer dibatalkan")
    func signatureDitolak() async throws {
        let layanan = layanan(kunciPublik: P256.Signing.PrivateKey().publicKey.rawRepresentation)
        let p = try await siapVerifikasi(layanan)
        let model = VerifikasiModel(permintaan: p, layanan: layanan, biometrik: BiometrikDummy(), navigasi: navigasi)
        await model.verifikasi()
        #expect(model.tahap == .dibatalkan(VerifikasiModel.pesanDitolak))
        #expect(navigasi.path.isEmpty)
        #expect(try await layanan.akun()?.saldo == 125_000_000)
    }

    @Test("Batalkan transfer di Verifikasi: kembali ke Beranda")
    func batalkanVerifikasi() {
        navigasi.path = [.pilihRekening, .transfer(DataTransfer.rekeningTujuan[0], saldo: 125_000_000),
                         .verifikasi(DataTransfer.permintaanBesar)]
        let model = VerifikasiModel(permintaan: DataTransfer.permintaanBesar, navigasi: navigasi)
        model.batalkan()
        #expect(navigasi.path.isEmpty)
    }

    // MARK: Beranda

    @Test("Beranda: memuat saldo dummy; Transfer membuka layar Transfer")
    func beranda() async {
        let model = BerandaModel(layanan: layanan(), navigasi: navigasi)
        await model.muncul()
        #expect(model.status == .berhasil(DataTransfer.akun))
        model.bukaTransfer()
        #expect(navigasi.path == [.pilihRekening])
    }
}

/// Biometrik pengganti untuk test: memberi hasil berurutan (`nil` = lulus) dan menghitung berapa kali dipanggil.
actor BiometrikUrutan: Biometrik {
    nonisolated let jenis: JenisBiometrik = .faceID
    private var hasil: [GalatBiometrik?]
    private(set) var jumlahPanggilan = 0

    init(_ hasil: [GalatBiometrik?]) {
        self.hasil = hasil
    }

    func verifikasi(alasan: String) async throws {
        jumlahPanggilan += 1
        let berikutnya = hasil.isEmpty ? nil : hasil.removeFirst()
        if let berikutnya { throw berikutnya }
    }
}
