import Foundation
import Observation

/// Layar 3 · Masukkan PIN (userflow #3). PIN dikirim otomatis begitu digit ke-6 diketik.
/// PIN hanya ada di sini selama diketik, tidak di-log, dan dihapus sebelum dikirim ke server.
@MainActor
@Observable
final class PINModel {
    enum Tahap: Equatable {
        case mengisi
        case memeriksa
        case mengirim
        /// Koneksi putus saat kirim. "Coba lagi" mengirim ulang transfer yang sama.
        case gagalKirim(String)
        /// Transfer dihentikan (PIN terkunci, saldo kurang). Hanya bisa kembali ke Beranda.
        case dibatalkan(String)
    }

    static let panjang = 6
    static let pesanTerkunci = "PIN salah 3 kali. Demi keamanan, transfer ini dibatalkan."
    static let pesanKoneksiPIN = "PIN belum bisa diperiksa. Periksa koneksi, lalu coba lagi."
    static let pesanKoneksiKirim = "Koneksi terputus. Saldo Anda tidak berubah."

    let permintaan: PermintaanTransfer
    let perluPasskey: Bool
    private(set) var jumlahDigit = 0
    private(set) var tahap: Tahap = .mengisi
    /// Pesan di bawah titik PIN: PIN salah atau koneksi putus.
    private(set) var pesan: String?
    /// Naik setiap PIN salah; dipakai untuk getaran haptic.
    private(set) var jumlahSalah = 0

    @ObservationIgnored private var digit = ""
    private let layanan: any LayananData
    private let navigasi: Navigasi?

    init(permintaan: PermintaanTransfer, perluPasskey: Bool,
         layanan: any LayananData = LayananDummy(), navigasi: Navigasi? = nil) {
        self.permintaan = permintaan
        self.perluPasskey = perluPasskey
        self.layanan = layanan
        self.navigasi = navigasi
    }

    /// Untuk preview: state tetap.
    init(tahap: Tahap, jumlahDigit: Int = 0, pesan: String? = nil, perluPasskey: Bool = false) {
        self.permintaan = DataTransfer.permintaanNormal
        self.perluPasskey = perluPasskey
        self.tahap = tahap
        self.jumlahDigit = jumlahDigit
        self.pesan = pesan
        self.layanan = LayananDummy()
        self.navigasi = nil
    }

    var sibuk: Bool { tahap == .memeriksa || tahap == .mengirim }

    func ketik(_ angka: Int) async {
        guard tahap == .mengisi, digit.count < Self.panjang, (0...9).contains(angka) else { return }
        if digit.isEmpty { pesan = nil }
        digit.append(String(angka))
        jumlahDigit = digit.count
        if digit.count == Self.panjang {
            await periksa()
        }
    }

    func hapus() {
        guard tahap == .mengisi, !digit.isEmpty else { return }
        digit.removeLast()
        jumlahDigit = digit.count
    }

    private func periksa() async {
        let pin = digit
        digit = ""
        jumlahDigit = 0
        tahap = .memeriksa
        pesan = nil

        let hasil: HasilPIN
        do {
            hasil = try await layanan.periksaPIN(pin, untuk: permintaan)
        } catch {
            // Koneksi putus tidak dihitung sebagai PIN salah.
            tahap = .mengisi
            pesan = Self.pesanKoneksiPIN
            return
        }

        switch hasil {
        case .salah(let sisa):
            jumlahSalah += 1
            tahap = .mengisi
            pesan = "PIN salah. Sisa \(sisa) kesempatan."
        case .terkunci:
            jumlahSalah += 1
            tahap = .dibatalkan(Self.pesanTerkunci)
        case .benar:
            if perluPasskey {
                tahap = .mengisi
                navigasi?.buka(.verifikasi(permintaan))
            } else {
                await kirim()
            }
        }
    }

    /// Jalur normal: kirim dengan PIN saja. Kalau server menilai risikonya sudah tinggi, lanjut ke passkey.
    func kirim() async {
        tahap = .mengirim
        do {
            let bukti = try await layanan.kirimTransfer(permintaan, tandaTangan: nil)
            navigasi?.selesai(bukti)
        } catch GalatTransfer.butuhVerifikasiTambahan {
            tahap = .mengisi
            navigasi?.buka(.verifikasi(permintaan))
        } catch GalatTransfer.saldoTidakCukup {
            tahap = .dibatalkan("Saldo tidak cukup. Transfer belum diproses.")
        } catch is GalatTransfer {
            tahap = .dibatalkan("Transfer belum bisa diproses. Silakan ulangi dari Beranda.")
        } catch {
            tahap = .gagalKirim(Self.pesanKoneksiKirim)
        }
    }

    func kembaliKeBeranda() {
        navigasi?.kembaliKeAwal()
    }
}

extension PINModel {
    static var contoh: PINModel { .init(tahap: .mengisi, jumlahDigit: 4) }
    static var kosong: PINModel { .init(tahap: .mengisi) }
    static var memuat: PINModel { .init(tahap: .memeriksa) }
    static var gagal: PINModel { .init(tahap: .mengisi, pesan: pesanKoneksiPIN) }
    static var salah: PINModel { .init(tahap: .mengisi, pesan: "PIN salah. Sisa 2 kesempatan.") }
    static var terkunci: PINModel { .init(tahap: .dibatalkan(pesanTerkunci)) }
    static var mengirim: PINModel { .init(tahap: .mengirim) }
    static var gagalKirim: PINModel { .init(tahap: .gagalKirim(pesanKoneksiKirim)) }
}
