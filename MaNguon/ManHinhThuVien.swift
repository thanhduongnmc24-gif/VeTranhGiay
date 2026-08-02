import UIKit

final class ManHinhThuVien: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var danhSach: [MauBanVe] = []
    private let khiChon: (MauBanVe) -> Void
    private lazy var luoiAnh: UICollectionView = {
        let boCuc = UICollectionViewFlowLayout()
        boCuc.minimumInteritemSpacing = 12
        boCuc.minimumLineSpacing = 12
        boCuc.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let luoi = UICollectionView(frame: .zero, collectionViewLayout: boCuc)
        luoi.backgroundColor = MauSac.mauNen
        luoi.dataSource = self
        luoi.delegate = self
        luoi.register(OAnhThuVien.self, forCellWithReuseIdentifier: OAnhThuVien.maTaiSuDung)
        return luoi
    }()

    init(khiChon: @escaping (MauBanVe) -> Void) {
        self.khiChon = khiChon
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("Khong ho tro coder") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Thu vien tranh"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) })
        luoiAnh.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(luoiAnh)
        NSLayoutConstraint.activate([
            luoiAnh.topAnchor.constraint(equalTo: view.topAnchor), luoiAnh.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            luoiAnh.leadingAnchor.constraint(equalTo: view.leadingAnchor), luoiAnh.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        napDanhSach()
    }

    private func napDanhSach() {
        danhSach = QuanLyThuVien.dungChung.docTatCa()
        luoiAnh.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { danhSach.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let o = collectionView.dequeueReusableCell(withReuseIdentifier: OAnhThuVien.maTaiSuDung, for: indexPath) as! OAnhThuVien
        let banVe = danhSach[indexPath.item]
        o.anh.image = banVe.anhXemTruoc
        o.nhanNgay.text = DateFormatter.localizedString(from: banVe.ngayTao, dateStyle: .short, timeStyle: .short)
        return o
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let banVe = danhSach[indexPath.item]
        dismiss(animated: true) { [khiChon] in khiChon(banVe) }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let banVe = danhSach[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            UIMenu(children: [
                UIAction(title: "Mo va ve tiep", image: UIImage(systemName: "pencil")) { _ in
                    self?.dismiss(animated: true) { [khiChon = self?.khiChon] in khiChon?(banVe) }
                },
                UIAction(title: "Xoa", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    try? QuanLyThuVien.dungChung.xoaBanVe(maBanVe: banVe.maBanVe)
                    self?.napDanhSach()
                }
            ])
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let soCot: CGFloat = view.bounds.width > 700 ? 4 : 3
        let tongKhoang: CGFloat = 24 + (soCot - 1) * 12
        let rong = floor((view.bounds.width - tongKhoang) / soCot)
        return CGSize(width: rong, height: rong * 1.05)
    }
}
