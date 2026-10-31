import Foundation

/// Alamat dan kunci Supabase untuk app. `kunci` HANYA kunci publishable (`sb_publishable_…`) atau anon,
/// tidak pernah kunci secret atau kunci service role.
struct KonfigurasiSupabase: Sendable, Equatable {
    let urlDasar: URL
    let kunci: String
}

/// Memilih sumber data app dari Info.plist (App/Info.plist ← Config/Proyek.xcconfig ← Config/Supabase.xcconfig).
///
/// - `SumberData` = "supabase" dan `SupabaseHost` + `SupabasePublishableKey` terisi → `LayananSupabase`.
/// - Selain itu → `LayananDummy`. Tanpa Config/Supabase.xcconfig app tetap jalan dengan data dummy.
enum SumberData {
    /// Dipanggil sekali di `PrototipeApp`. Preview dan test tidak memakai ini; mereka memakai `LayananDummy`.
    static func layanan(bundle: Bundle = .main) -> any LayananData {
        let sumber = teks("SumberData", di: bundle)
        let layanan = pilih(sumber: sumber,
                            host: teks("SupabaseHost", di: bundle),
                            kunci: teks("SupabasePublishableKey", di: bundle))
        #if DEBUG
        if layanan is LayananSupabase {
            print("[Prototipe] Sumber data: Supabase")
        } else if sumber?.lowercased() == "supabase" {
            print("[Prototipe] SUMBER_DATA = supabase, tapi SUPABASE_HOST atau SUPABASE_PUBLISHABLE_KEY kosong atau masih contoh. Memakai data dummy. Lihat docs/supabase-opsional.md.")
        } else {
            print("[Prototipe] Sumber data: dummy")
        }
        #endif
        return layanan
    }

    /// Logika pilihannya, tanpa Bundle, supaya bisa dites.
    static func pilih(sumber: String?, host: String?, kunci: String?) -> any LayananData {
        if let konfigurasi = konfigurasiSupabase(sumber: sumber, host: host, kunci: kunci) {
            return LayananSupabase(konfigurasi: konfigurasi)
        }
        return LayananDummy()
    }

    static func konfigurasiSupabase(sumber: String?, host: String?, kunci: String?) -> KonfigurasiSupabase? {
        guard bersih(sumber)?.lowercased() == "supabase",
              let host = bersih(host), let kunci = bersih(kunci) else { return nil }
        // Host saja, misalnya abcd1234.supabase.co. Di .xcconfig, "//" memulai komentar,
        // jadi "https://..." akan terpotong menjadi "https:".
        guard host.contains("."), !host.contains("/"), !host.contains(":"),
              !host.contains("your-project-ref"), !kunci.contains("xxxxxxxx") else { return nil }
        guard let url = URL(string: "https://\(host)"), url.host() != nil else { return nil }
        return KonfigurasiSupabase(urlDasar: url, kunci: kunci)
    }

    private static func teks(_ namaKey: String, di bundle: Bundle) -> String? {
        bundle.object(forInfoDictionaryKey: namaKey) as? String
    }

    /// Nilai kosong atau "$(...)" (build setting yang tidak terisi) dianggap tidak ada.
    private static func bersih(_ nilai: String?) -> String? {
        guard let nilai = nilai?.trimmingCharacters(in: .whitespacesAndNewlines),
              !nilai.isEmpty, !nilai.hasPrefix("$(") else { return nil }
        return nilai
    }
}
