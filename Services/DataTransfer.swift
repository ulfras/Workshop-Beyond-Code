import Foundation

/// Data dummy alur transfer. Nama, nomor rekening dan nominal contoh, bukan data nasabah.
enum DataTransfer {
    static let akun = Akun(namaPanggilan: "Budi", jenisTabungan: "BritAma",
                           nomorRekening: "0000 01 000000 00 1", saldo: 125_000_000)

    static let kontak = [
        Rekening(nomor: "0000000002", nama: "Ayu Contoh", bank: "Bank BRI"),
        Rekening(nomor: "0000000003", nama: "Citra Contoh", bank: "Bank BRI"),
        Rekening(nomor: "0000000004", nama: "Dimas Contoh", bank: "Bank BRI")
    ]

    /// Rekening tujuan yang bisa dipilih di layar Pilih Rekening Tujuan. Yang pertama dipakai di preview dan test.
    static let rekeningTujuan = kontak

    /// Bentuk kartu saldo saat memuat (diburamkan dengan `.redacted`).
    static let akunPlaceholder = Akun(namaPanggilan: "Nasabah", jenisTabungan: "Tabungan",
                                      nomorRekening: "0000 00 000000 00 0", saldo: 10_000_000)

    /// Transfer lama, terlama di depan. Yang terakhir (Rp20.000.000 satu jam lalu) membuat aturan jam malam
    /// bisa didemokan dengan chip Rp10.000.000.
    static func riwayatAwal(sekarang: Date) -> [BuktiTransfer] {
        let hari: TimeInterval = 24 * 60 * 60
        return [
            BuktiTransfer(permintaan: PermintaanTransfer(tujuan: kontak[1], nominal: 1_500_000, catatan: "bayar kos"),
                          metode: .pin, waktu: sekarang.addingTimeInterval(-3 * hari)),
            BuktiTransfer(permintaan: PermintaanTransfer(tujuan: kontak[2], nominal: 250_000, catatan: ""),
                          metode: .pin, waktu: sekarang.addingTimeInterval(-hari)),
            BuktiTransfer(permintaan: PermintaanTransfer(tujuan: kontak[0], nominal: 20_000_000, catatan: "uang muka"),
                          metode: .pin, waktu: sekarang.addingTimeInterval(-60 * 60))
        ]
    }

    // Untuk preview.
    static let permintaanBesar = PermintaanTransfer(tujuan: rekeningTujuan[0], nominal: 75_000_000, catatan: "bayar arisan")
    static let permintaanNormal = PermintaanTransfer(tujuan: rekeningTujuan[0], nominal: 1_000_000, catatan: "bayar arisan")
    static let buktiPasskey = BuktiTransfer(permintaan: permintaanBesar, metode: .passkey, waktu: Date())
    static let buktiPIN = BuktiTransfer(permintaan: permintaanNormal, metode: .pin, waktu: Date())

    static func notifikasiContoh(sekarang: Date = Date()) -> [Notifikasi] {
        [
            BankDummy.notifikasiBerhasil(BuktiTransfer(permintaan: permintaanBesar, metode: .passkey,
                                                       waktu: sekarang.addingTimeInterval(-60))),
            BankDummy.notifikasiPeringatan(permintaanBesar, waktu: sekarang.addingTimeInterval(-120)),
            BankDummy.notifikasiPINTerkunci(permintaanNormal, waktu: sekarang.addingTimeInterval(-3600)),
            BankDummy.notifikasiBerhasil(BuktiTransfer(permintaan: permintaanNormal, metode: .pin,
                                                       waktu: sekarang.addingTimeInterval(-86_400)), dibaca: true)
        ]
    }
}
