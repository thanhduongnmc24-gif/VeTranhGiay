import Foundation
import UIKit
import PencilKit

final class QuanLyThuVien {
    static let dungChung = QuanLyThuVien()
    private let quanLyTep = FileManager.default
    private init() { taoThuMucNeuCan() }

    private var thuMucGoc: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ThuVienTranh", isDirectory: true)
    }

    private func taoThuMucNeuCan() {
        try? quanLyTep.createDirectory(at: thuMucGoc, withIntermediateDirectories: true)
    }

    private func thuMucBanVe(_ ma: String) -> URL {
        thuMucGoc.appendingPathComponent(ma, isDirectory: true)
    }

    func luuBanVe(
        maBanVe: String?,
        banVeThuong: PKDrawing,
        banVeTrenCung: PKDrawing,
        anhXemTruoc: UIImage
    ) throws -> String {
        taoThuMucNeuCan()
        let ma = maBanVe ?? "tranh-\(Int(Date().timeIntervalSince1970 * 1000))"
        let thuMuc = thuMucBanVe(ma)
        try quanLyTep.createDirectory(at: thuMuc, withIntermediateDirectories: true)
        try banVeThuong.dataRepresentation().write(to: thuMuc.appendingPathComponent("net-thuong.data"), options: .atomic)
        try banVeTrenCung.dataRepresentation().write(to: thuMuc.appendingPathComponent("net-tren-cung.data"), options: .atomic)
        guard let duLieuAnh = anhXemTruoc.pngData() else {
            throw NSError(domain: "VeTranhGiay", code: 10, userInfo: [NSLocalizedDescriptionKey: "Không tạo được ảnh PNG."])
        }
        try duLieuAnh.write(to: thuMuc.appendingPathComponent("anh.png"), options: .atomic)
        let thongTin: [String: Any] = ["maBanVe": ma, "ngayTao": Date().timeIntervalSince1970]
        let duLieuThongTin = try JSONSerialization.data(withJSONObject: thongTin, options: .prettyPrinted)
        try duLieuThongTin.write(to: thuMuc.appendingPathComponent("thong-tin.json"), options: .atomic)
        return ma
    }

    func docTatCa() -> [MauBanVe] {
        taoThuMucNeuCan()
        let danhSach = (try? quanLyTep.contentsOfDirectory(
            at: thuMucGoc,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []
        return danhSach.compactMap { docBanVe(maBanVe: $0.lastPathComponent) }
            .sorted { $0.ngayTao > $1.ngayTao }
    }

    func docBanVe(maBanVe: String) -> MauBanVe? {
        let thuMuc = thuMucBanVe(maBanVe)
        guard let duLieuAnh = try? Data(contentsOf: thuMuc.appendingPathComponent("anh.png")),
              let anh = UIImage(data: duLieuAnh),
              let duLieuThuong = try? Data(contentsOf: thuMuc.appendingPathComponent("net-thuong.data")),
              let duLieuTren = try? Data(contentsOf: thuMuc.appendingPathComponent("net-tren-cung.data")),
              let banVeThuong = try? PKDrawing(data: duLieuThuong),
              let banVeTren = try? PKDrawing(data: duLieuTren) else { return nil }
        var ngay = Date.distantPast
        if let duLieu = try? Data(contentsOf: thuMuc.appendingPathComponent("thong-tin.json")),
           let json = try? JSONSerialization.jsonObject(with: duLieu) as? [String: Any],
           let moc = json["ngayTao"] as? TimeInterval {
            ngay = Date(timeIntervalSince1970: moc)
        }
        return MauBanVe(maBanVe: maBanVe, ngayTao: ngay, anhXemTruoc: anh, banVeThuong: banVeThuong, banVeTrenCung: banVeTren)
    }

    func xoaBanVe(maBanVe: String) throws {
        try quanLyTep.removeItem(at: thuMucBanVe(maBanVe))
    }
}
