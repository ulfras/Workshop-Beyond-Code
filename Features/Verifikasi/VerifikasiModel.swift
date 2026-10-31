import Foundation
import Observation

/// Layar 4 · Verifikasi biometrik + passkey (userflow #4). Hanya untuk transfer berisiko tinggi, setelah PIN benar.
///
/// Urutan: Face ID/Touch ID asli → tantangan sekali pakai dari server → tanda tangan perangkat → server
/// memverifikasi. Kalau biometrik tidak bisa dipakai, transfer berhenti: tidak ada jalan pintas lewat PIN saja.
@MainActor
@Observable
final class VerifikasiModel {
    enum Tahap: Equatable {
        case siap
        case memverifikasi
        case mengirim
        /// Bisa diulang di layar ini: wajah tidak dikenali, atau prompt ditutup.
        case ulang(String)
        /// Koneksi putus saat kirim. "Coba lagi" mengirim tanda tangan yang sama; biometrik tidak diminta ulang.
        case gagalKirim(String)
        /// Transfer dihentikan demi keamanan. Hanya bisa kembali ke Beranda.
        case dibatalkan(String)
    }

    static let pesanDitolak = "Verifikasi transaksi gagal. Demi keamanan, transfer ini dibatalkan."
    static let pesanKoneksi = "Koneksi terputus. Saldo Anda tidak berubah."

    let permintaan: PermintaanTransfer
    let jenis: JenisBiometrik
    private(set) var tahap: Tahap = .siap

    private let layanan: any LayananData
    private let biometrik: any Biometrik
    private let penandatangan: any Penandatangan
    private let navigasi: Navigasi?
    private var biometrikLulus = false
    private var tandaTangan: TandaTanganTransaksi?

    init(permintaan: PermintaanTransfer,
         layanan: any LayananData = LayananDummy(),
         biometrik: any Biometrik = BiometrikDummy(),
         penandatangan: any Penandatangan = PenandatanganPerangkat(),
         navigasi: Navigasi? = nil) {
        self.permintaan = permintaan
        self.layanan = layanan
        self.biometrik = biometrik
        self.penandatangan = penandatangan
        self.navigasi = navigasi
        self.jenis = biometrik.jenis
    }

    /// Untuk preview: state tetap.
    init(tahap: Tahap, jenis: JenisBiometrik = .faceID) {
        self.permintaan = DataTransfer.permintaanBesar
        self.layanan = LayananDummy()
        self.biometrik = BiometrikDummy(jenis: jenis)
        self.penandatangan = PenandatanganPerangkat()
        self.navigasi = nil
        self.jenis = jenis
        self.tahap = tahap
    }

    var sibuk: Bool { tahap == .memverifikasi || tahap == .mengirim }

    var namaBiometrik: String {
        switch jenis {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .tidakAda: "Biometrik"
        }
    }

    var instruksi: String {
        switch jenis {
        case .faceID: "Gunakan Face ID untuk mengotorisasi transaksi"
        case .touchID: "Tempelkan sidik jari untuk mengotorisasi transaksi"
        case .tidakAda: "Gunakan biometrik untuk mengotorisasi transaksi"
        }
    }

    var ikon: String {
        switch jenis {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .tidakAda: "lock.shield"
        }
    }

    func verifikasi() async {
        guard !sibuk else { return }
        if !biometrikLulus {
            tahap = .memverifikasi
            do {
                try await biometrik.verifikasi(alasan: "Otorisasi transfer \(Rupiah.format(permintaan.nominal)) ke \(permintaan.tujuan.nama)")
                biometrikLulus = true
            } catch let galat as GalatBiometrik {
                tangani(galat)
                return
            } catch {
                tangani(.tidakCocok)
                return
            }
        }
        await kirim()
    }

    func kirim() async {
        tahap = .mengirim
        let tanda: TandaTanganTransaksi
        if let ada = tandaTangan {
            tanda = ada
        } else {
            let tantangan: Data
            do {
                tantangan = try await layanan.mintaTantangan(untuk: permintaan)
            } catch is GalatTransfer {
                tahap = .dibatalkan(Self.pesanDitolak)
                return
            } catch {
                tahap = .gagalKirim(Self.pesanKoneksi)
                return
            }
            do {
                tanda = TandaTanganTransaksi(
                    tantangan: tantangan,
                    tanda: try penandatangan.tandatangani(permintaan.muatanTandaTangan(tantangan: tantangan)))
            } catch {
                tahap = .dibatalkan(Self.pesanDitolak)
                return
            }
            tandaTangan = tanda
        }

        do {
            let bukti = try await layanan.kirimTransfer(permintaan, tandaTangan: tanda)
            navigasi?.selesai(bukti)
        } catch GalatTransfer.saldoTidakCukup {
            tahap = .dibatalkan("Saldo tidak cukup. Transfer belum diproses.")
        } catch is GalatTransfer {
            tahap = .dibatalkan(Self.pesanDitolak)
        } catch {
            tahap = .gagalKirim(Self.pesanKoneksi)
        }
    }

    func batalkan() {
        navigasi?.kembaliKeAwal()
    }

    private func tangani(_ galat: GalatBiometrik) {
        switch galat {
        case .tidakCocok:
            tahap = .ulang(jenis == .touchID ? "Sidik jari tidak dikenali." : "Wajah tidak dikenali.")
        case .dibatalkan:
            tahap = .ulang("Verifikasi dibatalkan. Transfer belum diproses.")
        case .tidakTersedia:
            tahap = .dibatalkan("\(namaBiometrik) belum diaktifkan di iPhone ini. Transfer ini butuh verifikasi biometrik, jadi belum bisa diproses.")
        case .terkunci:
            tahap = .dibatalkan("\(namaBiometrik) terkunci karena terlalu banyak percobaan. Buka kunci iPhone dengan kode sandi, lalu coba lagi.")
        }
    }
}

extension VerifikasiModel {
    static var contoh: VerifikasiModel { .init(tahap: .siap) }
    static var touchID: VerifikasiModel { .init(tahap: .siap, jenis: .touchID) }
    static var memuat: VerifikasiModel { .init(tahap: .memverifikasi) }
    static var mengirim: VerifikasiModel { .init(tahap: .mengirim) }
    static var ulang: VerifikasiModel { .init(tahap: .ulang("Wajah tidak dikenali.")) }
    static var gagal: VerifikasiModel { .init(tahap: .gagalKirim(pesanKoneksi)) }
    static var ditolak: VerifikasiModel { .init(tahap: .dibatalkan(pesanDitolak)) }
}
