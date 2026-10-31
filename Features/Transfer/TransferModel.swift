import Foundation
import Observation

/// Layar 2 · Transfer, termasuk cek FDS saat Lanjutkan dan sheet peringatan (userflow #1 dan #2).
@MainActor
@Observable
final class TransferModel {
    struct DataLayar: Equatable {
        let saldo: Int
        let tujuan: Rekening
    }

    enum Pemeriksaan: Equatable {
        case siap
        case memeriksa
        case gagal(String)
    }

    static let pilihanNominal = [1_000_000, 10_000_000, 75_000_000]
    static let pesanFDSGagal = "Pemeriksaan keamanan belum bisa dilakukan. Transfer belum diproses. Periksa koneksi, lalu coba lagi."

    /// Rekening tujuan dan saldo dibawa dari Pilih Rekening Tujuan; layar ini tidak memuat apa pun.
    let data: DataLayar
    /// Teks di field nominal, selalu berformat ribuan ("7.500.000"). Settable karena TextField menulis
    /// ketikan mentah ke sini; `ubahNominal(_:sebelumnya:)` langsung merapikannya lewat `onChange` di view.
    var ketikanNominal = ""
    var catatan = ""
    private(set) var pemeriksaan: Pemeriksaan = .siap
    /// Sheet "Transaksi Tidak Biasa Terdeteksi".
    var peringatanTampil = false
    private(set) var alasanPeringatan: AlasanRisiko?

    let batasKewajaran = AturanRisiko().batasNominal

    private let layanan: any LayananData
    private let navigasi: Navigasi?
    private var permintaanAktif: PermintaanTransfer?
    private var lanjutSetelahSheet = false

    init(tujuan: Rekening, saldo: Int, layanan: any LayananData = LayananDummy(), navigasi: Navigasi? = nil) {
        self.data = DataLayar(saldo: saldo, tujuan: tujuan)
        self.layanan = layanan
        self.navigasi = navigasi
    }

    /// Untuk preview: state tetap.
    init(data: DataLayar = TransferModel.dataContoh, nominal: Int? = nil, catatan: String = "", pemeriksaan: Pemeriksaan = .siap) {
        self.data = data
        self.ketikanNominal = nominal.map(Rupiah.angka) ?? ""
        self.catatan = catatan
        self.pemeriksaan = pemeriksaan
        self.layanan = LayananDummy()
        self.navigasi = nil
    }

    var nominal: Int? { ValidasiTransfer.nominal(dariKetikan: ketikanNominal) }

    var masalah: MasalahNominal? {
        ValidasiTransfer.periksa(nominal: nominal, saldo: data.saldo)
    }

    var bisaLanjut: Bool {
        masalah == nil && pemeriksaan != .memeriksa
    }

    /// Aturan field nominal ada di `ValidasiTransfer.rapikan`: titik ribuan langsung, maksimal 12 digit,
    /// selain angka rupiah ditolak. `sebelumnya` default nilai saat ini (chip, test); dari TextField diisi nilai lama.
    func ubahNominal(_ teks: String, sebelumnya: String? = nil) {
        let rapi = ValidasiTransfer.rapikan(ketikan: teks, sebelumnya: sebelumnya ?? ketikanNominal)
        if ketikanNominal != rapi { ketikanNominal = rapi }
        if case .gagal = pemeriksaan { pemeriksaan = .siap }
    }

    func pilihNominal(_ nilai: Int) {
        ubahNominal(String(nilai))
    }

    /// Cek FDS di server. Gagal = transfer berhenti di sini; tidak pernah diteruskan ke jalur normal.
    func lanjutkan() async {
        guard bisaLanjut, let nominal else { return }
        let permintaan = PermintaanTransfer(tujuan: data.tujuan, nominal: nominal,
                                            catatan: catatan.trimmingCharacters(in: .whitespacesAndNewlines))
        pemeriksaan = .memeriksa
        do {
            let hasil = try await layanan.cekRisiko(permintaan)
            pemeriksaan = .siap
            switch hasil {
            case .normal:
                navigasi?.buka(.pin(permintaan, perluPasskey: false))
            case .tinggi(let alasan):
                permintaanAktif = permintaan
                alasanPeringatan = alasan
                peringatanTampil = true
            }
        } catch {
            pemeriksaan = .gagal(Self.pesanFDSGagal)
        }
    }

    func lanjutkanKePIN() {
        lanjutSetelahSheet = true
        peringatanTampil = false
    }

    func batalkan() {
        lanjutSetelahSheet = false
        peringatanTampil = false
    }

    /// Dipanggil setelah sheet benar-benar tertutup, supaya push ke PIN tidak bertabrakan dengan animasi sheet.
    func sheetTertutup() {
        if lanjutSetelahSheet, let permintaan = permintaanAktif {
            navigasi?.buka(.pin(permintaan, perluPasskey: true))
        }
        lanjutSetelahSheet = false
        permintaanAktif = nil
        alasanPeringatan = nil
    }
}

extension AlasanRisiko {
    /// Isi sheet peringatan. Kalimat penutupnya sama untuk semua aturan.
    var pesan: String {
        let penutup = "Demi keamanan, diperlukan verifikasi tambahan sebelum transfer diproses."
        switch self {
        case .nominalBesar(let nominal, let batas):
            return "Nominal \(Rupiah.format(nominal)) melebihi batas kewajaran transaksi Anda (\(Rupiah.format(batas))). \(penutup)"
        case .totalMalam(let total, let batas):
            return "Total transfer Anda \(Rupiah.format(total)) dalam 4 jam terakhir pada jam malam melebihi batas \(Rupiah.format(batas)). \(penutup)"
        }
    }
}

extension TransferModel {
    static let dataContoh = DataLayar(saldo: DataTransfer.akun.saldo, tujuan: DataTransfer.rekeningTujuan[0])

    static var contoh: TransferModel { .init(nominal: 75_000_000, catatan: "bayar arisan") }
    static var kosongIsian: TransferModel { .init() }
    static var melebihiSaldo: TransferModel { .init(nominal: 200_000_000) }
    static var memeriksa: TransferModel { .init(nominal: 75_000_000, pemeriksaan: .memeriksa) }
    static var fdsGagal: TransferModel { .init(nominal: 75_000_000, pemeriksaan: .gagal(pesanFDSGagal)) }
    static var tujuanLain: TransferModel {
        .init(data: DataLayar(saldo: DataTransfer.akun.saldo, tujuan: DataTransfer.rekeningTujuan[2]), nominal: 1_000_000)
    }
}
