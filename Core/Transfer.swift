import Foundation

/// Model alur transfer. Nominal selalu `Int` rupiah, tidak pernah `Double`.
/// Semua data di app ini data dummy (Services/DataTransfer.swift), bukan data nasabah.

/// Rekening nasabah yang sedang masuk.
struct Akun: Hashable, Sendable {
    let namaPanggilan: String
    let jenisTabungan: String
    let nomorRekening: String
    var saldo: Int
}

/// Rekening tujuan transfer.
struct Rekening: Identifiable, Hashable, Sendable {
    var id: String { nomor }
    let nomor: String
    let nama: String
    let bank: String
}

/// Satu transfer yang sedang diajukan. `id` dibuat baru setiap nasabah mengetuk Lanjutkan,
/// jadi hitungan PIN salah dan tantangan passkey selalu milik satu transfer.
struct PermintaanTransfer: Identifiable, Hashable, Sendable {
    let id: UUID
    let tujuan: Rekening
    let nominal: Int
    let catatan: String

    init(id: UUID = UUID(), tujuan: Rekening, nominal: Int, catatan: String) {
        self.id = id
        self.tujuan = tujuan
        self.nominal = nominal
        self.catatan = catatan
    }

    /// Data yang ditandatangani passkey: isi transfer + tantangan sekali pakai dari server.
    /// Panjang catatan ditulis di depannya supaya isi catatan tidak bisa menyamar sebagai field lain.
    func muatanTandaTangan(tantangan: Data) -> Data {
        var teks = "BRImo-transfer-v1\n"
        teks += id.uuidString + "\n"
        teks += tujuan.nomor + "\n"
        teks += String(nominal) + "\n"
        teks += String(catatan.utf8.count) + ":" + catatan + "\n"
        var data = Data(teks.utf8)
        data.append(tantangan)
        return data
    }
}

enum MetodeOtorisasi: Hashable, Sendable {
    case pin
    case passkey

    /// Baris Otorisasi di bukti transfer.
    var keterangan: String {
        switch self {
        case .pin: "Diotorisasi dengan PIN"
        case .passkey: "Diotorisasi dengan Passkey + Biometrik"
        }
    }

    /// Di baris Riwayat.
    var singkat: String {
        switch self {
        case .pin: "PIN"
        case .passkey: "Passkey"
        }
    }
}

extension PermintaanTransfer {
    /// Nomor referensi di detail transaksi: 8 karakter pertama id.
    var referensi: String { String(id.uuidString.prefix(8)) }
}

/// Bukti transfer dari server. `waktu` adalah jam server, bukan jam layar.
struct BuktiTransfer: Hashable, Sendable {
    let permintaan: PermintaanTransfer
    let metode: MetodeOtorisasi
    let waktu: Date
}

/// Tanda tangan passkey untuk satu transfer: tantangan dari server dan tanda tangan ECDSA (DER).
struct TandaTanganTransaksi: Hashable, Sendable {
    let tantangan: Data
    let tanda: Data
}

enum HasilPIN: Hashable, Sendable {
    case benar
    case salah(sisaKesempatan: Int)
    case terkunci
}
