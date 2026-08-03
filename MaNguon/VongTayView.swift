import UIKit

final class VongTayView: UIView {
    var tamVongTay: CGPoint?
    var banKinhVongTay: CGFloat = 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("Không hỗ trợ coder")
    }

    func hienVongTay(tai viTri: CGPoint, banKinh: CGFloat) {
        tamVongTay = viTri
        banKinhVongTay = banKinh
        setNeedsDisplay()
    }

    func anVongTay() {
        tamVongTay = nil
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let tamVongTay else { return }

        let duongKinh = banKinhVongTay * 2
        let khungVongTay = CGRect(
            x: tamVongTay.x - banKinhVongTay,
            y: tamVongTay.y - banKinhVongTay,
            width: duongKinh,
            height: duongKinh
        )

        guard let boCanh = UIGraphicsGetCurrentContext() else { return }

        boCanh.saveGState()
        boCanh.setFillColor(UIColor.white.withAlphaComponent(0.22).cgColor)
        boCanh.fillEllipse(in: khungVongTay)
        boCanh.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.95).cgColor)
        boCanh.setLineWidth(2)
        boCanh.strokeEllipse(in: khungVongTay.insetBy(dx: 1, dy: 1))
        boCanh.restoreGState()
    }
}
