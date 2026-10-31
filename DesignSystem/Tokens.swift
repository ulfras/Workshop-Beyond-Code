import SwiftUI
import UIKit

// Token dari DESIGN.md (root repo). Nilai terang dari screenshot prototype BRImo (prototype/screenshots/),
// lalu disesuaikan supaya lolos kontras WCAG AA (lihat docs/DECISIONS.md, 30 Okt 2026).
// Ganti di DESIGN.md dan di file ini bersamaan. Jangan menulis hex atau ukuran font langsung di view.
// Varian lembut pakai opacity, bukan warna baru, misalnya Warna.utama.opacity(0.1) untuk chip.
// Teks dan ikon di atas isian: di atas `utama` pakai `utamaTeks`; di atas `sukses` dan `aksen` pakai `latar`.

enum Warna {
    // DESIGN.md: background, surface, primary, on-primary, accent, text, text-secondary, separator, success, warning, danger
    static let latar = Color(terang: 0xFFFFFF, gelap: 0x000000)
    static let permukaan = Color(terang: 0xF1F5F9, gelap: 0x1C1C1E)
    static let utama = Color(terang: 0x00529C, gelap: 0x5AA9FF)
    static let utamaTeks = Color(terang: 0xFFFFFF, gelap: 0x002B54)
    static let aksen = Color(terang: 0xDF5A09, gelap: 0xFF8A3D)
    static let teks = Color(terang: 0x020618, gelap: 0xF5F5F7)
    static let teksSekunder = Color(terang: 0x5B6B84, gelap: 0x94A3B8)
    static let garis = Color(terang: 0xE5E5EA, gelap: 0x38383A)
    static let sukses = Color(terang: 0x167F3E, gelap: 0x30D158)
    static let peringatan = Color(terang: 0xC93400, gelap: 0xFF9F0A)
    static let gagal = Color(terang: 0xDE0C00, gelap: 0xFF453A)

    // DESIGN.md: header, header-deep, on-header. Header Beranda dan launch screen: biru BRImo yang SAMA di kedua mode,
    // teks dan ikon di atasnya selalu putih. Sengaja tidak adaptif: navigation bar Beranda berskema gelap,
    // jadi warna adaptif akan berbeda antara bar dan pita di bawahnya. Launch screen: App/Assets.xcassets/WarnaLaunch.
    static let kepala = Color(terang: 0x00529C, gelap: 0x00529C)
    static let kepalaTua = Color(terang: 0x003872, gelap: 0x003872)
    static let kepalaTeks = Color(terang: 0xFFFFFF, gelap: 0xFFFFFF)
}

enum Space {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

/// Tombol utama selalu kapsul (`.capsule`), bukan radius angka.
enum Radius {
    static let s: CGFloat = 8
    static let m: CGFloat = 14
    static let l: CGFloat = 20
    static let xl: CGFloat = 28
}

enum Ukuran {
    static let tombol: CGFloat = 52
    static let ikon: CGFloat = 36
    static let sentuhMinimal: CGFloat = 44
}

/// Semua teks memakai text style supaya ikut Dynamic Type.
enum Teks {
    static let nominal = Font.largeTitle.weight(.bold)          // DESIGN.md title
    static let judulBesar = Font.title2.weight(.bold)           // DESIGN.md heading-lg
    static let judul = Font.title3.weight(.bold)                // DESIGN.md heading
    static let isi = Font.body
    static let isiTebal = Font.body.weight(.semibold)
    static let keterangan = Font.subheadline
    static let label = Font.footnote.weight(.semibold)
    static let tombol = Font.headline
}

extension Color {
    init(terang: UInt32, gelap: UInt32) {
        self.init(uiColor: UIColor { trait in
            UIColor(hex: trait.userInterfaceStyle == .dark ? gelap : terang)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}
