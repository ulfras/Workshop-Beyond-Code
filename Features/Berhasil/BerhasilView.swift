import SwiftUI

/// Layar 5 · Transfer Berhasil (prototype 6-berhasil-passkey dan 7-berhasil-pin).
/// Semua data dibawa dari layar sebelumnya, jadi tidak ada state memuat, kosong atau gagal (docs/userflow.md).
struct BerhasilView: View {
    let bukti: BuktiTransfer
    let kembali: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Space.l) {
                IkonLingkaran(ikon: "checkmark", warna: Warna.sukses, gaya: .penuh)
                    .padding(.top, Space.xl)
                VStack(spacing: Space.xs) {
                    Text("Transfer Berhasil")
                        .font(Teks.judulBesar)
                        .foregroundStyle(Warna.teks)
                        .accessibilityAddTraits(.isHeader)
                    Text(Rupiah.format(bukti.permintaan.nominal))
                        .font(Teks.nominal)
                        .foregroundStyle(Warna.utama)
                        .monospacedDigit()
                }
                .multilineTextAlignment(.center)
                RincianTransfer(bukti: bukti)
            }
            .padding(Space.m)
        }
        .background(Warna.latar)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton("Kembali ke Beranda", aksi: kembali)
                .padding(Space.m)
                .background(Warna.latar)
        }
        .onAppear { AccessibilityNotification.Announcement("Transfer berhasil").post() }
    }
}

#Preview("Berhasil Passkey") {
    NavigationStack { BerhasilView(bukti: DataTransfer.buktiPasskey) {} }
}

#Preview("Berhasil PIN") {
    NavigationStack { BerhasilView(bukti: DataTransfer.buktiPIN) {} }
}

#Preview("Teks besar") {
    NavigationStack { BerhasilView(bukti: DataTransfer.buktiPasskey) {} }
        .dynamicTypeSize(.accessibility3)
}
