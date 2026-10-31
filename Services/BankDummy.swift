import Foundation

/// Backend tiruan untuk alur transfer. Semua aturan keamanan dicek di sini, bukan di layar,
/// supaya layar yang dimanipulasi tetap tidak bisa melewati PIN atau passkey:
///
/// - Transfer harus didaftarkan lewat `cekRisiko` dulu; isi yang dikirim harus sama persis.
/// - PIN wajib untuk semua transfer. Salah 3 kali → transfer itu terkunci.
/// - FDS dinilai ulang saat kirim. Risiko tinggi tanpa tanda tangan passkey → ditolak.
/// - Tanda tangan dicek dengan public key terdaftar dan tantangan sekali pakai (tidak bisa diputar ulang).
/// - Kirim ulang dengan `id` yang sama mengembalikan bukti yang sama; saldo tidak terpotong dua kali.
///
/// Server juga mencatat riwayat transfer berhasil dan notifikasi keamanan.
/// State hanya di memori: hilang saat app ditutup.
actor BankDummy {
    static let batasPercobaanPIN = 3

    private var akun: Akun?
    private let tujuan: [Rekening]
    /// Transfer berhasil, terlama di depan. Sumber layar Riwayat dan hitungan FDS 4 jam.
    private var transaksi: [BuktiTransfer]
    /// Terlama di depan.
    private var kotakNotifikasi: [Notifikasi]
    private let pinBenar: String
    private let kunciPublik: Data
    private let aturan: AturanRisiko
    private let sekarang: @Sendable () -> Date
    /// Push "Transfer berhasil" ke perangkat nasabah. `nil` di test dan preview.
    private let push: (any PengirimPush)?

    private var terdaftar: [UUID: PermintaanTransfer] = [:]
    private var percobaanSalah: [UUID: Int] = [:]
    private var pinLulus: Set<UUID> = []
    private var tantangan: [UUID: Data] = [:]
    private var selesai: [UUID: BuktiTransfer] = [:]
    /// Peringatan risiko hanya sekali per transfer, walaupun cek risiko diulang.
    private var sudahDiperingatkan: Set<UUID> = []
    private var topUpSelesai: [UUID: BuktiTopUp] = [:]

    init(sekarang: @escaping @Sendable () -> Date = { Date() },
         akun: Akun? = DataTransfer.akun,
         tujuan: [Rekening] = DataTransfer.rekeningTujuan,
         riwayat: [BuktiTransfer]? = nil,
         pinBenar: String = "000000",
         kunciPublik: Data = KunciPerangkat.kunciPublik,
         aturan: AturanRisiko = AturanRisiko(),
         push: (any PengirimPush)? = nil) {
        self.sekarang = sekarang
        self.push = push
        self.akun = akun
        self.tujuan = tujuan
        let awal = riwayat ?? DataTransfer.riwayatAwal(sekarang: sekarang())
        self.transaksi = awal
        // Satu notifikasi per transfer lama; hanya yang terbaru belum dibaca.
        self.kotakNotifikasi = awal.enumerated().map { indeks, bukti in
            Self.notifikasiBerhasil(bukti, dibaca: indeks < awal.count - 1)
        }
        self.pinBenar = pinBenar
        self.kunciPublik = kunciPublik
        self.aturan = aturan
    }

    func akunSaatIni() -> Akun? { akun }

    func daftarTujuan() -> [Rekening] { tujuan }

    /// Terbaru di depan.
    func daftarRiwayat() -> [BuktiTransfer] { transaksi.reversed() }

    /// Terbaru di depan.
    func daftarNotifikasi() -> [Notifikasi] { kotakNotifikasi.reversed() }

    func tandaiSemuaDibaca() {
        for indeks in kotakNotifikasi.indices {
            kotakNotifikasi[indeks].dibaca = true
        }
    }

    func cekRisiko(_ permintaan: PermintaanTransfer) -> HasilRisiko {
        let baru = selesai[permintaan.id] == nil
        if baru {
            terdaftar[permintaan.id] = permintaan
        }
        let hasil = aturan.nilai(nominal: permintaan.nominal, waktu: sekarang(), riwayat: riwayatFDS)
        if case .tinggi = hasil, baru, sudahDiperingatkan.insert(permintaan.id).inserted {
            kotakNotifikasi.append(Self.notifikasiPeringatan(permintaan, waktu: sekarang()))
        }
        return hasil
    }

    func periksaPIN(_ pin: String, untuk id: UUID) throws -> HasilPIN {
        guard let permintaan = terdaftar[id] else { throw GalatTransfer.permintaanTidakDikenal }
        let salah = percobaanSalah[id, default: 0]
        guard salah < Self.batasPercobaanPIN else { return .terkunci }
        if pin == pinBenar {
            pinLulus.insert(id)
            return .benar
        }
        percobaanSalah[id] = salah + 1
        let sisa = Self.batasPercobaanPIN - (salah + 1)
        if sisa > 0 { return .salah(sisaKesempatan: sisa) }
        kotakNotifikasi.append(Self.notifikasiPINTerkunci(permintaan, waktu: sekarang()))
        return .terkunci
    }

    /// Tantangan acak 32 byte, sekali pakai. Hanya untuk transfer yang PIN-nya sudah benar.
    func mintaTantangan(untuk id: UUID) throws -> Data {
        guard terdaftar[id] != nil, pinLulus.contains(id) else { throw GalatTransfer.pinBelumDiverifikasi }
        let baru = Data((0..<32).map { _ in UInt8.random(in: .min ... .max) })
        tantangan[id] = baru
        return baru
    }

    func kirim(_ permintaan: PermintaanTransfer, tandaTangan: TandaTanganTransaksi?) throws -> BuktiTransfer {
        if let bukti = selesai[permintaan.id], bukti.permintaan == permintaan {
            return bukti
        }
        guard let asli = terdaftar[permintaan.id], asli == permintaan else {
            throw GalatTransfer.permintaanTidakDikenal
        }
        guard pinLulus.contains(permintaan.id) else { throw GalatTransfer.pinBelumDiverifikasi }

        let waktu = sekarang()
        let risiko = aturan.nilai(nominal: permintaan.nominal, waktu: waktu, riwayat: riwayatFDS)
        let metode: MetodeOtorisasi
        if let tandaTangan {
            // Tantangan dibuang begitu dipakai, cocok atau tidak.
            let harapan = tantangan.removeValue(forKey: permintaan.id)
            guard let harapan, harapan == tandaTangan.tantangan,
                  PemeriksaTandaTangan.valid(tanda: tandaTangan.tanda,
                                             muatan: permintaan.muatanTandaTangan(tantangan: harapan),
                                             kunciPublik: kunciPublik) else {
                kotakNotifikasi.append(Self.notifikasiTandaTanganDitolak(permintaan, waktu: waktu))
                throw GalatTransfer.tandaTanganDitolak
            }
            metode = .passkey
        } else {
            guard risiko == .normal else { throw GalatTransfer.butuhVerifikasiTambahan }
            metode = .pin
        }

        guard let saatIni = akun, saatIni.saldo >= permintaan.nominal else { throw GalatTransfer.saldoTidakCukup }
        akun?.saldo = saatIni.saldo - permintaan.nominal

        let bukti = BuktiTransfer(permintaan: permintaan, metode: metode, waktu: waktu)
        transaksi.append(bukti)
        kotakNotifikasi.append(Self.notifikasiBerhasil(bukti))
        // Seperti server bank: push dikirim sekali, setelah saldo terpotong. Kirim ulang dengan id yang sama
        // kembali lebih awal di atas, jadi tidak sampai ke sini.
        push?.transferBerhasil(bukti)
        selesai[permintaan.id] = bukti
        terdaftar[permintaan.id] = nil
        pinLulus.remove(permintaan.id)
        return bukti
    }

    /// Menambah saldo. Nominal dicek ulang di server dengan `AturanTopUp`, sama seperti layar.
    /// Mengulang `id` yang sama mengembalikan bukti yang sama; `id` yang sama dengan nominal lain ditolak.
    func topUp(_ permintaan: PermintaanTopUp) throws -> BuktiTopUp {
        if let bukti = topUpSelesai[permintaan.id] {
            guard bukti.permintaan == permintaan else { throw GalatTopUp.permintaanBerbeda }
            return bukti
        }
        guard AturanTopUp.periksa(nominal: permintaan.nominal) == nil else { throw GalatTopUp.nominalTidakValid }
        guard let saatIni = akun else { throw GalatTopUp.tanpaRekening }
        let saldoBaru = saatIni.saldo + permintaan.nominal
        akun?.saldo = saldoBaru
        let bukti = BuktiTopUp(permintaan: permintaan, saldoBaru: saldoBaru, waktu: sekarang())
        topUpSelesai[permintaan.id] = bukti
        return bukti
    }

    /// Untuk `-demoSignature gagal`: server menolak tanda tangan tanpa memeriksanya.
    func tolakTandaTanganDemo(_ permintaan: PermintaanTransfer) {
        kotakNotifikasi.append(Self.notifikasiTandaTanganDitolak(permintaan, waktu: sekarang()))
    }

    private var riwayatFDS: [TransaksiTercatat] {
        transaksi.map { TransaksiTercatat(nominal: $0.permintaan.nominal, waktu: $0.waktu) }
    }

    // MARK: Teks notifikasi (dibuat server)

    static func notifikasiPeringatan(_ p: PermintaanTransfer, waktu: Date) -> Notifikasi {
        Notifikasi(jenis: .peringatan, judul: "Transaksi tidak biasa terdeteksi",
                   pesan: "Transfer \(Rupiah.format(p.nominal)) ke \(p.tujuan.nama) butuh verifikasi tambahan. Kalau ini bukan Anda, jangan lanjutkan transfer.",
                   waktu: waktu)
    }

    static func notifikasiBerhasil(_ bukti: BuktiTransfer, dibaca: Bool = false) -> Notifikasi {
        Notifikasi(jenis: .berhasil, judul: "Transfer berhasil",
                   pesan: "\(Rupiah.format(bukti.permintaan.nominal)) ke \(bukti.permintaan.tujuan.nama). \(bukti.metode.keterangan).",
                   waktu: bukti.waktu, dibaca: dibaca, bukti: bukti)
    }

    static func notifikasiPINTerkunci(_ p: PermintaanTransfer, waktu: Date) -> Notifikasi {
        Notifikasi(jenis: .dibatalkan, judul: "Transfer dibatalkan",
                   pesan: "PIN salah 3 kali. Transfer \(Rupiah.format(p.nominal)) ke \(p.tujuan.nama) dibatalkan demi keamanan.",
                   waktu: waktu)
    }

    static func notifikasiTandaTanganDitolak(_ p: PermintaanTransfer, waktu: Date) -> Notifikasi {
        Notifikasi(jenis: .dibatalkan, judul: "Verifikasi transaksi gagal",
                   pesan: "Transfer \(Rupiah.format(p.nominal)) ke \(p.tujuan.nama) dibatalkan demi keamanan.",
                   waktu: waktu)
    }
}
