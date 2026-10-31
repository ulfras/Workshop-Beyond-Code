// Membuat aset logo BRImo di App/Assets.xcassets dari satu file PDF logo.
//
//   swift scripts/buat-aset-logo.swift ~/Downloads/BrimoIcon.pdf
//
// Hasilnya:
//   LogoBRImo.imageset   PDF asli (vektor), dipakai komponen LogoBRImo di app
//   AppIcon.appiconset   ikon 1024 px: latar biru, "BRI" putih, "mo" biru muda
//   LogoLaunch.imageset  logo untuk launch screen ("BRI" putih), 1x/2x/3x
//   WarnaLaunch.colorset latar launch screen, sama dengan Warna.kepala di Tokens.swift (#00529C, kedua mode)
//
// PDF logo: "BRI" di atas, "mo" di bawah, dengan celah kosong di antaranya (60% dari atas).
// Kalau logo resmi diganti dengan bentuk lain, cek nilai `batasBRI` di sini dan di DesignSystem/Komponen/LogoBRImo.swift.
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let batasBRI = 0.6  // bagian atas logo (0–60%) adalah "BRI"
// Sama dengan DESIGN.md: header (#00529C), header-deep (#003872). Sama di mode terang dan gelap.
let kepala = CGColor(srgbRed: 0x00 / 255, green: 0x52 / 255, blue: 0x9C / 255, alpha: 1)
let kepalaTua = CGColor(srgbRed: 0x00 / 255, green: 0x38 / 255, blue: 0x72 / 255, alpha: 1)
let putih = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)

guard CommandLine.arguments.count == 2 else {
    print("Pakai: swift scripts/buat-aset-logo.swift <logo.pdf>")
    exit(1)
}
let sumber = URL(fileURLWithPath: (CommandLine.arguments[1] as NSString).expandingTildeInPath)
guard let dokumen = CGPDFDocument(sumber as CFURL), let halaman = dokumen.page(at: 1) else {
    print("PDF tidak bisa dibaca: \(sumber.path)")
    exit(1)
}
let kotak = halaman.getBoxRect(.mediaBox)
let rasio = kotak.width / kotak.height
let katalog = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appending(path: "App/Assets.xcassets")
let ruangWarna = CGColorSpace(name: CGColorSpace.sRGB)!

func tulisJSON(_ isi: String, ke folder: URL) throws {
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    try isi.write(to: folder.appending(path: "Contents.json"), atomically: true, encoding: .utf8)
}

/// Menggambar logo di `area`. `briPutih`: bagian "BRI" diwarnai putih, "mo" tetap warna aslinya.
func gambarLogo(_ ctx: CGContext, di area: CGRect, briPutih: Bool) {
    ctx.saveGState()
    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    ctx.saveGState()
    ctx.translateBy(x: area.minX, y: area.minY)
    ctx.scaleBy(x: area.width / kotak.width, y: area.height / kotak.height)
    ctx.translateBy(x: -kotak.minX, y: -kotak.minY)
    ctx.drawPDFPage(halaman)
    ctx.restoreGState()
    if briPutih {
        // Koordinat CG dari bawah: "BRI" ada di 40% teratas tinggi area.
        let atas = CGRect(x: area.minX, y: area.minY + area.height * (1 - batasBRI),
                          width: area.width, height: area.height * batasBRI)
        ctx.setBlendMode(.sourceAtop)
        ctx.setFillColor(putih)
        ctx.fill(atas)
    }
    ctx.endTransparencyLayer()
    ctx.restoreGState()
}

func simpanPNG(_ gambar: CGImage, ke url: URL) throws {
    guard let tujuan = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw CocoaError(.fileWriteUnknown)
    }
    CGImageDestinationAddImage(tujuan, gambar, nil)
    guard CGImageDestinationFinalize(tujuan) else { throw CocoaError(.fileWriteUnknown) }
}

// 1. Logo vektor untuk app
let folderLogo = katalog.appending(path: "LogoBRImo.imageset")
try tulisJSON("""
{
  "images" : [ { "filename" : "LogoBRImo.pdf", "idiom" : "universal" } ],
  "info" : { "author" : "xcode", "version" : 1 },
  "properties" : { "preserves-vector-representation" : true }
}
""", ke: folderLogo)
let pdfTujuan = folderLogo.appending(path: "LogoBRImo.pdf")
try? FileManager.default.removeItem(at: pdfTujuan)
try FileManager.default.copyItem(at: sumber, to: pdfTujuan)

// 2. Ikon app 1024 px, tanpa transparansi (syarat App Store)
let sisi = 1024
let ctxIkon = CGContext(data: nil, width: sisi, height: sisi, bitsPerComponent: 8, bytesPerRow: 0,
                        space: ruangWarna, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
let gradasi = CGGradient(colorsSpace: ruangWarna, colors: [kepala, kepalaTua] as CFArray, locations: [0, 1])!
ctxIkon.drawLinearGradient(gradasi, start: CGPoint(x: 0, y: Double(sisi)), end: CGPoint(x: Double(sisi), y: 0), options: [])
let lebarLogoIkon = Double(sisi) * 0.56
let tinggiLogoIkon = lebarLogoIkon / rasio
gambarLogo(ctxIkon, di: CGRect(x: (Double(sisi) - lebarLogoIkon) / 2, y: (Double(sisi) - tinggiLogoIkon) / 2,
                               width: lebarLogoIkon, height: tinggiLogoIkon), briPutih: true)
let folderIkon = katalog.appending(path: "AppIcon.appiconset")
try tulisJSON("""
{
  "images" : [ { "filename" : "AppIcon.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" } ],
  "info" : { "author" : "xcode", "version" : 1 }
}
""", ke: folderIkon)
try simpanPNG(ctxIkon.makeImage()!, ke: folderIkon.appending(path: "AppIcon.png"))

// 3. Logo launch screen ("BRI" putih di atas latar biru), 96 × 80 pt
let folderLaunch = katalog.appending(path: "LogoLaunch.imageset")
try FileManager.default.createDirectory(at: folderLaunch, withIntermediateDirectories: true)
let lebarLaunch = 96.0
for skala in [1, 2, 3] {
    let w = Int(lebarLaunch) * skala, h = Int((lebarLaunch / rasio).rounded()) * skala
    let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                        space: ruangWarna, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    gambarLogo(ctx, di: CGRect(x: 0, y: 0, width: w, height: h), briPutih: true)
    try simpanPNG(ctx.makeImage()!, ke: folderLaunch.appending(path: "LogoLaunch@\(skala)x.png"))
}
try tulisJSON("""
{
  "images" : [
    { "filename" : "LogoLaunch@1x.png", "idiom" : "universal", "scale" : "1x" },
    { "filename" : "LogoLaunch@2x.png", "idiom" : "universal", "scale" : "2x" },
    { "filename" : "LogoLaunch@3x.png", "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
""", ke: folderLaunch)

// 4. Warna latar launch screen: Warna.kepala (#00529C, sama di mode terang dan gelap)
try tulisJSON("""
{
  "colors" : [
    { "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "blue" : "0x9C", "green" : "0x52", "red" : "0x00" } }, "idiom" : "universal" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
""", ke: katalog.appending(path: "WarnaLaunch.colorset"))

try tulisJSON("""
{
  "info" : { "author" : "xcode", "version" : 1 }
}
""", ke: katalog)

print("Selesai: \(katalog.path)")
