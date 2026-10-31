// Menyusun screenshot gaya App Store dari screenshot Simulator di marketing/raw/.
//
//   swift scripts/buat-screenshot-appstore.swift
//
// Hasil: marketing/framed/NN-<nama>.png, 1290 × 2796 px, tanpa alpha (iPhone 6,9", diterima App Store Connect).
//
// Tema: keamanan perbankan yang tenang. Navy BRI dengan cincin "radar" (sistem yang selalu memantau),
// satu kata penekanan per headline dengan biru muda logo "mo", kartu callout yang menunjuk momen penting,
// framing ponsel tegak dan miring bergantian, dan slide penutup tanpa ponsel berisi aturan FDS.
// Warna dari DESIGN.md: header #00529C, header-deep #003872, accent #DF5A09, success #167F3E.
// Bingkai ponsel digambar sendiri (bukan aset resmi Apple).
import AppKit
import CoreGraphics
import Foundation

let lebar = 1290.0, tinggi = 2796.0
let akar = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let folderRaw = akar.appending(path: "marketing/raw")
let folderFramed = akar.appending(path: "marketing/framed")
let fileLogo = akar.appending(path: "App/Assets.xcassets/LogoBRImo.imageset/LogoBRImo.pdf")

func warna(_ hex: UInt32, _ a: Double = 1) -> NSColor {
    NSColor(srgbRed: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255, alpha: a)
}
// Token DESIGN.md
let utama = warna(0x00529C), kepalaTua = warna(0x003872), aksen = warna(0xDF5A09), sukses = warna(0x167F3E)
let teks = warna(0x020618), teksSekunder = warna(0x5B6B84), putih = warna(0xFFFFFF)
// Khusus materi pemasaran (tidak dipakai di app)
let navyDalam = warna(0x001A3D)
let biruMo = warna(0x5CC8F5)          // biru muda "mo" di logo, untuk kata penekanan di latar gelap
let pucatAtas = warna(0xEEF4FB), pucatBawah = warna(0xD6E5F5)

enum Latar { case gelap, pucat }
enum Framing { case tegak, miring(Double) }

struct Callout {
    let simbol: String
    let warnaSimbol: NSColor
    let judul: String
    let sub: String
    let posisi: CGPoint   // pojok kiri atas kartu, koordinat kanvas
}

struct Slide {
    let sumber: String?
    let hasil: String
    let label: String
    let baris: [String]   // baris headline (maks 5 kata total)
    let tekan: String     // kata/frasa yang ditekankan
    let sub: String
    let latar: Latar
    let framing: Framing
    let callout: Callout?
}

let slides = [
    Slide(sumber: "01-peringatan-fds.png", hasil: "01-deteksi.png", label: "Deteksi dini",
          baris: ["Transaksi janggal", "langsung terdeteksi"], tekan: "terdeteksi",
          sub: "Risiko diperiksa sebelum transfer diproses.", latar: .gelap, framing: .tegak,
          callout: Callout(simbol: "exclamationmark.shield.fill", warnaSimbol: aksen,
                           judul: "Risiko tinggi", sub: "Nominal di atas Rp50.000.000",
                           posisi: CGPoint(x: 60, y: 2560))),
    Slide(sumber: "02-verifikasi-passkey.png", hasil: "02-face-id.png", label: "Passkey + Biometrik",
          baris: ["Face ID menjaga", "transfer besar"], tekan: "Face ID",
          sub: "Verifikasi tambahan hanya saat perlu.", latar: .pucat, framing: .miring(-6),
          callout: Callout(simbol: "faceid", warnaSimbol: utama,
                           judul: "Diamankan Passkey", sub: "Kunci tersimpan di iPhone Anda",
                           posisi: CGPoint(x: 560, y: 2250))),
    Slide(sumber: "00-beranda-cadangan.png", hasil: "03-harian.png", label: "Tanpa friksi",
          baris: ["Transfer harian", "tetap cepat"], tekan: "cepat",
          sub: "Transaksi wajar cukup dengan PIN.", latar: .gelap, framing: .miring(5),
          callout: Callout(simbol: "bolt.shield.fill", warnaSimbol: sukses,
                           judul: "Transaksi normal", sub: "Cukup PIN, langsung terkirim",
                           posisi: CGPoint(x: 60, y: 2360))),
    Slide(sumber: "03-berhasil.png", hasil: "04-bukti.png", label: "Bukti transaksi",
          baris: ["Terlindungi", "tanpa ribet"], tekan: "tanpa ribet",
          sub: "Bukti jelas, lengkap dengan cara otorisasinya.", latar: .pucat, framing: .tegak,
          callout: Callout(simbol: "checkmark.seal.fill", warnaSimbol: sukses,
                           judul: "Diotorisasi", sub: "Passkey + Biometrik",
                           posisi: CGPoint(x: 520, y: 2080))),
    Slide(sumber: nil, hasil: "05-cara-kerja.png", label: "Fraud Detection Rule",
          baris: ["Aman otomatis,", "setiap transfer"], tekan: "otomatis",
          sub: "", latar: .gelap, framing: .tegak, callout: nil),
]

// MARK: - Alat gambar

/// Gambar simbol SF (monokrom, bagian dalam tetap berlubang) di tengah `kotak`, lalu diwarnai.
func gambarSimbol(_ nama: String, warna: NSColor, kotak: CGRect) {
    let cfg = NSImage.SymbolConfiguration(pointSize: kotak.height, weight: .semibold)
    guard let img = NSImage(systemSymbolName: nama, accessibilityDescription: nil)?.withSymbolConfiguration(cfg),
          let ctx = NSGraphicsContext.current?.cgContext else { return }
    let s = min(kotak.width / img.size.width, kotak.height / img.size.height)
    let w = img.size.width * s, h = img.size.height * s
    let r = CGRect(x: kotak.midX - w / 2, y: kotak.midY - h / 2, width: w, height: h)
    ctx.saveGState()
    ctx.beginTransparencyLayer(in: r.insetBy(dx: -4, dy: -4), auxiliaryInfo: nil)
    img.draw(in: r, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
    ctx.setBlendMode(.sourceIn)
    ctx.setFillColor(warna.cgColor)
    ctx.fill(r.insetBy(dx: -4, dy: -4))
    ctx.endTransparencyLayer()
    ctx.restoreGState()
}

@discardableResult
func gambarTeks(_ s: NSAttributedString, kotak: CGRect) -> CGFloat {
    let ukuran = s.boundingRect(with: CGSize(width: kotak.width, height: .greatestFiniteMagnitude),
                                options: [.usesLineFragmentOrigin, .usesFontLeading])
    s.draw(with: CGRect(x: kotak.minX, y: kotak.minY, width: kotak.width, height: ceil(ukuran.height)),
           options: [.usesLineFragmentOrigin, .usesFontLeading])
    return ceil(ukuran.height)
}

func paragraf(_ rata: NSTextAlignment, tinggiBaris: Double = 1) -> NSParagraphStyle {
    let g = NSMutableParagraphStyle()
    g.alignment = rata
    g.lineBreakMode = .byWordWrapping
    g.lineHeightMultiple = tinggiBaris
    return g
}

func teksBiasa(_ s: String, font: NSFont, warna: NSColor, rata: NSTextAlignment = .center) -> NSAttributedString {
    NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: warna, .paragraphStyle: paragraf(rata)])
}

func jalurBulat(_ r: CGRect, _ radius: Double) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func logoBRImo(_ ctx: CGContext, lebarLogo: Double, tengahX: Double, atas: Double) {
    guard let logo = NSImage(contentsOf: fileLogo) else { return }
    let h = lebarLogo * logo.size.height / logo.size.width
    let r = CGRect(x: tengahX - lebarLogo / 2, y: atas, width: lebarLogo, height: h)
    ctx.saveGState()
    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    logo.draw(in: r, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
    // "BRI" (60% atas) jadi putih, "mo" tetap biru muda (sama dengan scripts/buat-aset-logo.swift)
    ctx.setBlendMode(.sourceAtop)
    ctx.setFillColor(putih.cgColor)
    ctx.fill(CGRect(x: r.minX, y: r.minY, width: r.width, height: r.height * 0.6))
    ctx.endTransparencyLayer()
    ctx.restoreGState()
}

// MARK: - Bagian slide

func gambarLatar(_ ctx: CGContext, _ latar: Latar, pusatRadar: CGPoint) {
    let gelap = latar == .gelap
    let semua = CGRect(x: 0, y: 0, width: lebar, height: tinggi)
    NSGradient(colors: gelap ? [kepalaTua, navyDalam] : [pucatAtas, pucatBawah])!.draw(in: semua, angle: -90)
    // Cahaya lembut di belakang ponsel
    NSGradient(colors: [(gelap ? utama : putih).withAlphaComponent(gelap ? 0.75 : 0.9),
                        (gelap ? utama : putih).withAlphaComponent(0)])!
        .draw(fromCenter: pusatRadar, radius: 0, toCenter: pusatRadar, radius: 950, options: [])
    // Cincin radar
    ctx.setLineWidth(3)
    for i in 1...7 {
        let r = Double(i) * 190
        ctx.setStrokeColor((gelap ? putih : utama).withAlphaComponent(gelap ? 0.07 : 0.07).cgColor)
        ctx.strokeEllipse(in: CGRect(x: pusatRadar.x - r, y: pusatRadar.y - r, width: r * 2, height: r * 2))
    }
    // Titik-titik kecil di cincin, kesan "memindai"
    let titik: [(Double, Double)] = [(2, -20), (3, 200), (4, 150), (5, 20), (6, 110)]
    for (cincin, sudut) in titik {
        let r = cincin * 190, a = sudut * .pi / 180
        let p = CGPoint(x: pusatRadar.x + r * cos(a), y: pusatRadar.y + r * sin(a))
        ctx.setFillColor((cincin == 3 ? aksen : (gelap ? biruMo : utama)).withAlphaComponent(0.55).cgColor)
        ctx.fillEllipse(in: CGRect(x: p.x - 9, y: p.y - 9, width: 18, height: 18))
    }
}

/// Label, headline dengan satu penekanan, dan sub. Mengembalikan posisi y bagian bawah teks.
func gambarJudul(_ s: Slide, atas: Double) -> Double {
    let gelap = s.latar == .gelap
    // Pil label: ikon perisai + teks
    let fontLabel = NSFont.systemFont(ofSize: 40, weight: .bold)
    let lebarTeks = (s.label as NSString).size(withAttributes: [.font: fontLabel]).width
    let lebarPil = lebarTeks + 150
    let pil = CGRect(x: (lebar - lebarPil) / 2, y: atas, width: lebarPil, height: 80)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.setFillColor((gelap ? putih.withAlphaComponent(0.12) : utama.withAlphaComponent(0.10)).cgColor)
    ctx.addPath(jalurBulat(pil, 40)); ctx.fillPath()
    ctx.setStrokeColor((gelap ? putih.withAlphaComponent(0.22) : utama.withAlphaComponent(0.25)).cgColor)
    ctx.setLineWidth(2); ctx.addPath(jalurBulat(pil.insetBy(dx: 1, dy: 1), 39)); ctx.strokePath()
    gambarSimbol("checkmark.shield.fill", warna: aksen, kotak: CGRect(x: pil.minX + 34, y: pil.minY + 18, width: 44, height: 44))
    gambarTeks(teksBiasa(s.label, font: fontLabel, warna: gelap ? putih : utama, rata: .left),
               kotak: CGRect(x: pil.minX + 96, y: pil.minY + 16, width: lebarTeks + 10, height: 0))

    // Headline
    let fontJudul = NSFont.systemFont(ofSize: 116, weight: .heavy)
    let warnaJudul = gelap ? putih : teks
    let warnaTekan = gelap ? biruMo : utama
    let isi = s.baris.joined(separator: "\n")
    let judul = NSMutableAttributedString(string: isi, attributes: [
        .font: fontJudul, .foregroundColor: warnaJudul, .paragraphStyle: paragraf(.center, tinggiBaris: 0.92),
        .kern: -2,
    ])
    let rentang = (isi as NSString).range(of: s.tekan)
    if rentang.location != NSNotFound { judul.addAttribute(.foregroundColor, value: warnaTekan, range: rentang) }
    let yJudul = atas + 120
    let tJudul = gambarTeks(judul, kotak: CGRect(x: 60, y: yJudul, width: lebar - 120, height: 0))
    var bawah = yJudul + tJudul
    if !s.sub.isEmpty {
        let tSub = gambarTeks(teksBiasa(s.sub, font: NSFont.systemFont(ofSize: 52, weight: .medium),
                                        warna: gelap ? putih.withAlphaComponent(0.78) : teksSekunder),
                              kotak: CGRect(x: 110, y: bawah + 28, width: lebar - 220, height: 0))
        bawah += 28 + tSub
    }
    return bawah
}

func gambarPonsel(_ ctx: CGContext, layar: CGImage, atas: Double, framing: Framing, latar: Latar) {
    let lebarLayar = 940.0
    let tinggiLayar = lebarLayar * Double(layar.height) / Double(layar.width)
    let bezel = 28.0
    let layarRect = CGRect(x: (lebar - lebarLayar) / 2, y: atas + bezel, width: lebarLayar, height: tinggiLayar)
    let bodi = layarRect.insetBy(dx: -bezel, dy: -bezel)
    let rLayar = lebarLayar * 0.137, rBodi = rLayar + bezel

    ctx.saveGState()
    if case .miring(let derajat) = framing {
        ctx.translateBy(x: bodi.midX, y: bodi.minY + 900)
        ctx.rotate(by: derajat * .pi / 180)
        ctx.translateBy(x: -bodi.midX, y: -(bodi.minY + 900))
    }
    // Bayangan
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 50), blur: 110,
                  color: NSColor.black.withAlphaComponent(latar == .gelap ? 0.55 : 0.28).cgColor)
    ctx.setFillColor(warna(0x16161A).cgColor)
    ctx.addPath(jalurBulat(bodi, rBodi)); ctx.fillPath()
    ctx.restoreGState()
    // Rangka
    NSGradient(colors: [warna(0x8A8F98), warna(0x3A3D44), warna(0x8A8F98)])!
        .draw(in: NSBezierPath(roundedRect: bodi, xRadius: rBodi, yRadius: rBodi), angle: 0)
    ctx.setFillColor(warna(0x111114).cgColor)
    ctx.addPath(jalurBulat(bodi.insetBy(dx: 6, dy: 6), rBodi - 6)); ctx.fillPath()
    // Layar
    ctx.saveGState()
    ctx.addPath(jalurBulat(layarRect, rLayar)); ctx.clip()
    NSImage(cgImage: layar, size: NSSize(width: layar.width, height: layar.height))
        .draw(in: layarRect, from: .zero, operation: .copy, fraction: 1, respectFlipped: true, hints: nil)
    ctx.restoreGState()
    // Dynamic Island (iPhone 17 Pro: 126 × 37 pt, 11 pt dari atas, layar 402 pt)
    let k = lebarLayar / 402
    let pulau = CGRect(x: layarRect.midX - 63 * k, y: layarRect.minY + 11 * k, width: 126 * k, height: 37 * k)
    ctx.setFillColor(NSColor.black.cgColor)
    ctx.addPath(jalurBulat(pulau, pulau.height / 2)); ctx.fillPath()
    ctx.restoreGState()
}

func gambarCallout(_ ctx: CGContext, _ c: Callout) {
    let fontJudul = NSFont.systemFont(ofSize: 46, weight: .bold)
    let fontSub = NSFont.systemFont(ofSize: 36, weight: .medium)
    let lebarIsi = max((c.judul as NSString).size(withAttributes: [.font: fontJudul]).width,
                       (c.sub as NSString).size(withAttributes: [.font: fontSub]).width)
    let kartu = CGRect(x: c.posisi.x, y: c.posisi.y, width: lebarIsi + 200, height: 180)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 24), blur: 60, color: NSColor.black.withAlphaComponent(0.28).cgColor)
    ctx.setFillColor(putih.cgColor)
    ctx.addPath(jalurBulat(kartu, 44)); ctx.fillPath()
    ctx.restoreGState()
    let ikon = CGRect(x: kartu.minX + 32, y: kartu.midY - 50, width: 100, height: 100)
    ctx.setFillColor(c.warnaSimbol.withAlphaComponent(0.13).cgColor)
    ctx.fillEllipse(in: ikon)
    gambarSimbol(c.simbol, warna: c.warnaSimbol, kotak: ikon.insetBy(dx: 24, dy: 24))
    gambarTeks(teksBiasa(c.judul, font: fontJudul, warna: teks, rata: .left),
               kotak: CGRect(x: ikon.maxX + 28, y: kartu.minY + 36, width: lebarIsi + 10, height: 0))
    gambarTeks(teksBiasa(c.sub, font: fontSub, warna: teksSekunder, rata: .left),
               kotak: CGRect(x: ikon.maxX + 28, y: kartu.minY + 98, width: lebarIsi + 10, height: 0))
}

/// Slide penutup: logo, headline, tiga aturan FDS dalam kartu kaca, perisai besar di radar.
func gambarPenutup(_ ctx: CGContext, _ s: Slide) {
    let pusat = CGPoint(x: lebar / 2, y: 2180)
    gambarLatar(ctx, .gelap, pusatRadar: pusat)
    logoBRImo(ctx, lebarLogo: 210, tengahX: lebar / 2, atas: 150)
    let bawahJudul = gambarJudul(s, atas: 420)

    let aturan: [(String, NSColor, String, String)] = [
        ("exclamationmark.triangle.fill", aksen, "Nominal tidak wajar", "Lebih dari Rp50.000.000"),
        ("moon.stars.fill", biruMo, "Lonjakan di jam malam", "22.00–05.59, total 4 jam > Rp30 juta"),
        ("faceid", putih, "Verifikasi saat perlu", "Transaksi harian cukup PIN"),
    ]
    var y = bawahJudul + 90
    for (ikonNama, warnaIkon, judul, sub) in aturan {
        let kartu = CGRect(x: 110, y: y, width: lebar - 220, height: 220)
        ctx.setFillColor(putih.withAlphaComponent(0.09).cgColor)
        ctx.addPath(jalurBulat(kartu, 48)); ctx.fillPath()
        ctx.setStrokeColor(putih.withAlphaComponent(0.16).cgColor)
        ctx.setLineWidth(2); ctx.addPath(jalurBulat(kartu.insetBy(dx: 1, dy: 1), 47)); ctx.strokePath()
        let ikon = CGRect(x: kartu.minX + 44, y: kartu.midY - 62, width: 124, height: 124)
        ctx.setFillColor(warnaIkon.withAlphaComponent(0.16).cgColor)
        ctx.fillEllipse(in: ikon)
        gambarSimbol(ikonNama, warna: warnaIkon, kotak: ikon.insetBy(dx: 30, dy: 30))
        gambarTeks(teksBiasa(judul, font: NSFont.systemFont(ofSize: 54, weight: .bold), warna: putih, rata: .left),
                   kotak: CGRect(x: ikon.maxX + 40, y: kartu.minY + 46, width: kartu.width - 260, height: 0))
        gambarTeks(teksBiasa(sub, font: NSFont.systemFont(ofSize: 40, weight: .medium),
                             warna: putih.withAlphaComponent(0.75), rata: .left),
                   kotak: CGRect(x: ikon.maxX + 40, y: kartu.minY + 120, width: kartu.width - 260, height: 0))
        y += 220 + 36
    }
    // Perisai besar di pusat radar, dengan keterangan di bawahnya
    gambarTeks(teksBiasa("Dipantau sebelum setiap transfer diproses", font: NSFont.systemFont(ofSize: 44, weight: .semibold),
                         warna: putih.withAlphaComponent(0.8)),
               kotak: CGRect(x: 110, y: pusat.y + 230, width: lebar - 220, height: 0))
    ctx.setFillColor(utama.cgColor)
    ctx.fillEllipse(in: CGRect(x: pusat.x - 170, y: pusat.y - 170, width: 340, height: 340))
    ctx.setStrokeColor(biruMo.withAlphaComponent(0.6).cgColor)
    ctx.setLineWidth(6)
    ctx.strokeEllipse(in: CGRect(x: pusat.x - 170, y: pusat.y - 170, width: 340, height: 340))
    gambarSimbol("checkmark.shield.fill", warna: putih, kotak: CGRect(x: pusat.x - 95, y: pusat.y - 95, width: 190, height: 190))
}

// MARK: - Susun

func buat(_ s: Slide) throws {
    guard let ctx = CGContext(data: nil, width: Int(lebar), height: Int(tinggi), bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { throw CocoaError(.fileWriteUnknown) }
    ctx.translateBy(x: 0, y: tinggi)   // koordinat dari atas
    ctx.scaleBy(x: 1, y: -1)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)

    if let sumber = s.sumber {
        guard let img = NSImage(contentsOf: folderRaw.appending(path: sumber)),
              let layar = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Lewati: marketing/raw/\(sumber) tidak ada")
            NSGraphicsContext.restoreGraphicsState()
            return
        }
        gambarLatar(ctx, s.latar, pusatRadar: CGPoint(x: lebar / 2, y: 1500))
        let bawah = gambarJudul(s, atas: 150)
        gambarPonsel(ctx, layar: layar, atas: bawah + 110, framing: s.framing, latar: s.latar)
        if let c = s.callout { gambarCallout(ctx, c) }
    } else {
        gambarPenutup(ctx, s)
    }

    NSGraphicsContext.restoreGraphicsState()
    guard let hasil = ctx.makeImage(),
          let data = NSBitmapImageRep(cgImage: hasil).representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    try data.write(to: folderFramed.appending(path: s.hasil))
    print("Tulis: marketing/framed/\(s.hasil)")
}

try FileManager.default.createDirectory(at: folderFramed, withIntermediateDirectories: true)
// Hapus hasil lama supaya tidak ada slide basi di folder
for f in (try? FileManager.default.contentsOfDirectory(atPath: folderFramed.path)) ?? [] where f.hasSuffix(".png") {
    try? FileManager.default.removeItem(at: folderFramed.appending(path: f))
}
for s in slides { try buat(s) }
