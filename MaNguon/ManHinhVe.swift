import UIKit
import PencilKit

final class ManHinhVe: UIViewController, PKCanvasViewDelegate, UIColorPickerViewControllerDelegate {
    private let khungVe = PKCanvasView()
    private let thanhCongCu = UIStackView()
    private let thanhMau = UIScrollView()
    private let hangMau = UIStackView()
    private let thanhDoDay = UISlider()
    private let nhanDoDay = UILabel()
    private let nhanCheDoBut = UILabel()
    private let chuyenCheDoBut = UISwitch()
    private let dichVuLuuAnh = DichVuLuuAnh()

    private var mauDangChon = UIColor.black
    private var loaiButDangChon: PKInkingTool.InkType = .pencil
    private var doDayNet: CGFloat = 5
    private var cacNutMau: [NutMau] = []
    private var congViecTuDongLuu: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ve Tranh Giay"
        view.backgroundColor = MauSac.mauNen
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        taoGiaoDien()
        cauHinhKhungVe()
        napBanVeCu()
        capNhatCongCuVe()
    }

    private func taoGiaoDien() {
        let nutLuu = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"),
            style: .done,
            target: self,
            action: #selector(luuAnhVaoAlbum)
        )
        nutLuu.accessibilityLabel = "Luu anh"

        let nutChonMau = UIBarButtonItem(
            image: UIImage(systemName: "paintpalette.fill"),
            style: .plain,
            target: self,
            action: #selector(moBangChonMau)
        )
        nutChonMau.accessibilityLabel = "Chon mau tuy y"
        navigationItem.rightBarButtonItems = [nutLuu, nutChonMau]

        khungVe.translatesAutoresizingMaskIntoConstraints = false
        khungVe.layer.cornerRadius = 18
        khungVe.layer.borderWidth = 1
        khungVe.layer.borderColor = MauSac.mauVien.cgColor
        khungVe.layer.shadowColor = UIColor.black.cgColor
        khungVe.layer.shadowOpacity = 0.12
        khungVe.layer.shadowRadius = 10
        khungVe.layer.shadowOffset = CGSize(width: 0, height: 4)

        thanhCongCu.axis = .horizontal
        thanhCongCu.alignment = .center
        thanhCongCu.distribution = .fillProportionally
        thanhCongCu.spacing = 8
        thanhCongCu.translatesAutoresizingMaskIntoConstraints = false

        let cacCongCu: [(String, Selector)] = [
            ("But chi", #selector(chonButChi)),
            ("But muc", #selector(chonButMuc)),
            ("Danh dau", #selector(chonButDanhDau)),
            ("Tay", #selector(chonTay)),
            ("Hoan tac", #selector(hoanTac)),
            ("Lam lai", #selector(lamLai)),
            ("Xoa", #selector(xacNhanXoa))
        ]

        for (ten, hanhDong) in cacCongCu {
            thanhCongCu.addArrangedSubview(taoNut(ten: ten, hanhDong: hanhDong))
        }

        nhanDoDay.text = "Do day: 5"
        nhanDoDay.font = .systemFont(ofSize: 13, weight: .semibold)
        nhanDoDay.textColor = MauSac.mauNau
        nhanDoDay.setContentHuggingPriority(.required, for: .horizontal)

        thanhDoDay.minimumValue = 1
        thanhDoDay.maximumValue = 30
        thanhDoDay.value = 5
        thanhDoDay.addTarget(self, action: #selector(thayDoiDoDay), for: .valueChanged)

        let hangDoDay = UIStackView(arrangedSubviews: [nhanDoDay, thanhDoDay])
        hangDoDay.axis = .horizontal
        hangDoDay.alignment = .center
        hangDoDay.spacing = 12
        hangDoDay.translatesAutoresizingMaskIntoConstraints = false

        thanhMau.translatesAutoresizingMaskIntoConstraints = false
        thanhMau.showsHorizontalScrollIndicator = false
        thanhMau.alwaysBounceHorizontal = true

        hangMau.axis = .horizontal
        hangMau.alignment = .center
        hangMau.spacing = 10
        hangMau.translatesAutoresizingMaskIntoConstraints = false
        thanhMau.addSubview(hangMau)

        for mau in MauSac.danhSach {
            let nut = NutMau(mau: mau)
            nut.addTarget(self, action: #selector(chonMau(_:)), for: .touchUpInside)
            hangMau.addArrangedSubview(nut)
            cacNutMau.append(nut)
        }
        cacNutMau.first?.datDangChon(true)

        nhanCheDoBut.text = "Chi Apple Pencil"
        nhanCheDoBut.font = .systemFont(ofSize: 13, weight: .semibold)
        nhanCheDoBut.textColor = MauSac.mauNau

        chuyenCheDoBut.isOn = false
        chuyenCheDoBut.onTintColor = MauSac.mauNau
        chuyenCheDoBut.addTarget(self, action: #selector(thayDoiCheDoVe), for: .valueChanged)

        let khoangTrong = UIView()
        let hangCheDoBut = UIStackView(arrangedSubviews: [nhanCheDoBut, khoangTrong, chuyenCheDoBut])
        hangCheDoBut.axis = .horizontal
        hangCheDoBut.alignment = .center

        let bangDieuKhien = UIStackView(arrangedSubviews: [thanhCongCu, hangDoDay, hangCheDoBut, thanhMau])
        bangDieuKhien.axis = .vertical
        bangDieuKhien.spacing = 10
        bangDieuKhien.translatesAutoresizingMaskIntoConstraints = false
        bangDieuKhien.backgroundColor = UIColor.white.withAlphaComponent(0.86)
        bangDieuKhien.layer.cornerRadius = 16
        bangDieuKhien.isLayoutMarginsRelativeArrangement = true
        bangDieuKhien.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)

        view.addSubview(khungVe)
        view.addSubview(bangDieuKhien)

        NSLayoutConstraint.activate([
            bangDieuKhien.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            bangDieuKhien.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            bangDieuKhien.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            thanhMau.heightAnchor.constraint(equalToConstant: 38),

            hangMau.leadingAnchor.constraint(equalTo: thanhMau.contentLayoutGuide.leadingAnchor),
            hangMau.trailingAnchor.constraint(equalTo: thanhMau.contentLayoutGuide.trailingAnchor),
            hangMau.topAnchor.constraint(equalTo: thanhMau.contentLayoutGuide.topAnchor, constant: 2),
            hangMau.bottomAnchor.constraint(equalTo: thanhMau.contentLayoutGuide.bottomAnchor, constant: -2),
            hangMau.heightAnchor.constraint(equalTo: thanhMau.frameLayoutGuide.heightAnchor, constant: -4),

            khungVe.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            khungVe.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            khungVe.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            khungVe.bottomAnchor.constraint(equalTo: bangDieuKhien.topAnchor, constant: -10)
        ])
    }

    private func taoNut(ten: String, hanhDong: Selector) -> UIButton {
        var cauHinh = UIButton.Configuration.tinted()
        cauHinh.title = ten
        cauHinh.baseForegroundColor = MauSac.mauNau
        cauHinh.baseBackgroundColor = MauSac.mauNen
        cauHinh.cornerStyle = .medium

        let nut = UIButton(configuration: cauHinh)
        nut.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        nut.addTarget(self, action: hanhDong, for: .touchUpInside)
        return nut
    }

    private func cauHinhKhungVe() {
        khungVe.delegate = self
        khungVe.backgroundColor = MauSac.mauGiay
        khungVe.isOpaque = true
        khungVe.drawingPolicy = .anyInput
        khungVe.alwaysBounceVertical = false
        khungVe.alwaysBounceHorizontal = false
        khungVe.maximumZoomScale = 1
        khungVe.minimumZoomScale = 1
        khungVe.contentInset = .zero
    }

    private func napBanVeCu() {
        if let banVeCu = QuanLyBanVe.dungChung.docBanVe() {
            khungVe.drawing = banVeCu
        }
    }

    private func capNhatCongCuVe() {
        khungVe.tool = PKInkingTool(loaiButDangChon, color: mauDangChon, width: doDayNet)
    }

    @objc private func chonButChi() {
        loaiButDangChon = .pencil
        capNhatCongCuVe()
    }

    @objc private func chonButMuc() {
        loaiButDangChon = .pen
        capNhatCongCuVe()
    }

    @objc private func chonButDanhDau() {
        loaiButDangChon = .marker
        capNhatCongCuVe()
    }

    @objc private func chonTay() {
        khungVe.tool = PKEraserTool(.vector)
    }

    @objc private func thayDoiDoDay() {
        doDayNet = CGFloat(thanhDoDay.value)
        nhanDoDay.text = "Do day: \(Int(thanhDoDay.value))"
        capNhatCongCuVe()
    }

    @objc private func chonMau(_ nut: NutMau) {
        mauDangChon = nut.mau
        cacNutMau.forEach { $0.datDangChon($0 === nut) }
        capNhatCongCuVe()
    }

    @objc private func moBangChonMau() {
        let bangChonMau = UIColorPickerViewController()
        bangChonMau.delegate = self
        bangChonMau.selectedColor = mauDangChon
        bangChonMau.supportsAlpha = true
        present(bangChonMau, animated: true)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        mauDangChon = viewController.selectedColor
        cacNutMau.forEach { $0.datDangChon(false) }
        capNhatCongCuVe()
    }

    @objc private func thayDoiCheDoVe() {
        khungVe.drawingPolicy = chuyenCheDoBut.isOn ? .pencilOnly : .anyInput
        nhanCheDoBut.text = chuyenCheDoBut.isOn ? "Dang chi dung Apple Pencil" : "Pencil va ngon tay"
    }

    @objc private func hoanTac() {
        khungVe.undoManager?.undo()
    }

    @objc private func lamLai() {
        khungVe.undoManager?.redo()
    }

    @objc private func xacNhanXoa() {
        let hopThoai = UIAlertController(
            title: "Xoa toan bo tranh?",
            message: "Thao tac nay co the hoan tac ngay sau khi xoa.",
            preferredStyle: .alert
        )
        hopThoai.addAction(UIAlertAction(title: "Huy", style: .cancel))
        hopThoai.addAction(UIAlertAction(title: "Xoa", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.khungVe.drawing = PKDrawing()
            QuanLyBanVe.dungChung.xoaBanVeDaLuu()
        })
        present(hopThoai, animated: true)
    }

    @objc private func luuAnhVaoAlbum() {
        guard !khungVe.drawing.bounds.isNull, !khungVe.drawing.bounds.isEmpty else {
            hienThongBao(tieuDe: "Chua co tranh", noiDung: "Anh Hai hay ve mot chut truoc khi luu nhe.")
            return
        }

        let le: CGFloat = 40
        let vungNetVe = khungVe.drawing.bounds.insetBy(dx: -le, dy: -le)
        let anhNetVe = khungVe.drawing.image(from: vungNetVe, scale: 3)
        let boTaoAnh = UIGraphicsImageRenderer(size: vungNetVe.size)
        let anhHoanChinh = boTaoAnh.image { boCanh in
            MauSac.mauGiay.setFill()
            boCanh.fill(CGRect(origin: .zero, size: vungNetVe.size))
            anhNetVe.draw(at: .zero)
        }

        navigationItem.rightBarButtonItems?.first?.isEnabled = false
        dichVuLuuAnh.luu(anhHoanChinh) { [weak self] ketQua in
            self?.navigationItem.rightBarButtonItems?.first?.isEnabled = true
            switch ketQua {
            case .success:
                self?.hienThongBao(tieuDe: "Da luu", noiDung: "Tranh da duoc luu vao album anh.")
            case .failure(let loi):
                self?.hienThongBao(tieuDe: "Khong luu duoc", noiDung: loi.localizedDescription)
            }
        }
    }

    private func hienThongBao(tieuDe: String, noiDung: String) {
        let hopThoai = UIAlertController(title: tieuDe, message: noiDung, preferredStyle: .alert)
        hopThoai.addAction(UIAlertAction(title: "Dong", style: .default))
        present(hopThoai, animated: true)
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        congViecTuDongLuu?.cancel()
        let congViec = DispatchWorkItem {
            QuanLyBanVe.dungChung.luuBanVe(canvasView.drawing)
        }
        congViecTuDongLuu = congViec
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: congViec)
    }
}
