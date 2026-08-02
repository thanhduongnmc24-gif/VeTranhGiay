import UIKit

final class LuuMauTuyChon {
    static let dungChung = LuuMauTuyChon()
    private let khoaLuu = "bay-mau-tuy-chon"
    private init() {}

    func docDanhSach() -> [UIColor?] {
        guard let danhSachMa = UserDefaults.standard.array(forKey: khoaLuu) as? [String] else {
            return Array(repeating: nil, count: 7)
        }
        var ketQua = danhSachMa.prefix(7).map { ma -> UIColor? in
            ma.isEmpty ? nil : UIColor(maHex: ma)
        }
        while ketQua.count < 7 { ketQua.append(nil) }
        return ketQua
    }

    func luuDanhSach(_ danhSach: [UIColor?]) {
        let danhSachMa = danhSach.prefix(7).map { $0?.maHex ?? "" }
        UserDefaults.standard.set(danhSachMa, forKey: khoaLuu)
    }
}

extension UIColor {
    convenience init?(maHex: String) {
        var ma = maHex.trimmingCharacters(in: .whitespacesAndNewlines)
        if ma.hasPrefix("#") { ma.removeFirst() }
        guard ma.count == 8, let giaTri = UInt64(ma, radix: 16) else { return nil }
        let do = CGFloat((giaTri >> 24) & 255) / 255
        let luc = CGFloat((giaTri >> 16) & 255) / 255
        let lam = CGFloat((giaTri >> 8) & 255) / 255
        let trong = CGFloat(giaTri & 255) / 255
        self.init(red: do, green: luc, blue: lam, alpha: trong)
    }

    var maHex: String? {
        guard let thanhPhan = cgColor.converted(
            to: CGColorSpaceCreateDeviceRGB(),
            intent: .defaultIntent,
            options: nil
        )?.components, thanhPhan.count >= 4 else { return nil }
        return String(
            format: "#%02X%02X%02X%02X",
            Int(thanhPhan[0] * 255), Int(thanhPhan[1] * 255),
            Int(thanhPhan[2] * 255), Int(thanhPhan[3] * 255)
        )
    }
}
