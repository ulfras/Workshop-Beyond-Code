import Foundation
import LocalAuthentication

enum JenisBiometrik: Sendable, Equatable {
    case faceID
    case touchID
    case tidakAda
}

enum GalatBiometrik: Error, Equatable, Sendable {
    /// Wajah atau sidik jari tidak cocok.
    case tidakCocok
    /// Nasabah menutup prompt, atau sistem membatalkannya.
    case dibatalkan
    /// Biometrik tidak ada, belum diatur, atau kode sandi iPhone belum dipasang.
    case tidakTersedia
    /// Terlalu banyak percobaan gagal; iPhone harus dibuka dengan kode sandi dulu.
    case terkunci
}

protocol Biometrik: Sendable {
    var jenis: JenisBiometrik { get }
    func verifikasi(alasan: String) async throws
}

/// Face ID atau Touch ID asli lewat LocalAuthentication. Butuh `NSFaceIDUsageDescription` di App/Info.plist.
/// Di Simulator: Features › Face ID › Enrolled, lalu Matching Face atau Non-matching Face.
struct BiometrikPerangkat: Biometrik {
    var jenis: JenisBiometrik {
        let konteks = LAContext()
        _ = konteks.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch konteks.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        default: return .tidakAda
        }
    }

    func verifikasi(alasan: String) async throws {
        let konteks = LAContext()
        // Tanpa tombol "Masukkan Kode Sandi": transfer berisiko tinggi wajib biometrik.
        konteks.localizedFallbackTitle = ""
        var galat: NSError?
        guard konteks.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &galat) else {
            throw Self.terjemahkan(galat)
        }
        do {
            let lulus = try await konteks.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: alasan)
            if !lulus { throw GalatBiometrik.tidakCocok }
        } catch let galat as GalatBiometrik {
            throw galat
        } catch {
            throw Self.terjemahkan(error as NSError)
        }
    }

    private static func terjemahkan(_ galat: NSError?) -> GalatBiometrik {
        guard let galat, galat.domain == LAError.errorDomain else { return .tidakCocok }
        switch LAError.Code(rawValue: galat.code) {
        case .userCancel, .appCancel, .systemCancel, .userFallback:
            return .dibatalkan
        case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet:
            return .tidakTersedia
        case .biometryLockout:
            return .terkunci
        default:
            return .tidakCocok
        }
    }
}

/// Untuk preview dan test. Tidak pernah memanggil Face ID.
struct BiometrikDummy: Biometrik {
    var jenis: JenisBiometrik = .faceID
    var galat: GalatBiometrik? = nil

    func verifikasi(alasan: String) async throws {
        if let galat { throw galat }
    }
}
