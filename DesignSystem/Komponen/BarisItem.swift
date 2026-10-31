import SwiftUI

/// Baris daftar umum: ikon, judul, keterangan, nominal, tanda pilih. Dibaca VoiceOver sebagai satu elemen.
/// `BarisItem(ikon: "bolt", judul: "Tagihan listrik", keterangan: "Jatuh tempo 5 Nov", nominal: 350_000)`
struct BarisItem: View {
    var ikon: String? = nil
    let judul: String
    var keterangan: String? = nil
    var nominal: Int? = nil
    var terpilih: Bool? = nil
    @Environment(\.dynamicTypeSize) private var ukuranTeks

    var body: some View {
        HStack(spacing: Space.m) {
            if let ikon {
                Image(systemName: ikon)
                    .font(Teks.isi)
                    .foregroundStyle(Warna.utama)
                    .frame(width: Ukuran.ikon, height: Ukuran.ikon)
                    .background(Warna.latar, in: .rect(cornerRadius: Radius.s))
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: Space.xs) {
                Text(judul).font(Teks.isiTebal).foregroundStyle(Warna.teks)
                if let keterangan {
                    Text(keterangan).font(Teks.keterangan).foregroundStyle(Warna.teksSekunder)
                }
                // Teks besar: nominal turun ke bawah judul supaya tidak terpotong.
                if ukuranTeks.isAccessibilitySize, let nominal { teksNominal(nominal) }
            }
            Spacer(minLength: Space.s)
            // Ukuran biasa: nominal tidak pernah patah baris; judul dan keterangan yang menyesuaikan.
            if !ukuranTeks.isAccessibilitySize, let nominal {
                teksNominal(nominal)
                    .fixedSize(horizontal: true, vertical: false)
            }
            if let terpilih {
                Image(systemName: terpilih ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(terpilih ? Warna.utama : Warna.garis)
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: Ukuran.sentuhMinimal)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(terpilih == true ? .isSelected : [])
    }

    /// Nominal selalu satu baris. Pada teks besar boleh mengecil sampai separuh, supaya angka tidak terpotong "…".
    private func teksNominal(_ nilai: Int) -> some View {
        Text(Rupiah.format(nilai))
            .font(Teks.isiTebal)
            .foregroundStyle(Warna.teks)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(ukuranTeks.isAccessibilitySize ? 0.5 : 1)
    }
}

/// Wadah kartu putih di atas latar abu.
struct Kartu<Isi: View>: View {
    @ViewBuilder let isi: Isi

    var body: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            isi
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Space.m)
        .background(Warna.permukaan, in: .rect(cornerRadius: Radius.l))
    }
}

#Preview("Baris") {
    VStack(spacing: Space.m) {
        Kartu {
            BarisItem(ikon: "bolt", judul: "Tagihan listrik", keterangan: "Jatuh tempo 5 Nov", nominal: 350_000)
            BarisItem(ikon: "person", judul: "Budi Contoh", keterangan: "Transfer masuk", nominal: 125_000, terpilih: true)
            BarisItem(ikon: "arrow.up.right", judul: "Ayu Contoh", keterangan: "15.08 · PIN", nominal: -20_000_000)
            BarisItem(judul: "Tanpa ikon", keterangan: "Keterangan singkat", terpilih: false)
        }
    }
    .padding()
    .background(Warna.latar)
}

#Preview("Teks besar") {
    Kartu {
        BarisItem(ikon: "arrow.up.right", judul: "Ayu Contoh", keterangan: "15.08 · PIN", nominal: -20_000_000)
    }
    .padding()
    .dynamicTypeSize(.accessibility3)
}
