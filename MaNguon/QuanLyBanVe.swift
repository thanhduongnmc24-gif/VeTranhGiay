import Foundation
import PencilKit

final class QuanLyBanVe {
    static let dungChung = QuanLyBanVe()
    private init() {}

    private var duongDan: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("ban-ve-hien-tai.data")
    }

    func luuBanVe(_ banVe: PKDrawing) {
        guard let duongDan else { return }
        do {
            try banVe.dataRepresentation().write(to: duongDan, options: .atomic)
        } catch {
            print("Không lưu được bản vẽ: \(error.localizedDescription)")
        }
    }

    func docBanVe() -> PKDrawing? {
        guard let duongDan,
              let duLieu = try? Data(contentsOf: duongDan) else { return nil }
        return try? PKDrawing(data: duLieu)
    }

    func xoaBanVeDaLuu() {
        guard let duongDan else { return }
        try? FileManager.default.removeItem(at: duongDan)
    }
}
