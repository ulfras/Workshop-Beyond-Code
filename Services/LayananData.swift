import Foundation

/// Semua data yang dibutuhkan layar. Model layar hanya mengenal protokol ini, jadi sumbernya
/// (dummy atau Supabase) bisa diganti tanpa menyentuh view. Sumber yang aktif dipilih di `SumberData`.
///
/// Layar baru butuh data baru? Tambah satu fungsi di sini, lalu isi di `LayananDummy`
/// (wajib, dipakai preview dan test) dan di `LayananSupabase` (kalau kelompok memakai Supabase).
protocol LayananData: Sendable {
    func daftarContoh() async throws -> [ItemContoh]

    // MARK: Alur transfer (docs/userflow.md)

    /// `nil` = belum ada rekening yang terhubung.
    func akun() async throws -> Akun?
    func rekeningTujuan() async throws -> [Rekening]
    /// Mendaftarkan transfer di server dan menilai risikonya (FDS).
    func cekRisiko(_ permintaan: PermintaanTransfer) async throws -> HasilRisiko
    func periksaPIN(_ pin: String, untuk permintaan: PermintaanTransfer) async throws -> HasilPIN
    /// Tantangan sekali pakai untuk ditandatangani passkey.
    func mintaTantangan(untuk permintaan: PermintaanTransfer) async throws -> Data
    /// `tandaTangan` wajib kalau server menilai risikonya tinggi.
    func kirimTransfer(_ permintaan: PermintaanTransfer, tandaTangan: TandaTanganTransaksi?) async throws -> BuktiTransfer

    // MARK: Riwayat dan notifikasi

    /// Transfer berhasil, terbaru di depan.
    func riwayatTransfer() async throws -> [BuktiTransfer]
    /// Notifikasi keamanan transaksi, terbaru di depan.
    func notifikasi() async throws -> [Notifikasi]
    func tandaiNotifikasiDibaca() async throws

    // MARK: Top up

    /// Menambah saldo. Mengulang dengan `id` yang sama mengembalikan bukti yang sama, tanpa menambah saldo lagi.
    func topUp(_ permintaan: PermintaanTopUp) async throws -> BuktiTopUp
}

enum GalatLayanan: Error {
    case koneksiTerputus
    /// Supabase menjawab dengan kode HTTP selain 2xx (misalnya 401 kunci salah, 404 tabel tidak ada).
    case server(kode: Int)
}

/// Penolakan dari server saat top up. Semuanya berarti saldo TIDAK bertambah.
enum GalatTopUp: Error, Equatable {
    /// Di bawah minimal atau di atas maksimal (`AturanTopUp`).
    case nominalTidakValid
    case tanpaRekening
    /// `id` yang sama dipakai lagi dengan nominal lain.
    case permintaanBerbeda
}

/// Penolakan dari server saat transfer. Semuanya berarti transfer TIDAK diproses.
enum GalatTransfer: Error, Equatable {
    case permintaanTidakDikenal
    case pinBelumDiverifikasi
    case butuhVerifikasiTambahan
    case tandaTanganDitolak
    case saldoTidakCukup
}
