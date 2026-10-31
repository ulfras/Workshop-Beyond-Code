import SwiftUI

/// State kosong: apa yang terjadi dan apa yang bisa dilakukan.
struct KeadaanKosong: View {
    let ikon: String
    let judul: String
    let pesan: String
    var tombol: String? = nil
    var aksi: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label(judul, systemImage: ikon)
        } description: {
            Text(pesan)
        } actions: {
            if let tombol, let aksi {
                Button(tombol, action: aksi)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// State gagal: apa yang terjadi, kenapa, dan satu tombol (default "Coba lagi").
/// Untuk proses yang dihentikan demi keamanan: `tombol: "Kembali ke Beranda"`.
struct KeadaanGagal: View {
    var judul: String = "Belum bisa dimuat"
    let pesan: String
    var tombol: String = "Coba lagi"
    let cobaLagi: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(judul, systemImage: "exclamationmark.triangle")
        } description: {
            Text(pesan)
        } actions: {
            Button(action: cobaLagi) {
                Text(tombol).foregroundStyle(Warna.utamaTeks)   // mode gelap: utama biru muda, teks biru tua
            }
            .buttonStyle(.borderedProminent)
            .tint(Warna.utama)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Proses singkat yang sedang berjalan: "Memeriksa PIN…", "Memproses transfer…". Diumumkan VoiceOver.
struct KeadaanMemproses: View {
    let pesan: String

    var body: some View {
        HStack(spacing: Space.s) {
            ProgressView()
            Text(pesan)
                .font(Teks.keterangan)
                .foregroundStyle(Warna.teksSekunder)
        }
        .frame(minHeight: Ukuran.sentuhMinimal)
        .accessibilityElement(children: .combine)
        .onAppear { AccessibilityNotification.Announcement(pesan).post() }
    }
}

/// State memuat: baris placeholder dengan bentuk yang sama seperti isi aslinya.
struct BarisMemuat: View {
    var jumlah: Int = 5

    var body: some View {
        VStack(spacing: Space.m) {
            ForEach(0..<jumlah, id: \.self) { _ in
                BarisItem(ikon: "circle", judul: "Judul baris", keterangan: "Keterangan singkat", nominal: 100_000)
            }
            Spacer(minLength: 0)
        }
        .padding(Space.m)
        .redacted(reason: .placeholder)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Memuat")
    }
}

/// Penanda layar yang belum dibangun. Dipakai sampai task-nya selesai.
struct BelumDibangun: View {
    let layar: String
    let task: String

    var body: some View {
        KeadaanKosong(ikon: "hammer", judul: layar, pesan: "Layar ini belum dibangun. Lihat \(task) di docs/tasks.md.")
            .navigationTitle(layar)
    }
}

#Preview("Kosong") {
    KeadaanKosong(ikon: "tray", judul: "Belum ada data", pesan: "Data contoh akan muncul di sini.")
}

#Preview("Gagal") {
    KeadaanGagal(pesan: "Data belum bisa dimuat. Periksa koneksi, lalu coba lagi.") {}
}

#Preview("Memuat") {
    BarisMemuat()
}

#Preview("Memproses") {
    KeadaanMemproses(pesan: "Memeriksa keamanan transaksi…")
}

#Preview("Gagal, tombol lain") {
    KeadaanGagal(judul: "Transfer dibatalkan", pesan: "PIN salah 3 kali. Demi keamanan, transfer ini dibatalkan.",
                 tombol: "Kembali ke Beranda") {}
}
