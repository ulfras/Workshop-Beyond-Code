import Foundation
import Testing
@testable import Prototipe

/// Pilihan sumber data. Tidak ada test di sini yang memanggil jaringan.
struct SumberDataTests {
    @Test("Default dummy, walaupun host dan kunci terisi")
    func defaultDummy() {
        let layanan = SumberData.pilih(sumber: "dummy", host: "abcd1234.supabase.co", kunci: "sb_publishable_contoh")
        #expect(layanan is LayananDummy)
    }

    @Test("Tanpa SumberData sama sekali: dummy")
    func tanpaSumber() {
        #expect(SumberData.pilih(sumber: nil, host: nil, kunci: nil) is LayananDummy)
        #expect(SumberData.pilih(sumber: "$(SUMBER_DATA)", host: "abcd1234.supabase.co", kunci: "sb_publishable_contoh") is LayananDummy)
    }

    @Test("Supabase dipilih kalau sumber = supabase dan host + kunci terisi")
    func supabaseLengkap() throws {
        let layanan = SumberData.pilih(sumber: "supabase", host: " abcd1234.supabase.co ", kunci: "sb_publishable_contoh")
        let supabase = try #require(layanan as? LayananSupabase)
        #expect(supabase.konfigurasi.urlDasar.absoluteString == "https://abcd1234.supabase.co")
        #expect(supabase.konfigurasi.kunci == "sb_publishable_contoh")
    }

    @Test("Host atau kunci kosong, belum diisi, atau salah format: kembali ke dummy",
          arguments: ["", "$(SUPABASE_HOST)", "your-project-ref.supabase.co", "https:", "https://abcd1234.supabase.co"])
    func hostTidakValid(host: String) {
        #expect(SumberData.pilih(sumber: "supabase", host: host, kunci: "sb_publishable_contoh") is LayananDummy)
    }

    // Nilai contoh dari Config/Supabase.example.xcconfig, dirangkai supaya scripts/cek-rahasia.sh tidak curiga.
    @Test("Kunci kosong atau masih contoh: kembali ke dummy",
          arguments: ["", "$(SUPABASE_PUBLISHABLE_KEY)", "sb_publishable_" + String(repeating: "x", count: 24)])
    func kunciTidakValid(kunci: String) {
        #expect(SumberData.pilih(sumber: "supabase", host: "abcd1234.supabase.co", kunci: kunci) is LayananDummy)
    }
}
