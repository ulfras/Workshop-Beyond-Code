import Foundation
import UserNotifications

/// Push notification "Transfer berhasil" dari server, dengan jingle BRImo.
///
/// SIMULASI push (docs/DECISIONS.md, 31 Okt 2026): push asli dikirim server bank lewat APNs dan butuh capability
/// Push Notifications, sertifikat dan server. Di prototipe, `BankDummy` (server dummy) memanggil `PengirimPush`
/// setelah transfer berhasil, dan `PengirimPushLokal` menampilkannya sebagai notifikasi lokal iOS: banner, bunyi,
/// dan masuk Notification Center, juga saat app sedang dibuka.
protocol PengirimPush: Sendable {
    /// Dipanggil server tepat sekali per transfer berhasil (kirim ulang dengan id yang sama tidak memanggil lagi).
    /// Tidak menunggu: transfer tidak boleh tertahan oleh izin notifikasi atau penjadwalan.
    func transferBerhasil(_ bukti: BuktiTransfer)
}

enum PushNotifikasi {
    /// Jingle BRImo di App/Suara/ (dikonversi dari MP3 dengan `afconvert -f caff -d ima4`; iOS tidak memutar MP3
    /// sebagai bunyi notifikasi, dan bunyi harus ≤ 30 detik).
    static let namaSuara = "notif_brimo.caf"
    static let kategoriTransfer = "transfer-berhasil"

    /// Isi notifikasi untuk satu transfer berhasil. Teksnya sama dengan notifikasi di layar Notifikasi.
    static func konten(untuk bukti: BuktiTransfer) -> UNMutableNotificationContent {
        let konten = UNMutableNotificationContent()
        konten.title = "Transfer Berhasil"
        konten.body = "\(Rupiah.format(bukti.permintaan.nominal)) ke \(bukti.permintaan.tujuan.nama). \(bukti.metode.keterangan)."
        konten.sound = UNNotificationSound(named: UNNotificationSoundName(namaSuara))
        konten.threadIdentifier = kategoriTransfer
        konten.categoryIdentifier = kategoriTransfer
        konten.userInfo = ["idTransfer": bukti.permintaan.id.uuidString]
        return konten
    }

    /// Satu notifikasi per transfer: id-nya id transfer, jadi tidak pernah dobel.
    static func permintaan(untuk bukti: BuktiTransfer) -> UNNotificationRequest {
        UNNotificationRequest(identifier: bukti.permintaan.id.uuidString, content: konten(untuk: bukti), trigger: nil)
    }
}

/// Menampilkan push sebagai notifikasi lokal. Izin diminta saat transfer pertama berhasil, bukan saat app dibuka.
struct PengirimPushLokal: PengirimPush {
    func transferBerhasil(_ bukti: BuktiTransfer) {
        Task { await kirim(bukti) }
    }

    private func kirim(_ bukti: BuktiTransfer) async {
        let pusat = UNUserNotificationCenter.current()
        let pengaturan = await pusat.notificationSettings()
        switch pengaturan.authorizationStatus {
        case .notDetermined:
            guard (try? await pusat.requestAuthorization(options: [.alert, .sound, .badge])) == true else { return }
        case .authorized, .provisional, .ephemeral:
            break
        case .denied:
            return
        @unknown default:
            return
        }
        try? await pusat.add(PushNotifikasi.permintaan(untuk: bukti))
    }
}

/// Supaya banner dan jingle tetap muncul saat app sedang dibuka (transfer berhasil selalu terjadi di dalam app).
/// Dipasang sekali di `PrototipeApp.init`.
final class PenanganNotifikasi: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = PenanganNotifikasi()

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
