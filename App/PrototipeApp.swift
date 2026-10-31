import SwiftUI

@main
struct PrototipeApp: App {
    @State private var navigasi = Navigasi()
    /// Data dummy secara default. Supabase hanya kalau diaktifkan di Config/ (docs/supabase-opsional.md).
    private let layanan = SumberData.layanan()
    /// Face ID / Touch ID asli. Preview dan test memakai `BiometrikDummy`.
    private let biometrik: any Biometrik = BiometrikPerangkat()
    /// Simulasi passkey (Services/Passkey.swift).
    private let penandatangan: any Penandatangan = PenandatanganPerangkat()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigasi.path) {
                // Layar pertama dari docs/userflow.md.
                BerandaView(model: BerandaModel(layanan: layanan, navigasi: navigasi))
                    .navigationDestination(for: Rute.self) { rute in
                        tujuan(rute)
                    }
            }
            .tint(Warna.utama)
            #if DEBUG
            .onAppear { navigasi.path = DemoFlags.ruteAwal() }
            #endif
        }
    }

    /// Satu `case` per layar di docs/userflow.md.
    @ViewBuilder
    private func tujuan(_ rute: Rute) -> some View {
        switch rute {
        case .pilihRekening:
            PilihRekeningView(model: PilihRekeningModel(layanan: layanan, navigasi: navigasi))
        case .transfer(let tujuan, let saldo):
            TransferView(model: TransferModel(tujuan: tujuan, saldo: saldo, layanan: layanan, navigasi: navigasi))
        case .pin(let permintaan, let perluPasskey):
            PINView(model: PINModel(permintaan: permintaan, perluPasskey: perluPasskey,
                                    layanan: layanan, navigasi: navigasi))
        case .verifikasi(let permintaan):
            VerifikasiView(model: VerifikasiModel(permintaan: permintaan, layanan: layanan, biometrik: biometrik,
                                                  penandatangan: penandatangan, navigasi: navigasi))
        case .berhasil(let bukti):
            BerhasilView(bukti: bukti) { navigasi.kembaliKeAwal() }
        case .riwayat:
            RiwayatView(model: RiwayatModel(layanan: layanan))
        case .notifikasi:
            NotifikasiView(model: NotifikasiModel(layanan: layanan))
        case .detailTransaksi(let bukti):
            DetailTransaksiView(bukti: bukti)
        case .topUp:
            TopUpView(model: TopUpModel(layanan: layanan, navigasi: navigasi))
        case .belumDibangun(let fitur):
            BelumDibangun(layar: fitur, task: "T9")
        case .detailContoh(let item):
            BelumDibangun(layar: item.judul, task: "task berikutnya")
        }
    }
}
