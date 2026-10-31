import SwiftUI

/// Label di kiri, nilai di kanan. Pada teks besar, nilai turun ke bawah label supaya tidak terpotong.
/// `BarisRincian(label: "Waktu", nilai: "30 Okt 2026, 14.05")`
struct BarisRincian: View {
    let label: String
    let nilai: String
    var warna: Color = Warna.teks
    @Environment(\.dynamicTypeSize) private var ukuranTeks

    var body: some View {
        let tata = ukuranTeks.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Space.xs))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: Space.m))
        tata {
            Text(label)
                .font(Teks.keterangan)
                .foregroundStyle(Warna.teksSekunder)
            if !ukuranTeks.isAccessibilitySize { Spacer(minLength: Space.s) }
            Text(nilai)
                .font(Teks.isi)
                .foregroundStyle(warna)
                .multilineTextAlignment(ukuranTeks.isAccessibilitySize ? .leading : .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Kartu rincian bukti transfer: Penerima, Waktu, Catatan, Otorisasi (dan No. referensi di detail).
/// Dipakai layar Berhasil dan Detail Transaksi.
struct RincianTransfer: View {
    let bukti: BuktiTransfer
    var tampilkanReferensi = false

    var body: some View {
        Kartu {
            VStack(spacing: Space.m) {
                BarisRincian(label: "Penerima",
                             nilai: "\(bukti.permintaan.tujuan.nomor) – \(bukti.permintaan.tujuan.nama)")
                BarisRincian(label: "Waktu", nilai: FormatWaktu.lengkap(bukti.waktu))
                if !bukti.permintaan.catatan.isEmpty {
                    BarisRincian(label: "Catatan", nilai: bukti.permintaan.catatan)
                }
                BarisRincian(label: "Otorisasi", nilai: bukti.metode.keterangan,
                             warna: bukti.metode == .passkey ? Warna.sukses : Warna.teks)
                if tampilkanReferensi {
                    BarisRincian(label: "No. referensi", nilai: bukti.permintaan.referensi)
                }
            }
        }
    }
}

#Preview("Rincian") {
    VStack(spacing: Space.m) {
        RincianTransfer(bukti: DataTransfer.buktiPasskey)
        RincianTransfer(bukti: DataTransfer.buktiPIN, tampilkanReferensi: true)
    }
    .padding()
}
