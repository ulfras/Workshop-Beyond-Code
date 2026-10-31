/// Sapaan di Beranda menurut jam perangkat.
enum Sapaan {
    static func untuk(jam: Int) -> String {
        switch jam {
        case 4..<11: "Selamat pagi,"
        case 11..<15: "Selamat siang,"
        case 15..<18: "Selamat sore,"
        default: "Selamat malam,"
        }
    }
}
