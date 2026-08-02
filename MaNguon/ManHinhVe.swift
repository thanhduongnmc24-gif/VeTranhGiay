import UIKit
import PencilKit

final class ManHinhVe: UIViewController, PKCanvasViewDelegate, UIColorPickerViewControllerDelegate {
    private let khungVeThuong = PKCanvasView()
    private let khungVeTrenCung = PKCanvasView()
    private let bangDieuKhien = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
    private let cuonCongCu = UIScrollView()
    private let hangCongCu = UIStackView()
    private let cuonMau = UIScrollView()
    private let hangMau = UIStackView()
    private let thanhDoDay = UISlider()
    private let nhanDoDay = UILabel()
    private let nutNetTrenCung = UIButton(type: .system)
    private let dichVuLuuAnh = DichVuLuuAnh()

    private var mauDangChon = UIColor.black
    private var loaiButDangChon: PKInkingTool.InkType = .pencil
    private var doDayNet: CGFloat = 8
    private var cacNutMau: [NutMau] = []
    private var cacNutCongCu: [UIButton] = []
    private var nutCongCuDangChon: UIButton?
    private var cacMauTuyChon = LuuMauTuyChon.dungChung.docDanhSach()
    private var viTriMauDangSua: Int?
    private var maBanVeHienTai: String?
    private var dangVeTrenCung = false
    private var congViecTuDongLuu: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ve Tranh Giay"
        view.backgroundColor = MauSac.mauNen
        taoGiaoDien()
        cauHinhHaiKhungVe()
        capNhatCongCuVe()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let kichThuoc = khungVeThuong.bounds.size
        if kichThuoc.width > 0 && kichThuoc.height > 0 {
            khungVeThuong.contentSize = kichThuoc
            khungVeTrenCung.contentSize = kichThuoc
        }
    }

    private var khungVeDangDung: PKCanvasView { dangVeTrenCung ? khungVeTrenCung : khungVeThuong }

    private func taoGiaoDien() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .done, target: self, action: #selector(luuAnh)),
            UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled"), style: .plain, target: self, action: #selector(moThuVien)),
            UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(taoTranhMoi))
        ]

        [khungVeThuong, khungVeTrenCung].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            view.addSubview($0)
        }

        khungVeThuong.backgroundColor = MauSac.mauGiay
        khungVeThuong.isOpaque = true
        khungVeTrenCung.backgroundColor = .clear
        khungVeTrenCung.isOpaque = false

        bangDieuKhien.translatesAutoresizingMaskIntoConstraints = false
        bangDieuKhien.layer.cornerRadius = 14
        bangDieuKhien.clipsToBounds = true
        view.addSubview(bangDieuKhien)

        cuonCongCu.showsHorizontalScrollIndicator = false
        cuonCongCu.translatesAutoresizingMaskIntoConstraints = false
        hangCongCu.axis = .horizontal
        hangCongCu.spacing = 5
        hangCongCu.translatesAutoresizingMaskIntoConstraints = false
        cuonCongCu.addSubview(hangCongCu)

        let thongTinBut: [(String, String, PKInkingTool.InkType?)] = [
            ("But chi", "pencil.tip", .pencil),
            ("But muc", "pencil.line", .pen),
            ("Danh dau", "highlighter", .marker)
        ]
        for (ten, bieuTuong, loai) in thongTinBut {
            let nut = taoNutCongCu(ten: ten, bieuTuong: bieuTuong)
            nut.addAction(UIAction { [weak self, weak nut] _ in
                guard let self, let nut, let loai else { return }
                self.loaiButDangChon = loai
                self.capNhatCongCuVe()
                self.datNutCongCuDangChon(nut)
            }, for: .touchUpInside)
            hangCongCu.addArrangedSubview(nut)
        }
        if #available(iOS 17.0, *) {
            let butMoi: [(String, String, PKInkingTool.InkType)] = [
                ("Net deu", "line.diagonal", .monoline),
                ("But may", "scribble.variable", .fountainPen),
                ("Mau nuoc", "drop.fill", .watercolor),
                ("Sap mau", "paintbrush.pointed.fill", .crayon)
            ]
            for (ten, bieuTuong, loai) in butMoi {
                let nut = taoNutCongCu(ten: ten, bieuTuong: bieuTuong)
                nut.addAction(UIAction { [weak self, weak nut] _ in
                    guard let self, let nut else { return }
                    self.loaiButDangChon = loai
                    self.capNhatCongCuVe()
                    self.datNutCongCuDangChon(nut)
                }, for: .touchUpInside)
                hangCongCu.addArrangedSubview(nut)
            }
        }
        let nutTay = taoNutCongCu(ten: "Tay", bieuTuong: "eraser.fill")
        nutTay.addAction(UIAction { [weak self, weak nutTay] _ in
            guard let self, let nutTay else { return }
            self.khungVeDangDung.tool = PKEraserTool(.vector)
            self.datNutCongCuDangChon(nutTay)
        }, for: .touchUpInside)
        hangCongCu.addArrangedSubview(nutTay)

        let nutHoanTac = taoNutCongCu(ten: "Hoan tac", bieuTuong: "arrow.uturn.backward")
        nutHoanTac.addAction(UIAction { [weak self] _ in self?.khungVeDangDung.undoManager?.undo() }, for: .touchUpInside)
        hangCongCu.addArrangedSubview(nutHoanTac)
        let nutLamLai = taoNutCongCu(ten: "Lam lai", bieuTuong: "arrow.uturn.forward")
        nutLamLai.addAction(UIAction { [weak self] _ in self?.khungVeDangDung.undoManager?.redo() }, for: .touchUpInside)
        hangCongCu.addArrangedSubview(nutLamLai)
        datNutCongCuDangChon(cacNutCongCu.first)

        nutNetTrenCung.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        nutNetTrenCung.setTitle(" Net tren cung", for: .normal)
        nutNetTrenCung.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
        nutNetTrenCung.addTarget(self, action: #selector(batTatNetTrenCung), for: .touchUpInside)
        capNhatNutNetTrenCung()

        nhanDoDay.font = .monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
        nhanDoDay.text = "8"
        nhanDoDay.textAlignment = .center
        nhanDoDay.widthAnchor.constraint(equalToConstant: 30).isActive = true
        thanhDoDay.minimumValue = 1
        thanhDoDay.maximumValue = 100
        thanhDoDay.value = 8
        thanhDoDay.addTarget(self, action: #selector(thayDoiDoDay), for: .valueChanged)
        let hangDoDay = UIStackView(arrangedSubviews: [UIImageView(image: UIImage(systemName: "circle.fill")), thanhDoDay, nhanDoDay, nutNetTrenCung])
        hangDoDay.axis = .horizontal
        hangDoDay.alignment = .center
        hangDoDay.spacing = 7

        cuonMau.showsHorizontalScrollIndicator = false
        cuonMau.translatesAutoresizingMaskIntoConstraints = false
        hangMau.axis = .horizontal
        hangMau.spacing = 7
        hangMau.alignment = .center
        hangMau.translatesAutoresizingMaskIntoConstraints = false
        cuonMau.addSubview(hangMau)
        taoCacNutMau()

        let noiDung = UIStackView(arrangedSubviews: [cuonCongCu, hangDoDay, cuonMau])
        noiDung.axis = .vertical
        noiDung.spacing = 5
        noiDung.translatesAutoresizingMaskIntoConstraints = false
        bangDieuKhien.contentView.addSubview(noiDung)

        NSLayoutConstraint.activate([
            bangDieuKhien.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7),
            bangDieuKhien.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7),
            bangDieuKhien.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            noiDung.leadingAnchor.constraint(equalTo: bangDieuKhien.contentView.leadingAnchor, constant: 7),
            noiDung.trailingAnchor.constraint(equalTo: bangDieuKhien.contentView.trailingAnchor, constant: -7),
            noiDung.topAnchor.constraint(equalTo: bangDieuKhien.contentView.topAnchor, constant: 6),
            noiDung.bottomAnchor.constraint(equalTo: bangDieuKhien.contentView.bottomAnchor, constant: -6),
            cuonCongCu.heightAnchor.constraint(equalToConstant: 34),
            cuonMau.heightAnchor.constraint(equalToConstant: 30),

            hangCongCu.leadingAnchor.constraint(equalTo: cuonCongCu.contentLayoutGuide.leadingAnchor),
            hangCongCu.trailingAnchor.constraint(equalTo: cuonCongCu.contentLayoutGuide.trailingAnchor),
            hangCongCu.topAnchor.constraint(equalTo: cuonCongCu.contentLayoutGuide.topAnchor),
            hangCongCu.bottomAnchor.constraint(equalTo: cuonCongCu.contentLayoutGuide.bottomAnchor),
            hangCongCu.heightAnchor.constraint(equalTo: cuonCongCu.frameLayoutGuide.heightAnchor),
            hangMau.leadingAnchor.constraint(equalTo: cuonMau.contentLayoutGuide.leadingAnchor),
            hangMau.trailingAnchor.constraint(equalTo: cuonMau.contentLayoutGuide.trailingAnchor),
            hangMau.topAnchor.constraint(equalTo: cuonMau.contentLayoutGuide.topAnchor),
            hangMau.bottomAnchor.constraint(equalTo: cuonMau.contentLayoutGuide.bottomAnchor),
            hangMau.heightAnchor.constraint(equalTo: cuonMau.frameLayoutGuide.heightAnchor),

            khungVeThuong.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            khungVeThuong.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            khungVeThuong.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            khungVeThuong.bottomAnchor.constraint(equalTo: bangDieuKhien.topAnchor, constant: -5),
            khungVeTrenCung.topAnchor.constraint(equalTo: khungVeThuong.topAnchor),
            khungVeTrenCung.leadingAnchor.constraint(equalTo: khungVeThuong.leadingAnchor),
            khungVeTrenCung.trailingAnchor.constraint(equalTo: khungVeThuong.trailingAnchor),
            khungVeTrenCung.bottomAnchor.constraint(equalTo: khungVeThuong.bottomAnchor)
        ])
    }

    private func cauHinhHaiKhungVe() {
        [khungVeThuong, khungVeTrenCung].forEach {
            $0.delegate = self
            $0.drawingPolicy = .anyInput
            $0.minimumZoomScale = 1
            $0.maximumZoomScale = 1
            $0.alwaysBounceHorizontal = false
            $0.alwaysBounceVertical = false
        }
        capNhatKhungVeDangDung()
    }

    private func taoNutCongCu(ten: String, bieuTuong: String) -> UIButton {
        var cauHinh = UIButton.Configuration.tinted()
        cauHinh.image = UIImage(systemName: bieuTuong)
        cauHinh.baseForegroundColor = MauSac.mauNau
        cauHinh.baseBackgroundColor = MauSac.mauNen
        cauHinh.cornerStyle = .medium
        cauHinh.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        let nut = UIButton(configuration: cauHinh)
        nut.accessibilityLabel = ten
        nut.widthAnchor.constraint(greaterThanOrEqualToConstant: 38).isActive = true
        cacNutCongCu.append(nut)
        return nut
    }

    private func datNutCongCuDangChon(_ nut: UIButton?) {
        nutCongCuDangChon = nut
        for motNut in cacNutCongCu {
            motNut.configuration?.baseBackgroundColor = motNut === nut ? .systemBlue : MauSac.mauNen
            motNut.configuration?.baseForegroundColor = motNut === nut ? .white : MauSac.mauNau
        }
    }

    private func taoCacNutMau() {
        hangMau.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cacNutMau.removeAll()
        for mau in MauSac.danhSach {
            let nut = NutMau(mau: mau)
            nut.addTarget(self, action: #selector(chonMau(_:)), for: .touchUpInside)
            hangMau.addArrangedSubview(nut)
            cacNutMau.append(nut)
        }
        for viTri in 0..<7 {
            let nut = NutMau(mau: cacMauTuyChon[viTri], viTriTuyChon: viTri)
            nut.addTarget(self, action: #selector(chonMau(_:)), for: .touchUpInside)
            hangMau.addArrangedSubview(nut)
            cacNutMau.append(nut)
        }
        cacNutMau.first?.datDangChon(true)
    }

    @objc private func chonMau(_ nut: NutMau) {
        if let viTri = nut.viTriTuyChon, nut.mau == nil {
            viTriMauDangSua = viTri
            moBangChonMau(mauBanDau: .systemBlue)
            return
        }
        guard let mau = nut.mau else { return }
        mauDangChon = mau
        viTriMauDangSua = nut.viTriTuyChon
        cacNutMau.forEach { $0.datDangChon($0 === nut) }
        capNhatCongCuVe()
    }

    private func moBangChonMau(mauBanDau: UIColor) {
        let bang = UIColorPickerViewController()
        bang.delegate = self
        bang.selectedColor = mauBanDau
        bang.supportsAlpha = true
        present(bang, animated: true)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        guard let viTri = viTriMauDangSua else { return }
        let mauMoi = viewController.selectedColor
        cacMauTuyChon[viTri] = mauMoi
        LuuMauTuyChon.dungChung.luuDanhSach(cacMauTuyChon)
        mauDangChon = mauMoi
        if let nut = cacNutMau.first(where: { $0.viTriTuyChon == viTri }) {
            nut.capNhatMau(mauMoi)
            cacNutMau.forEach { $0.datDangChon($0 === nut) }
        }
        capNhatCongCuVe()
    }

    @objc private func thayDoiDoDay() {
        doDayNet = CGFloat(thanhDoDay.value)
        nhanDoDay.text = "\(Int(thanhDoDay.value))"
        capNhatCongCuVe()
    }

    @objc private func batTatNetTrenCung() {
        dangVeTrenCung.toggle()
        capNhatKhungVeDangDung()
        capNhatNutNetTrenCung()
        capNhatCongCuVe()
    }

    private func capNhatNutNetTrenCung() {
        nutNetTrenCung.tintColor = dangVeTrenCung ? .white : .systemBlue
        nutNetTrenCung.backgroundColor = dangVeTrenCung ? .systemBlue : .clear
        nutNetTrenCung.layer.cornerRadius = 7
    }

    private func capNhatKhungVeDangDung() {
        khungVeTrenCung.isUserInteractionEnabled = dangVeTrenCung
        khungVeThuong.isUserInteractionEnabled = !dangVeTrenCung
    }

    private func capNhatCongCuVe() {
        khungVeDangDung.tool = PKInkingTool(loaiButDangChon, color: mauDangChon, width: doDayNet)
    }

    private func taoAnhTongHop() -> UIImage {
        view.layoutIfNeeded()
        let kichThuoc = khungVeThuong.bounds.size
        let boTao = UIGraphicsImageRenderer(size: kichThuoc)
        return boTao.image { boCanh in
            MauSac.mauGiay.setFill()
            boCanh.fill(CGRect(origin: .zero, size: kichThuoc))
            khungVeThuong.drawing.image(from: CGRect(origin: .zero, size: kichThuoc), scale: 3).draw(in: CGRect(origin: .zero, size: kichThuoc))
            khungVeTrenCung.drawing.image(from: CGRect(origin: .zero, size: kichThuoc), scale: 3).draw(in: CGRect(origin: .zero, size: kichThuoc))
        }
    }

    @objc private func luuAnh() {
        guard !khungVeThuong.drawing.strokes.isEmpty || !khungVeTrenCung.drawing.strokes.isEmpty else {
            hienThongBao("Chua co net ve", "Hay ve mot chut truoc khi luu.")
            return
        }
        let anh = taoAnhTongHop()
        do {
            maBanVeHienTai = try QuanLyThuVien.dungChung.luuBanVe(
                maBanVe: maBanVeHienTai,
                banVeThuong: khungVeThuong.drawing,
                banVeTrenCung: khungVeTrenCung.drawing,
                anhXemTruoc: anh
            )
        } catch {
            hienThongBao("Khong luu duoc trong ung dung", error.localizedDescription)
            return
        }
        dichVuLuuAnh.luu(anh) { [weak self] ketQua in
            switch ketQua {
            case .success: self?.hienThongBao("Da luu", "Da luu vao Album Anh va Thu vien tranh cua ung dung.")
            case .failure(let loi): self?.hienThongBao("Da luu trong ung dung", "Khong them duoc vao Album Anh: \(loi.localizedDescription)")
            }
        }
    }

    @objc private func moThuVien() {
        let manHinh = ManHinhThuVien { [weak self] banVe in self?.moBanVe(banVe) }
        present(UINavigationController(rootViewController: manHinh), animated: true)
    }

    private func moBanVe(_ banVe: MauBanVe) {
        maBanVeHienTai = banVe.maBanVe
        khungVeThuong.drawing = banVe.banVeThuong
        khungVeTrenCung.drawing = banVe.banVeTrenCung
        title = "Dang sua tranh"
    }

    @objc private func taoTranhMoi() {
        let hopThoai = UIAlertController(title: "Tao tranh moi?", message: "Hay luu tranh hien tai neu can.", preferredStyle: .alert)
        hopThoai.addAction(UIAlertAction(title: "Huy", style: .cancel))
        hopThoai.addAction(UIAlertAction(title: "Tao moi", style: .destructive) { [weak self] _ in
            self?.maBanVeHienTai = nil
            self?.khungVeThuong.drawing = PKDrawing()
            self?.khungVeTrenCung.drawing = PKDrawing()
            self?.title = "Ve Tranh Giay"
        })
        present(hopThoai, animated: true)
    }

    private func hienThongBao(_ tieuDe: String, _ noiDung: String) {
        let hopThoai = UIAlertController(title: tieuDe, message: noiDung, preferredStyle: .alert)
        hopThoai.addAction(UIAlertAction(title: "Dong", style: .default))
        present(hopThoai, animated: true)
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        congViecTuDongLuu?.cancel()
        let congViec = DispatchWorkItem { [weak self] in
            guard let self, let ma = self.maBanVeHienTai else { return }
            try? QuanLyThuVien.dungChung.luuBanVe(
                maBanVe: ma,
                banVeThuong: self.khungVeThuong.drawing,
                banVeTrenCung: self.khungVeTrenCung.drawing,
                anhXemTruoc: self.taoAnhTongHop()
            )
        }
        congViecTuDongLuu = congViec
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: congViec)
    }
}
