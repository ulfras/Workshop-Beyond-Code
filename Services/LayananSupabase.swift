import Foundation

/// Data dari Supabase lewat PostgREST (REST API bawaan Supabase) dengan `URLSession`. Tanpa Swift package.
/// Hanya dipakai kalau `SumberData` memilihnya (lihat SumberData.swift dan docs/supabase-opsional.md).
///
/// Kunci yang dipakai hanya kunci publishable/anon. Yang menjaga data adalah RLS di
/// supabase/migrations/, bukan kunci ini. Skema berubah? Ikuti skill supabase-migrasi.
struct LayananSupabase: LayananData {
    let konfigurasi: KonfigurasiSupabase
    var sesi: URLSession = .shared
    /// Argument `-demoContoh gagal` dan kawan-kawan tetap berlaku di mode Supabase.
    var ikutiDemoFlags = true
    /// Tabel transfer belum ada di Supabase: alur transfer tetap memakai backend dummy.
    var cadanganTransfer = LayananDummy()

    func akun() async throws -> Akun? { try await cadanganTransfer.akun() }
    func rekeningTujuan() async throws -> [Rekening] { try await cadanganTransfer.rekeningTujuan() }
    func cekRisiko(_ permintaan: PermintaanTransfer) async throws -> HasilRisiko {
        try await cadanganTransfer.cekRisiko(permintaan)
    }
    func periksaPIN(_ pin: String, untuk permintaan: PermintaanTransfer) async throws -> HasilPIN {
        try await cadanganTransfer.periksaPIN(pin, untuk: permintaan)
    }
    func mintaTantangan(untuk permintaan: PermintaanTransfer) async throws -> Data {
        try await cadanganTransfer.mintaTantangan(untuk: permintaan)
    }
    func kirimTransfer(_ permintaan: PermintaanTransfer, tandaTangan: TandaTanganTransaksi?) async throws -> BuktiTransfer {
        try await cadanganTransfer.kirimTransfer(permintaan, tandaTangan: tandaTangan)
    }
    func riwayatTransfer() async throws -> [BuktiTransfer] { try await cadanganTransfer.riwayatTransfer() }
    func notifikasi() async throws -> [Notifikasi] { try await cadanganTransfer.notifikasi() }
    func tandaiNotifikasiDibaca() async throws { try await cadanganTransfer.tandaiNotifikasiDibaca() }
    func topUp(_ permintaan: PermintaanTopUp) async throws -> BuktiTopUp { try await cadanganTransfer.topUp(permintaan) }

    func daftarContoh() async throws -> [ItemContoh] {
        if ikutiDemoFlags {
            switch DemoFlags.keadaan(.contoh) {
            case .memuat: try await Task.sleep(for: .seconds(3600))
            case .gagal: throw GalatLayanan.koneksiTerputus
            case .kosong: return []
            case .normal: break
            }
        }
        // Tabel public.item_contoh (supabase/migrations/0001_contoh.sql). Nama kolom = nama properti ItemContoh.
        return try await ambil(tabel: "item_contoh", query: [
            URLQueryItem(name: "select", value: "id,judul,keterangan,nominal,ikon"),
            URLQueryItem(name: "order", value: "id.asc")
        ])
    }

    /// GET https://<host>/rest/v1/<tabel>?<query>, lalu dekode array JSON.
    private func ambil<Baris: Decodable & Sendable>(tabel: String, query: [URLQueryItem]) async throws -> [Baris] {
        var komponen = URLComponents(url: konfigurasi.urlDasar.appending(path: "rest/v1/\(tabel)"),
                                     resolvingAgainstBaseURL: false)
        komponen?.queryItems = query
        guard let url = komponen?.url else { throw GalatLayanan.koneksiTerputus }

        var permintaan = URLRequest(url: url)
        permintaan.timeoutInterval = 15
        permintaan.setValue("application/json", forHTTPHeaderField: "Accept")
        // Kunci publishable cukup dikirim di header `apikey`; Supabase memperlakukannya sebagai peran `anon`.
        permintaan.setValue(konfigurasi.kunci, forHTTPHeaderField: "apikey")

        let (data, respons) = try await sesi.data(for: permintaan)
        guard let http = respons as? HTTPURLResponse else { throw GalatLayanan.koneksiTerputus }
        guard (200..<300).contains(http.statusCode) else {
            #if DEBUG
            // Untuk agen dan Tester: pesan PostgREST (misalnya "permission denied" atau tabel tidak ada).
            print("[Prototipe] Supabase \(tabel): HTTP \(http.statusCode) \(String(decoding: data.prefix(300), as: UTF8.self))")
            #endif
            throw GalatLayanan.server(kode: http.statusCode)
        }
        return try JSONDecoder().decode([Baris].self, from: data)
    }
}
