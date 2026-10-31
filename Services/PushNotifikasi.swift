import AudioToolbox
import Foundation
import UIKit
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
///
/// Jingle: transfer berhasil selalu terjadi saat app dibuka, jadi saat app aktif jingle diputar app sendiri
/// (`JingleBRImo`). Dengan begitu jingle tetap terdengar walaupun izin notifikasi belum diberikan atau ditolak.
/// Banner di depan tampil tanpa bunyi (`PenanganNotifikasi`), supaya jingle tidak dobel. Saat app di latar belakang,
/// iOS yang memutar jingle lewat notifikasi.
struct PengirimPushLokal: PengirimPush {
    func transferBerhasil(_ bukti: BuktiTransfer) {
        Task { @MainActor in
            if UIApplication.shared.applicationState == .active {
                JingleBRImo.putar()
            }
            await Self.kirim(bukti)
        }
    }

    private static func kirim(_ bukti: BuktiTransfer) async {
        let pusat = UNUserNotificationCenter.current()
        let pengaturan = await pusat.notificationSettings()
        switch pengaturan.authorizationStatus {
        case .notDetermined:
            guard (try? await pusat.requestAuthorization(options: [.alert, .sound, .badge])) == true else {
                catat("izin notifikasi tidak diberikan; banner tidak tampil, jingle tetap diputar app")
                return
            }
        case .authorized, .provisional, .ephemeral:
            break
        case .denied:
            catat("izin notifikasi ditolak (Settings › Notifications › BRImo); banner tidak tampil, jingle tetap diputar app")
            return
        @unknown default:
            return
        }
        do {
            try await pusat.add(PushNotifikasi.permintaan(untuk: bukti))
        } catch {
            catat("notifikasi gagal dijadwalkan: \(error.localizedDescription)")
        }
    }

    private static func catat(_ pesan: String) {
        #if DEBUG
        print("[Prototipe] Push: \(pesan)")
        #endif
    }
}

/// Memutar jingle BRImo dari bundle app. Dipakai saat transfer berhasil dan app sedang dibuka.
/// Lewat System Sound Services, seperti bunyi notifikasi: ikut volume dering dan mode senyap iPhone.
@MainActor
enum JingleBRImo {
    private static var idSuara: SystemSoundID = 0

    /// `true` kalau file jingle ditemukan dan bisa dimuat sebagai system sound.
    static var tersedia: Bool { muat() != nil }

    static func putar() {
        guard let id = muat() else { return }
        AudioServicesPlaySystemSound(id)
    }

    private static func muat() -> SystemSoundID? {
        if idSuara != 0 { return idSuara }
        let nama = PushNotifikasi.namaSuara as NSString
        guard let url = Bundle.main.url(forResource: nama.deletingPathExtension, withExtension: nama.pathExtension) else {
            return nil
        }
        var id: SystemSoundID = 0
        guard AudioServicesCreateSystemSoundID(url as CFURL, &id) == kAudioServicesNoError else { return nil }
        idSuara = id
        return id
    }
}

/// Supaya banner tetap muncul saat app sedang dibuka (transfer berhasil selalu terjadi di dalam app).
/// Tanpa `.sound`: jingle saat app dibuka diputar `JingleBRImo`. Dipasang sekali di `PrototipeApp.init`.
final class PenanganNotifikasi: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = PenanganNotifikasi()
    static let opsiSaatDibuka: UNNotificationPresentationOptions = [.banner, .list]

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Self.opsiSaatDibuka
    }
}
