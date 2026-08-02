import UIKit

final class NutMau: UIButton {
    let mau: UIColor

    init(mau: UIColor) {
        self.mau = mau
        super.init(frame: .zero)
        backgroundColor = mau
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.14
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 32).isActive = true
        heightAnchor.constraint(equalToConstant: 32).isActive = true
        accessibilityLabel = "Chon mau"
    }

    required init?(coder: NSCoder) {
        fatalError("Khong ho tro khoi tao bang coder")
    }

    func datDangChon(_ dangChon: Bool) {
        layer.borderColor = dangChon ? MauSac.mauNau.cgColor : UIColor.white.cgColor
        layer.borderWidth = dangChon ? 4 : 2
        transform = dangChon ? CGAffineTransform(scaleX: 1.12, y: 1.12) : .identity
    }
}
