import Foundation
import Observation

/// Layar 8 · Top Up: menambah saldo akun (dibuka dari aksi cepat Top Up di Beranda).
@MainActor
@Observable
final class TopUpModel {
    enum Tahap: Equatable {
        case mengisi
        case memproses
        /// Saldo tidak bertambah. "Coba lagi" mengirim top up yang sama (id sama).
        case gagal(String)
        case selesai(BuktiTopUp)
    }

    static let pesanKoneksi = "Top up belum berhasil. Koneksi terputus. Saldo Anda tidak berubah."
    static let pesanTanpaRekening = "Belum ada rekening yang terhubung. Saldo tidak bisa ditambah."
    static let pesanDitolak = "Nominal top up tidak bisa diproses. Periksa nominalnya, lalu coba lagi."

    /// Teks di field nominal, selalu berformat ribuan. Aturan ketikan sama dengan Transfer.
    var ketikanNominal = ""
    private(set) var tahap: Tahap = .mengisi

    private let layanan: any LayananData
    private let navigasi: Navigasi?
    /// Top up yang sedang atau terakhir dikirim; dipakai ulang oleh "Coba lagi".
    private var permintaanAktif: PermintaanTopUp?

    init(layanan: any LayananData = LayananDummy(), navigasi: Navigasi? = nil) {
        self.layanan = layanan
        self.navigasi = navigasi
    }

    /// Untuk preview: state tetap.
    init(tahap: Tahap, nominal: Int? = nil) {
        self.tahap = tahap
        self.ketikanNominal = nominal.map(Rupiah.angka) ?? ""
        self.layanan = LayananDummy()
        self.navigasi = nil
    }

    var nominal: Int? { ValidasiTransfer.nominal(dariKetikan: ketikanNominal) }
    var masalah: MasalahTopUp? { AturanTopUp.periksa(nominal: nominal) }
    var sibuk: Bool { tahap == .memproses }

    var bisaTopUp: Bool {
        switch tahap {
        case .mengisi, .gagal: masalah == nil
        case .memproses, .selesai: false
        }
    }

    /// Aturan field sama dengan Transfer (`ValidasiTransfer.rapikan`). Nominal berubah = top up baru.
    func ubahNominal(_ teks: String, sebelumnya: String? = nil) {
        let rapi = ValidasiTransfer.rapikan(ketikan: teks, sebelumnya: sebelumnya ?? ketikanNominal)
        if ketikanNominal != rapi { ketikanNominal = rapi }
        if permintaanAktif?.nominal != nominal { permintaanAktif = nil }
        if case .gagal = tahap { tahap = .mengisi }
    }

    func pilihNominal(_ nilai: Int) {
        ubahNominal(String(nilai))
    }

    func topUp() async {
        guard bisaTopUp, let nominal else { return }
        let permintaan = permintaanAktif ?? PermintaanTopUp(nominal: nominal)
        permintaanAktif = permintaan
        tahap = .memproses
        do {
            let bukti = try await layanan.topUp(permintaan)
            permintaanAktif = nil
            tahap = .selesai(bukti)
        } catch GalatTopUp.tanpaRekening {
            tahap = .gagal(Self.pesanTanpaRekening)
        } catch is GalatTopUp {
            permintaanAktif = nil
            tahap = .gagal(Self.pesanDitolak)
        } catch {
            tahap = .gagal(Self.pesanKoneksi)
        }
    }

    func kembaliKeBeranda() {
        navigasi?.kembaliKeAwal()
    }
}

extension TopUpModel {
    static var contoh: TopUpModel { .init(tahap: .mengisi, nominal: 500_000) }
    static var kosongIsian: TopUpModel { .init(tahap: .mengisi) }
    static var kurangDariMinimal: TopUpModel { .init(tahap: .mengisi, nominal: 5_000) }
    static var melebihiMaksimal: TopUpModel { .init(tahap: .mengisi, nominal: 200_000_000) }
    static var memproses: TopUpModel { .init(tahap: .memproses, nominal: 500_000) }
    static var gagal: TopUpModel { .init(tahap: .gagal(pesanKoneksi), nominal: 500_000) }
    static var tanpaRekening: TopUpModel { .init(tahap: .gagal(pesanTanpaRekening), nominal: 500_000) }
    static var selesai: TopUpModel {
        .init(tahap: .selesai(BuktiTopUp(permintaan: PermintaanTopUp(nominal: 500_000),
                                         saldoBaru: DataTransfer.akun.saldo + 500_000, waktu: Date())))
    }
}
