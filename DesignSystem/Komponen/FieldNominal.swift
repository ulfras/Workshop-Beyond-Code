import SwiftUI

/// Field nominal rupiah: "Rp" lalu angka besar dengan titik ribuan. Dipakai Transfer dan Top Up.
/// Aturan ketikan (titik ribuan langsung, maksimal 12 digit, hanya angka) ada di `ValidasiTransfer.rapikan`;
/// pemanggil menerapkannya di `ubah`, misalnya `{ lama, baru in model.ubahNominal(baru, sebelumnya: lama) }`.
///
/// Dibind langsung ke teks di model lalu dirapikan di `onChange`. Dengan binding get/set biasa, ketikan yang
/// ditolak (huruf, digit ke-13) tetap terlihat karena nilai di model tidak berubah sehingga field tidak digambar ulang.
struct FieldNominal: View {
    @Binding var teks: String
    let labelAksesibilitas: String
    var fokus: FocusState<Bool>.Binding
    let ubah: (_ lama: String, _ baru: String) -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.s) {
            Text("Rp")
                .font(Teks.judul)
                .foregroundStyle(Warna.teksSekunder)
                .accessibilityHidden(true)
            TextField("0", text: $teks)
                .onChange(of: teks) { lama, baru in ubah(lama, baru) }
                .font(Teks.nominal)
                .foregroundStyle(Warna.teks)
                .keyboardType(.numberPad)
                .monospacedDigit()
                .focused(fokus)
                .accessibilityLabel(labelAksesibilitas)
        }
        .padding(Space.m)
        .background(Warna.permukaan, in: .rect(cornerRadius: Radius.l))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.l)
                .strokeBorder(fokus.wrappedValue ? Warna.utama : Color.clear, lineWidth: 2)
        }
        .contentShape(.rect)
        .onTapGesture { fokus.wrappedValue = true }
    }
}

/// Baris chip nominal cepat. Selalu satu baris; pada teks besar bisa digeser ke samping supaya nominal tidak terpotong.
/// `PilihanNominal(pilihan: [1_000_000, 10_000_000], terpilih: model.nominal) { model.pilihNominal($0) }`
struct PilihanNominal: View {
    let pilihan: [Int]
    let terpilih: Int?
    let pilih: (Int) -> Void
    @Environment(\.dynamicTypeSize) private var ukuranTeks

    var body: some View {
        if ukuranTeks.isAccessibilitySize {
            ScrollView(.horizontal, showsIndicators: false) { baris }
        } else {
            baris
        }
    }

    private var baris: some View {
        HStack(spacing: Space.s) {
            ForEach(pilihan, id: \.self) { nilai in
                ChipNominal(nilai: nilai, terpilih: terpilih == nilai) { pilih(nilai) }
            }
        }
    }
}

/// Chip nominal cepat. Teks `Warna.utama` di atas `Warna.utama.opacity(…)` (DESIGN.md › Colors).
private struct ChipNominal: View {
    let nilai: Int
    let terpilih: Bool
    let aksi: () -> Void

    @Environment(\.dynamicTypeSize) private var ukuranTeks

    var body: some View {
        Button(action: aksi) {
            Text(Rupiah.format(nilai))
                .font(Teks.label)
                .foregroundStyle(Warna.utama)
                .monospacedDigit()
                .lineLimit(1)
                // Layar sempit (iPhone SE): teks boleh mengecil sedikit supaya tetap satu baris.
                .minimumScaleFactor(ukuranTeks.isAccessibilitySize ? 1 : 0.8)
                .padding(.horizontal, Space.s)
                .frame(maxWidth: ukuranTeks.isAccessibilitySize ? nil : .infinity, minHeight: Ukuran.sentuhMinimal)
                .background(Warna.utama.opacity(terpilih ? 0.2 : 0.1), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(terpilih ? .isSelected : [])
    }
}

private struct PratinjauFieldNominal: View {
    @State private var teks = "7.500.000"
    @FocusState private var fokus: Bool

    var body: some View {
        VStack(spacing: Space.m) {
            FieldNominal(teks: $teks, labelAksesibilitas: "Nominal", fokus: $fokus) { lama, baru in
                teks = ValidasiTransfer.rapikan(ketikan: baru, sebelumnya: lama)
            }
            PilihanNominal(pilihan: [1_000_000, 10_000_000, 75_000_000],
                           terpilih: ValidasiTransfer.nominal(dariKetikan: teks)) { teks = Rupiah.angka($0) }
        }
        .padding()
    }
}

#Preview("Field nominal") {
    PratinjauFieldNominal()
}

#Preview("Teks besar") {
    PratinjauFieldNominal()
        .dynamicTypeSize(.accessibility3)
}
