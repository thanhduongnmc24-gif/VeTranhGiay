import UIKit

final class LuuMauTuyChon {
    static let dungChung = LuuMauTuyChon()

    private let khoaLuu = "bay-mau-tuy-chon"

    private init() {}

    func docDanhSach() -> [UIColor?] {
        guard let danhSachMaMau = UserDefaults.standard.array(
            forKey: khoaLuu
        ) as? [String] else {
            return Array(repeating: nil, count: 7)
        }

        var ketQua: [UIColor?] = danhSachMaMau
            .prefix(7)
            .map { maMau in
                if maMau.isEmpty {
                    return nil
                }

                return UIColor(maHex: maMau)
            }

        while ketQua.count < 7 {
            ketQua.append(nil)
        }

        return ketQua
    }

    func luuDanhSach(_ danhSach: [UIColor?]) {
        var danhSachMaMau = danhSach
            .prefix(7)
            .map { mau in
                mau?.maHex ?? ""
            }

        while danhSachMaMau.count < 7 {
            danhSachMaMau.append("")
        }

        UserDefaults.standard.set(
            danhSachMaMau,
            forKey: khoaLuu
        )
    }
}

extension UIColor {
    convenience init?(maHex: String) {
        var maMau = maHex.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if maMau.hasPrefix("#") {
            maMau.removeFirst()
        }

        guard maMau.count == 8,
              let giaTri = UInt64(maMau, radix: 16) else {
            return nil
        }

        let thanhPhanDo = CGFloat(
            (giaTri >> 24) & 255
        ) / 255.0

        let thanhPhanLuc = CGFloat(
            (giaTri >> 16) & 255
        ) / 255.0

        let thanhPhanLam = CGFloat(
            (giaTri >> 8) & 255
        ) / 255.0

        let thanhPhanTrongSuot = CGFloat(
            giaTri & 255
        ) / 255.0

        self.init(
            red: thanhPhanDo,
            green: thanhPhanLuc,
            blue: thanhPhanLam,
            alpha: thanhPhanTrongSuot
        )
    }

    var maHex: String? {
        guard let mauChuyenDoi = cgColor.converted(
            to: CGColorSpaceCreateDeviceRGB(),
            intent: .defaultIntent,
            options: nil
        ),
        let thanhPhan = mauChuyenDoi.components,
        thanhPhan.count >= 4 else {
            return nil
        }

        let thanhPhanDo = Int(
            round(thanhPhan[0] * 255)
        )

        let thanhPhanLuc = Int(
            round(thanhPhan[1] * 255)
        )

        let thanhPhanLam = Int(
      