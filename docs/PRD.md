# PRD Early detect transaction sang Fraud Detection Rule

## Masalah
Ketika nasabah melakukan transaksi yang tidak wajar, saya ingin sistem otomatis menaikkan verifikasi keamanan, agar nasabah terlindungi dari penipuan tanpa mengganggu transaksi hariannya.

## Feature scope (MoSCoW)
- Must: Form input + validasi nominal/saldo, FDS evaluasi rule (nominal, lokasi/device, velocity, jam), Signed proof ke server, Backend verifikasi signature, Tampilkan bukti transaksi
- Should: Risk badge + alasan, Rule FDS bisa di-update tanpa deploy ulang, Validasi passkey configurable, Menampilkan Customer Concern
- Could: Daftar tersimpan, Riwayat transaksi, Diimplementasi di seluruh transaksi
- Won't: Melalui wearable (jangan dibuat)

## Asumsi
| Asumsi | Kalau salah, gagal? | Sudah terbukti? | Keputusan |
|---|---|---|---|
| Apakah membutuhkan perjagaan keamanan bertape | TODO | Sudah, ditelponin IBO | Aman |
| Apakan Butuh kaldes mout nomiman said | Ya | Sudah | Aman |
| Apakah POS sa mandeneks anys ammal tra | Ya | Gilch | Aman |
| Apakah membutuhkan bage | TODO | Belum terbuk | U Dau |

## Kriteria sukses
1. ≥ 90% transaksi berisiko tinggi (uji skenario) terdeteksi & memicu step-up Passkey, dengan false-positive ≤ 10% pada transaksi normal.
2. Transaksi normal (Low risk) selesai ≤ 15 detik tanpa friksi tambahan, dan step-up selesai ≤ 30 detik — diukur pada 5–8 peserta usability test.