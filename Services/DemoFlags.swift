import Foundation

/// Memaksa satu layar ke state tertentu untuk demo, screenshot dan uji.
/// Isi lewat launch argument, misalnya `-demoBeranda gagal` (Edit Scheme > Run > Arguments),
/// atau `bash scripts/simulator-demo.sh paksa demoBeranda gagal`. Daftar lengkap: docs/userflow.md.
enum KeadaanDemo: String, Sendable {
    case normal
    case memuat
    case kosong
    case gagal
}

/// Satu case per layar atau langkah.
enum LayarDemo: String, Sendable {
    case contoh = "demoContoh"
    case beranda = "demoBeranda"
    /// Daftar rekening tujuan di layar Pilih Rekening Tujuan.
    case rekening = "demoRekening"
    /// Cek risiko FDS setelah Lanjutkan. `gagal` = koneksi putus saat cek.
    case fds = "demoFDS"
    /// Pemeriksaan PIN. `gagal` = koneksi putus, bukan PIN salah (PIN salah: ketik selain PIN dummy).
    case pin = "demoPin"
    /// Kirim transfer. `gagal` = koneksi putus.
    case kirim = "demoKirim"
    /// Verifikasi signature passkey. `gagal` = server menolak signature.
    case signature = "demoSignature"
    case riwayat = "demoRiwayat"
    case notifikasi = "demoNotifikasi"
    /// Kirim top up. `gagal` = koneksi putus, `kosong` = belum ada rekening.
    case topUp = "demoTopUp"
}

enum DemoFlags {
    static func keadaan(_ layar: LayarDemo) -> KeadaanDemo {
        guard let nilai = UserDefaults.standard.string(forKey: layar.rawValue) else { return .normal }
        return KeadaanDemo(rawValue: nilai) ?? .normal
    }

    /// `-demoJam 23:00`: jam server dummy dimulai dari jam itu hari ini, supaya aturan jam malam bisa didemokan siang hari.
    static func jam() -> (jam: Int, menit: Int)? {
        UserDefaults.standard.string(forKey: "demoJam").flatMap(uraiJam)
    }

    private static var transferContoh: Rute { .transfer(DataTransfer.rekeningTujuan[0], saldo: DataTransfer.akun.saldo) }

    /// `-demoMulai rekening|transfer|pin|verifikasi|berhasil|riwayat|notifikasi|topup`: app dibuka langsung di layar itu, untuk screenshot dan cek tata letak.
    /// Hanya tata letak: transfer contoh ini tidak terdaftar di server, jadi PIN di layar ini selalu "belum bisa diperiksa".
    static func ruteAwal() -> [Rute] {
        switch UserDefaults.standard.string(forKey: "demoMulai") {
        case "rekening": [.pilihRekening]
        case "transfer": [.pilihRekening, transferContoh]
        case "pin": [.pilihRekening, transferContoh, .pin(DataTransfer.permintaanNormal, perluPasskey: false)]
        case "verifikasi": [.pilihRekening, transferContoh, .verifikasi(DataTransfer.permintaanBesar)]
        case "berhasil": [.berhasil(DataTransfer.buktiPasskey)]
        case "riwayat": [.riwayat]
        case "notifikasi": [.notifikasi]
        case "topup": [.topUp]
        default: []
        }
    }

    static func uraiJam(_ teks: String) -> (jam: Int, menit: Int)? {
        let bagian = teks.split(separator: ":")
        guard bagian.count == 2, let jam = Int(bagian[0]), let menit = Int(bagian[1]),
              (0..<24).contains(jam), (0..<60).contains(menit) else { return nil }
        return (jam, menit)
    }
}
