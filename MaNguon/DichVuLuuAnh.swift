import UIKit
import Photos

final class DichVuLuuAnh {
    func luu(_ anh: UIImage, hoanTat: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { trangThai in
            guard trangThai == .authorized || trangThai == .limited else {
                let loi = NSError(
                    domain: "VeTranhGiay",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Chưa có quyền lưu ảnh vào album."]
                )
                DispatchQueue.main.async { hoanTat(.failure(loi)) }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: anh)
            } completionHandler: { thanhCong, loi in
                DispatchQueue.main.async {
                    if let loi {
                        hoanTat(.failure(loi))
                    } else if thanhCong {
                        hoanTat(.success(()))
                    } else {
                        let loiKhongRo = NSError(
                            domain: "VeTranhGiay",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "Không thể lưu ảnh."]
                        )
                        hoanTat(.failure(loiKhongRo))
                    }
                }
            }
        }
    }
}
