import Foundation

/// Pengganti backend, dan sumber data default. Ada jeda buatan supaya state "memuat" terlihat.
/// Tidak ada API asli, tidak ada kunci API, tidak ada data nasabah.
/// Aturan transfer (PIN, FDS, passkey) dijalankan oleh `BankDummy`.
struct LayananDummy: LayananData {
    var jeda: Duration
    /// Test memakai `false` supaya argument `-demo…` di scheme tidak memengaruhi hasil test.
    var ikutiDemoFlags: Bool
    let bank: BankDummy

    /// `push` hanya diisi app (`SumberData.layanan()`); preview dan test tanpa push.
    init(jeda: Duration = .milliseconds(600), ikutiDemoFlags: Bool = true, bank: BankDummy? = nil,
         push: (any PengirimPush)? = nil) {
        self.jeda = jeda
        self.ikutiDemoFlags = ikutiDemoFlags
        self.bank = bank ?? BankDummy(sekarang: Self.jamServer(ikutiDemoFlags: ikutiDemoFlags), push: push)
    }

    func daftarContoh() async throws -> [ItemContoh] {
        switch try await tunggu(.contoh) {
        case .kosong: return []
        default: return DataContoh.item
        }
    }

    // MARK: Alur transfer

    func akun() async throws -> Akun? {
        if try await tunggu(.beranda) == .kosong { return nil }
        return await bank.akunSaatIni()
    }

    func rekeningTujuan() async throws -> [Rekening] {
        if try await tunggu(.rekening) == .kosong { return [] }
        return await bank.daftarTujuan()
    }

    func cekRisiko(_ permintaan: PermintaanTransfer) async throws -> HasilRisiko {
        _ = try await tunggu(.fds)
        return await bank.cekRisiko(permintaan)
    }

    func periksaPIN(_ pin: String, untuk permintaan: PermintaanTransfer) async throws -> HasilPIN {
        _ = try await tunggu(.pin)
        return try await bank.periksaPIN(pin, untuk: permintaan.id)
    }

    func mintaTantangan(untuk permintaan: PermintaanTransfer) async throws -> Data {
        try await Task.sleep(for: jeda)
        return try await bank.mintaTantangan(untuk: permintaan.id)
    }

    func kirimTransfer(_ permintaan: PermintaanTransfer, tandaTangan: TandaTanganTransaksi?) async throws -> BuktiTransfer {
        _ = try await tunggu(.kirim)
        if tandaTangan != nil, ikutiDemoFlags, DemoFlags.keadaan(.signature) == .gagal {
            await bank.tolakTandaTanganDemo(permintaan)
            throw GalatTransfer.tandaTanganDitolak
        }
        return try await bank.kirim(permintaan, tandaTangan: tandaTangan)
    }

    // MARK: Riwayat dan notifikasi

    func riwayatTransfer() async throws -> [BuktiTransfer] {
        if try await tunggu(.riwayat) == .kosong { return [] }
        return await bank.daftarRiwayat()
    }

    func notifikasi() async throws -> [Notifikasi] {
        if try await tunggu(.notifikasi) == .kosong { return [] }
        return await bank.daftarNotifikasi()
    }

    func tandaiNotifikasiDibaca() async throws {
        await bank.tandaiSemuaDibaca()
    }

    // MARK: Top up

    /// `-demoTopUp gagal`: koneksi putus. `kosong`: server menjawab belum ada rekening. `memuat`: tidak pernah selesai.
    func topUp(_ permintaan: PermintaanTopUp) async throws -> BuktiTopUp {
        if try await tunggu(.topUp) == .kosong { throw GalatTopUp.tanpaRekening }
        return try await bank.topUp(permintaan)
    }

    private func tunggu(_ layar: LayarDemo) async throws -> KeadaanDemo {
        let keadaan = ikutiDemoFlags ? DemoFlags.keadaan(layar) : .normal
        switch keadaan {
        case .memuat:
            try await Task.sleep(for: .seconds(3600))
        case .gagal:
            try await Task.sleep(for: jeda)
            throw GalatLayanan.koneksiTerputus
        case .normal, .kosong:
            try await Task.sleep(for: jeda)
        }
        return keadaan
    }

    /// Jam server dummy. Dengan `-demoJam 23:00`, jam dimulai dari pukul itu hari ini lalu berjalan normal.
    private static func jamServer(ikutiDemoFlags: Bool) -> @Sendable () -> Date {
        guard ikutiDemoFlags, let demo = DemoFlags.jam(),
              let mulai = Calendar.current.date(bySettingHour: demo.jam, minute: demo.menit, second: 0, of: Date()) else {
            return { Date() }
        }
        let selisih = mulai.timeIntervalSinceNow
        return { Date().addingTimeInterval(selisih) }
    }
}
