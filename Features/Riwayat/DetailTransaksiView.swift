import SwiftUI

/// Detail satu transfer dari Riwayat atau Notifikasi. Datanya dibawa lewat rute, jadi tanpa state memuat, kosong atau gagal.
struct DetailTransaksiView: View {
    let bukti: BuktiTransfer

    var body: some View {
        ScrollView {
            VStack(spacing: Space.l) {
                VStack(spacing: Space.xs) {
                    Label("Transfer Berhasil", systemImage: "checkmark.circle.fill")
                        .font(Teks.isiTebal)
                        .foregroundStyle(Warna.sukses)
                    Text(Rupiah.format(bukti.permintaan.nominal))
                        .font(Teks.nominal)
                        .foregroundStyle(Warna.utama)
                        .monospacedDigit()
                    Text("ke \(bukti.permintaan.tujuan.nama) · \(bukti.permintaan.tujuan.bank)")
                        .font(Teks.keterangan)
                        .foregroundStyle(Warna.teksSekunder)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, Space.l)
                .accessibilityElement(children: .combine)
                RincianTransfer(bukti: bukti, tampilkanReferensi: true)
            }
            .padding(Space.m)
        }
        .background(Warna.latar)
        .navigationTitle("Detail Transaksi")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Passkey") {
    NavigationStack { DetailTransaksiView(bukti: DataTransfer.buktiPasskey) }
}

#Preview("PIN") {
    NavigationStack { DetailTransaksiView(bukti: DataTransfer.buktiPIN) }
}

#Preview("Teks besar") {
    NavigationStack { DetailTransaksiView(bukti: DataTransfer.buktiPasskey) }
        .dynamicTypeSize(.accessibility3)
}
