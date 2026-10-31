/// Data dummy. Nama dan nominal contoh, bukan data nasabah.
/// Ganti dengan data dummy untuk produk kalian (lihat AGENTS.md > Data).
enum DataContoh {
    static let item: [ItemContoh] = [
        ItemContoh(id: "ITM-01", judul: "Budi Contoh", keterangan: "Transfer masuk · Hari ini", nominal: 125_000, ikon: "arrow.down.circle"),
        ItemContoh(id: "ITM-02", judul: "Tagihan listrik", keterangan: "Jatuh tempo 5 Nov", nominal: 350_000, ikon: "bolt"),
        ItemContoh(id: "ITM-03", judul: "Ngopi sore", keterangan: "Kedai Kopi Senja · Kemarin", nominal: 86_000, ikon: "cup.and.saucer")
    ]
}
