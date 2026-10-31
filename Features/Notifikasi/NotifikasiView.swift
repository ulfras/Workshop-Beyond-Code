import SwiftUI

/// Layar 7 · Notifikasi (tidak ada di prototype; dibangun dari DESIGN.md). Dibuka dari lonceng di Beranda.
struct NotifikasiView: View {
    @State private var model: NotifikasiModel

    init(model: NotifikasiModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        konten
            .background(Warna.latar)
            .navigationTitle("Notifikasi")
            .navigationBarTitleDisplayMode(.inline)
            .task { await model.muncul() }
    }

    @ViewBuilder
    private var konten: some View {
        switch model.status {
        case .memuat:
            BarisMemuat()
        case .kosong:
            KeadaanKosong(ikon: "bell.slash", judul: "Belum ada notifikasi",
                          pesan: "Peringatan keamanan dan bukti transfer akan muncul di sini.")
        case .gagal(let pesan):
            KeadaanGagal(pesan: pesan) { Task { await model.muat() } }
        case .berhasil(let daftar):
            List(daftar) { notifikasi in
                Group {
                    if let bukti = notifikasi.bukti {
                        NavigationLink(value: Rute.detailTransaksi(bukti)) {
                            BarisNotifikasi(notifikasi: notifikasi)
                        }
                    } else {
                        BarisNotifikasi(notifikasi: notifikasi)
                    }
                }
                .listRowBackground(Warna.permukaan)
            }
            .scrollContentBackground(.hidden)
            .refreshable { await model.muat(tampilkanMemuat: false) }
        }
    }
}

/// Satu notifikasi: ikon jenis, judul, pesan, waktu, dan titik "belum dibaca". Dibaca VoiceOver sebagai satu elemen.
private struct BarisNotifikasi: View {
    let notifikasi: Notifikasi
    @ScaledMetric(relativeTo: .body) private var ukuranTitik: CGFloat = 8

    var body: some View {
        HStack(alignment: .top, spacing: Space.m) {
            Image(systemName: ikon)
                .font(Teks.judul)
                .foregroundStyle(warna)
                .frame(width: Ukuran.ikon)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Space.xs) {
                Text(notifikasi.judul)
                    .font(Teks.isiTebal)
                    .foregroundStyle(Warna.teks)
                Text(notifikasi.pesan)
                    .font(Teks.keterangan)
                    .foregroundStyle(Warna.teksSekunder)
                Text(FormatWaktu.lengkap(notifikasi.waktu))
                    .font(Teks.label)
                    .foregroundStyle(Warna.teksSekunder)
            }
            Spacer(minLength: 0)
            if !notifikasi.dibaca {
                Circle()
                    .fill(Warna.utama)
                    .frame(width: ukuranTitik, height: ukuranTitik)
                    .padding(.top, Space.s)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, Space.xs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(labelVoiceOver)
    }

    private var labelVoiceOver: String {
        let isi = "\(notifikasi.judul). \(notifikasi.pesan) \(FormatWaktu.lengkap(notifikasi.waktu))"
        return notifikasi.dibaca ? isi : "Belum dibaca. \(isi)"
    }

    private var ikon: String {
        switch notifikasi.jenis {
        case .berhasil: "checkmark.circle.fill"
        case .peringatan: "exclamationmark.shield.fill"
        case .dibatalkan: "xmark.shield.fill"
        }
    }

    private var warna: Color {
        switch notifikasi.jenis {
        case .berhasil: Warna.sukses
        case .peringatan: Warna.aksen
        case .dibatalkan: Warna.gagal
        }
    }
}

#Preview("Berhasil") {
    NavigationStack { NotifikasiView(model: .contoh) }
}

#Preview("Memuat") {
    NavigationStack { NotifikasiView(model: .memuat) }
}

#Preview("Kosong") {
    NavigationStack { NotifikasiView(model: .kosong) }
}

#Preview("Gagal") {
    NavigationStack { NotifikasiView(model: .gagal) }
}

#Preview("Teks besar") {
    NavigationStack { NotifikasiView(model: .contoh) }
        .dynamicTypeSize(.accessibility3)
}
