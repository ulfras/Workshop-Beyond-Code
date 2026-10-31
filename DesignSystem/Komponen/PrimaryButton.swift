import SwiftUI

/// Satu aksi utama per layar, selalu di bawah. Bentuk kapsul, warna primary (DESIGN.md > Components).
/// `PrimaryButton("Lanjut") { model.lanjut() }`
struct PrimaryButton: View {
    let judul: String
    let aksi: () -> Void

    init(_ judul: String, aksi: @escaping () -> Void) {
        self.judul = judul
        self.aksi = aksi
    }

    var body: some View {
        Button(judul, action: aksi)
            .buttonStyle(GayaTombolUtama())
    }
}

private struct GayaTombolUtama: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        LabelTombolUtama(configuration: configuration)
    }
}

private struct LabelTombolUtama: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var aktif

    var body: some View {
        configuration.label
            .font(Teks.tombol)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: Ukuran.tombol)
            .padding(.horizontal, Space.m)
            .foregroundStyle(aktif ? Warna.utamaTeks : Warna.teksSekunder)
            .background(aktif ? Warna.utama : Warna.garis, in: .capsule)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .contentShape(.rect)
    }
}

#Preview("Aktif") {
    PrimaryButton("Lanjut") {}
        .padding()
}

#Preview("Nonaktif") {
    PrimaryButton("Lanjut") {}
        .disabled(true)
        .padding()
}
