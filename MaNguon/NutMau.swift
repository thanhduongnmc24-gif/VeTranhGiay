import UIKit

final class NutMau: UIButton {
    var mau: UIColor?
    var viTriTuyChon: Int?

    init(mau: UIColor?, viTriTuyChon: Int? = nil) {
        self.mau = mau
        self.viTriTuyChon = viTriTuyChon
        super.init(frame: .zero)
        layer.cornerRadius = 13
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 1.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 26).isActive = true
        heightAnchor.constraint(equalToConstant: 26).isActive = true
        capNhatMau(mau)
    }

    required init?(coder: NSCoder) { fatalError("Không hỗ trợ coder") }

    func capNhatMau(_ mauMoi: UIColor?) {
        mau = mauMoi
        backgroundColor = mauMoi ?? UIColor.tertiarySystemFill
        setTitle(mauMoi == nil ? "+" : "", for: .normal)
        setTitleColor(MauSac.mauNau, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        accessibilityLabel = mauMoi == nil ? "Thêm màu tùy chọn" : "Chọn màu"
    }

    func datDangChon(_ dangChon: Bool) {
        layer.borderColor = dangChon ? UIColor.systemBlue.cgColor : UIColor.white.cgColor
        layer.borderWidth = dangChon ? 3.5 : 1.5
        transform = dangChon ? CGAffineTransform(scaleX: 1.14, y: 1.14) : .identity
    }
}
