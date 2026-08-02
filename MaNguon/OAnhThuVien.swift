import UIKit

final class OAnhThuVien: UICollectionViewCell {
    static let maTaiSuDung = "OAnhThuVien"
    let anh = UIImageView()
    let nhanNgay = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor

        anh.contentMode = .scaleAspectFit
        anh.backgroundColor = MauSac.mauGiay
        anh.translatesAutoresizingMaskIntoConstraints = false
        nhanNgay.font = .systemFont(ofSize: 11, weight: .medium)
        nhanNgay.textColor = .secondaryLabel
        nhanNgay.textAlignment = .center
        nhanNgay.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(anh)
        contentView.addSubview(nhanNgay)
        NSLayoutConstraint.activate([
            anh.topAnchor.constraint(equalTo: contentView.topAnchor),
            anh.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            anh.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            anh.bottomAnchor.constraint(equalTo: nhanNgay.topAnchor),
            nhanNgay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nhanNgay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nhanNgay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            nhanNgay.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    required init?(coder: NSCoder) { fatalError("Không hỗ trợ coder") }
}
