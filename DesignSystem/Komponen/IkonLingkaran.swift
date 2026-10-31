import SwiftUI

/// SF Symbol di dalam lingkaran, untuk status besar: centang berhasil, perisai peringatan.
/// Dekoratif: disembunyikan dari VoiceOver, jadi teks di sebelahnya yang harus menjelaskan.
/// `IkonLingkaran(ikon: "checkmark", warna: Warna.sukses, gaya: .penuh)`
struct IkonLingkaran: View {
    enum Gaya {
        /// Lingkaran berwarna, ikon `Warna.latar`.
        case penuh
        /// Lingkaran warna 15%, ikon berwarna.
        case lembut
    }

    let ikon: String
    let warna: Color
    var gaya: Gaya = .lembut

    @ScaledMetric(relativeTo: .largeTitle) private var ukuran: CGFloat = 72

    var body: some View {
        Image(systemName: ikon)
            .resizable()
            .scaledToFit()
            .fontWeight(.semibold)
            .foregroundStyle(gaya == .penuh ? Warna.latar : warna)
            .padding(ukuran * 0.26)
            .frame(width: ukuran, height: ukuran)
            .background(gaya == .penuh ? warna : warna.opacity(0.15), in: .circle)
            .accessibilityHidden(true)
    }
}

#Preview("Ikon") {
    HStack(spacing: Space.l) {
        IkonLingkaran(ikon: "checkmark", warna: Warna.sukses, gaya: .penuh)
        IkonLingkaran(ikon: "exclamationmark.shield", warna: Warna.aksen)
    }
    .padding()
}
