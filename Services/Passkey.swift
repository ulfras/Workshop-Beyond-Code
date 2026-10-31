import CryptoKit
import Foundation

/// SIMULASI passkey (docs/DECISIONS.md, 30 Okt 2026).
///
/// Passkey asli (`ASAuthorizationController`) butuh domain, entitlement Associated Domains dan server
/// relying party, yang belum ada. Di sini perangkat memegang kunci P-256 dari CryptoKit dan menandatangani
/// setiap transfer berisiko tinggi; backend dummy memeriksa tanda tangan itu dengan public key yang sudah
/// terdaftar. Alurnya sama dengan passkey: tantangan sekali pakai dari server → tanda tangan di perangkat →
/// verifikasi di server. Bedanya: kunci di memori (hilang saat app ditutup), bukan di Secure Enclave.

/// Kunci perangkat yang "terdaftar" di bank. Dibuat sekali per jalannya app (anggap terjadi saat aktivasi).
enum KunciPerangkat {
    static let bahanKunciPribadi: Data = P256.Signing.PrivateKey().rawRepresentation

    /// Public key yang disimpan server. Server tidak pernah menerima public key dari permintaan transfer.
    static var kunciPublik: Data {
        (try? P256.Signing.PrivateKey(rawRepresentation: bahanKunciPribadi))?.publicKey.rawRepresentation ?? Data()
    }
}

enum GalatPenandatangan: Error, Equatable {
    case kunciTidakValid
}

protocol Penandatangan: Sendable {
    /// Tanda tangan ECDSA P-256 atas `muatan`, dalam format DER.
    func tandatangani(_ muatan: Data) throws -> Data
}

struct PenandatanganPerangkat: Penandatangan {
    var bahanKunciPribadi: Data = KunciPerangkat.bahanKunciPribadi

    func tandatangani(_ muatan: Data) throws -> Data {
        guard let kunci = try? P256.Signing.PrivateKey(rawRepresentation: bahanKunciPribadi) else {
            throw GalatPenandatangan.kunciTidakValid
        }
        guard let tanda = try? kunci.signature(for: muatan) else { throw GalatPenandatangan.kunciTidakValid }
        return tanda.derRepresentation
    }
}

/// Dipakai backend dummy. Tanda tangan yang rusak, kunci lain, atau muatan yang diubah → `false`.
enum PemeriksaTandaTangan {
    static func valid(tanda: Data, muatan: Data, kunciPublik: Data) -> Bool {
        guard let kunci = try? P256.Signing.PublicKey(rawRepresentation: kunciPublik),
              let tandaTangan = try? P256.Signing.ECDSASignature(derRepresentation: tanda) else { return false }
        return kunci.isValidSignature(tandaTangan, for: muatan)
    }
}
