import SwiftUI

/// Logo BRImo dari aset vektor `LogoBRImo` (App/Assets.xcassets, dibuat dengan scripts/buat-aset-logo.swift).
/// Logo asli: "BRI" biru di atas, "mo" biru muda di bawah. Di latar gelap (header biru atau mode gelap),
/// bagian "BRI" diwarnai putih supaya terbaca; "mo" tetap warna aslinya.
/// `LogoBRImo(latar: .gelap)`
struct LogoBRImo: View {
    enum Latar {
        /// Di atas latar putih: logo asli. Di mode gelap otomatis seperti `.gelap`.
        case terang
        /// Di atas `Warna.kepala` atau latar gelap lain.
        case gelap
    }

    let latar: Latar
    private let tinggiMaks: CGFloat
    @Environment(\.colorScheme) private var skema
    /// Tinggi logo; ikut Dynamic Type sampai `tinggiMaks`, supaya header tidak penuh logo.
    @ScaledMetric private var tinggiDasar: CGFloat

    /// "BRI" menempati 60% teratas logo; di bawahnya celah kosong, lalu "mo".
    private let batasBRI: CGFloat = 0.6
    /// Rasio lebar : tinggi PDF logo (24 × 20 pt).
    private let rasio: CGFloat = 1.2

    /// Di navigation bar: `LogoBRImo(latar: .gelap, tinggi: 28, tinggiMaks: 34)`.
    init(latar: Latar = .terang, tinggi: CGFloat = 36, tinggiMaks: CGFloat = 72) {
        self.latar = latar
        self.tinggiMaks = tinggiMaks
        _tinggiDasar = ScaledMetric(wrappedValue: tinggi, relativeTo: .title2)
    }

    var body: some View {
        let tinggi = min(tinggiDasar, tinggiMaks)
        let lebar = tinggi * rasio
        Group {
            if latar == .gelap || skema == .dark {
                ZStack {
                    Image(.logoBRImo)
                        .resizable()
                        .mask(alignment: .bottom) { Rectangle().frame(height: tinggi * (1 - batasBRI)) }
                    Image(.logoBRImo)
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(Warna.kepalaTeks)
                        .mask(alignment: .top) { Rectangle().frame(height: tinggi * batasBRI) }
                }
            } else {
                Image(.logoBRImo)
                    .resizable()
            }
        }
        .frame(width: lebar, height: tinggi)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("BRImo")
        .accessibilityAddTraits(.isImage)
    }
}

#Preview("Logo") {
    VStack(spacing: Space.l) {
        LogoBRImo()
        LogoBRImo(latar: .gelap)
            .padding(Space.m)
            .background(Warna.kepala, in: .rect(cornerRadius: Radius.l))
    }
    .padding()
}
