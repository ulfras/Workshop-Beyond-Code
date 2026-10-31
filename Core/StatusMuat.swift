/// Empat state yang wajib ada di setiap layar (lihat AGENTS.md > State).
enum StatusMuat<Nilai> {
    case memuat
    case berhasil(Nilai)
    case kosong
    case gagal(String)
}

extension StatusMuat: Equatable where Nilai: Equatable {}
