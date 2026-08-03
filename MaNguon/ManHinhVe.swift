import UIKit
import PencilKit

final class ManHinhVe: UIViewController, PKCanvasViewDelegate, UIColorPickerViewControllerDelegate {
    private let khungVeThuong = PKCanvasView()
    private let khungVeTrenCung = PKCanvasView()
    private let lopTay = VongTayView()
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
    private var loaiButNetTrenCung: PKInkingTool.InkType?
    private var dangDungTay = false
    private var congViecTuĐóngLuu: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vẽ Tranh Giấy"
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

        lopTay.translatesAutoresizingMaskIntoConstraints = false
        lopTay.backgroundColor = .clear
        lopTay.isUserInteractionEnabled = false
        lopTay.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(xuLyCuChiTay(_:))))
        lopTay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(xuLyChamTay(_:))))
        view.addSubview(lopTay)

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
            ("Bút chì", "pencil.tip", .pencil),
            ("Bút mực", "pencil.line", .pen),
            ("Đánh dấu", "highlighter", .marker)
        ]
        for (ten, bieuTuong, loai) in thongTinBut {
            let nut = taoNutCongCu(ten: ten, bieuTuong: bieuTuong)
            nut.addAction(UIAction { [weak self, weak nut] _ in
                guard let self, let nut, let loai else { return }
                self.chonLoaiBut(loai, nut: nut)
            }, for: .touchUpInside)
            hangCongCu.addArrangedSubview(nut)
        }
        if #available(iOS 17.0, *) {
            let butMoi: [(String, String, PKInkingTool.InkType)] = [
                ("Nét đều", "line.diagonal", .monoline),
                ("Bút máy", "scribble.variable", .fountainPen),
                ("Màu nước", "drop.fill", .watercolor),
                ("Sáp màu", "paintbrush.pointed.fill", .crayon)
            ]
            for (ten, bieuTuong, loai) in butMoi {
                let nut = taoNutCongCu(ten: ten, bieuTuong: bieuTuong)
                nut.addAction(UIAction { [weak self, weak nut] _ in
                    guard let self, let nut else { return }
                    self.chonLoaiBut(loai, nut: nut)
                }, for: .touchUpInside)
                hangCongCu.addArrangedSubview(nut)
            }
        }
        let nutTẩy = taoNutCongCu(ten: "Tẩy", bieuTuong: "eraser.fill")
        nutTẩy.addAction(UIAction { [weak self, weak nutTẩy] _ in
            guard let self, let nutTẩy else { return }
            self.khungVeDangDung.tool = PKEraserTool(.vector)
            self.datNutCongCuDangChon(nutTẩy)
        }, for: .touchUpInside)
        hangCongCu.addArrangedSubview(nutTẩy)

        let nutHoanTac = taoNutCongCu(ten: "Hoàn tác", bieuTuong: "arrow.uturn.backward")
        nutHoanTac.addAction(UIAction { [weak self] _ in self?.khungVeDangDung.undoManager?.undo() }, for: .touchUpInside)
        hangCongCu.addArrangedSubview(nutHoanTac)
        let nutLamLai = taoNutCongCu(ten: "Làm lại", bieuTuong: "arrow.uturn.forward")
        nutLamLai.addAction(UIAction { [weak self] _ in self?.khungVeDangDung.undoManager?.redo() }, for: .touchUpInside)
        hangCongCu.addArrangedSubview(nutLamLai)
        datNutCongCuDangChon(cacNutCongCu.first)

        nutNetTrenCung.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        nutNetTrenCung.setTitle(" Nét trên cùng", for: .normal)
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
            khungVeTrenCung.bottomAnchor.constraint(equalTo: khungVeThuong.bottomAnchor),
            lopTay.topAnchor.constraint(equalTo: khungVeThuong.topAnchor),
            lopTay.leadingAnchor.constraint(equalTo: khungVeThuong.leadingAnchor),
            lopTay.trailingAnchor.constraint(equalTo: khungVeThuong.trailingAnchor),
            lopTay.bottomAnchor.constraint(equalTo: khungVeThuong.bottomAnchor)
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

    private func chonLoaiBut(_ loaiBut: PKInkingTool.InkType, nut: UIButton) {
        dangDungTay = false
        lopTay.anVongTay()
        loaiButDangChon = loaiBut

        if loaiButNetTrenCung == loaiBut {
            dangVeTrenCung = true
        } else {
            dangVeTrenCung = false
        }

        capNhatKhungVeDangDung()
        capNhatNutNetTrenCung()
        capNhatCongCuVe()
        datNutCongCuDangChon(nut)
    }

    @objc private func batTatNetTrenCung() {
        dangDungTay = false
        lopTay.anVongTay()
        if dangVeTrenCung {
            dangVeTrenCung = false
            loaiButNetTrenCung = nil
        } else {
            dangVeTrenCung = true
            loaiButNetTrenCung = loaiButDangChon
        }

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
        lopTay.isUserInteractionEnabled = dangDungTay
        khungVeTrenCung.isUserInteractionEnabled = !dangDungTay && dangVeTrenCung
        khungVeThuong.isUserInteractionEnabled = !dangDungTay && !dangVeTrenCung
        if dangDungTay { view.bringSubviewToFront(lopTay) }
        view.bringSubviewToFront(bangDieuKhien)
    }

    @objc private func xuLyCuChiTay(_ cuChi: UIPanGestureRecognizer) {
        let viTri = cuChi.location(in: lopTay)
        let banKinh = banKinhTayHienTai()

        switch cuChi.state {
        case .began, .changed:
            lopTay.hienVongTay(tai: viTri, banKinh: banKinh)
            tayNetTai(viTri, banKinh: banKinh)
        case .ended, .cancelled, .failed:
            lopTay.anVongTay()
        default:
            break
        }
    }

    @objc private func xuLyChamTay(_ cuChi: UITapGestureRecognizer) {
        let viTri = cuChi.location(in: lopTay)
        let banKinh = banKinhTayHienTai()
        lopTay.hienVongTay(tai: viTri, banKinh: banKinh)
        tayNetTai(viTri, banKinh: banKinh)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.lopTay.anVongTay()
        }
    }

    private func banKinhTayHienTai() -> CGFloat {
        max(CGFloat(14), doDayNet * 0.65)
    }

    private func tayNetTai(_ viTri: CGPoint, banKinh: CGFloat) {
        let vungTay = CGRect(
            x: viTri.x - banKinh,
            y: viTri.y - banKinh,
            width: banKinh * 2,
            height: banKinh * 2
        )

        // Luon kiem tra tat ca net tren lop tren cung, khong phan biet loai but.
        let cacNetTrenCung = khungVeTrenCung.drawing.strokes
        let netTrenCungConLai = cacNetTrenCung.filter { netVe in
            !netVe.renderBounds.intersects(vungTay)
        }

        if netTrenCungConLai.count != cacNetTrenCung.count {
            khungVeTrenCung.drawing = PKDrawing(strokes: netTrenCungConLai)
            return
        }

        // Khi khong con net tren cung tai vi tri do, xoa net lop thuong ben duoi.
        // Tat ca kieu but deu duoc xu ly nhu nhau.
        let cacNetThuong = khungVeThuong.drawing.strokes
        let netThuongConLai = cacNetThuong.filter { netVe in
            !netVe.renderBounds.intersects(vungTay)
        }

        if netThuongConLai.count != cacNetThuong.count {
            khungVeThuong.drawing = PKDrawing(strokes: netThuongConLai)
        }
    }

    private func xacNhanXoaTatCa() {
        let hopThoai = UIAlertController(title: "Xóa toàn bộ tranh?", message: "Tất cả nét vẽ trên cả hai lớp sẽ bị xóa.", preferredStyle: .alert)
        hopThoai.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        hopThoai.addAction(UIAlertAction(title: "Xóa tất cả", style: .destructive) { [weak self] _ in self?.lamMoiBanVe() })
        present(hopThoai, animated: true)
    }

    private func lamMoiBanVe() {
        maBanVeHienTai = nil
        khungVeThuong.drawing = PKDrawing()
        khungVeTrenCung.drawing = PKDrawing()
        dangDungTay = false
        lopTay.anVongTay()
        dangVeTrenCung = false
        loaiButNetTrenCung = nil
        title = "Vẽ Tranh Giấy"
        capNhatKhungVeDangDung()
        capNhatNutNetTrenCung()
        capNhatCongCuVe()
        datNutCongCuDangChon(cacNutCongCu.first)
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
            hienThongBao("Chưa có nét vẽ", "Hãy vẽ một chút trước khi lưu.")
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
            hienThongBao("Không lưu được trong ứng dụng", error.localizedDescription)
            return
        }
        dichVuLuuAnh.luu(anh) { [weak self] ketQua in
            guard let self else { return }
            switch ketQua {
            case .success:
                self.hienThongBao("Đã lưu", "Đã lưu vào Album Ảnh và Thư viện tranh của ứng dụng.")
            case .failure(let loi):
                self.hienThongBao("Đã lưu trong ứng dụng", "Không thêm được vào Album Ảnh: \(loi.localizedDescription)")
            }
            self.lamMoiBanVe()
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
        title = "Đang sửa tranh"
    }

    @objc private func taoTranhMoi() {
        let hopThoai = UIAlertController(title: "Tạo tranh mới?", message: "Hãy lưu tranh hiện tại nếu cần.", preferredStyle: .alert)
        hopThoai.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        hopThoai.addAction(UIAlertAction(title: "Tạo mới", style: .destructive) { [weak self] _ in
            self?.lamMoiBanVe()
        })
        present(hopThoai, animated: true)
    }

    private func hienThongBao(_ tieuDe: String, _ noiDung: String) {
        let hopThoai = UIAlertController(title: tieuDe, message: noiDung, preferredStyle: .alert)
        hopThoai.addAction(UIAlertAction(title: "Đóng", style: .default))
        present(hopThoai, animated: true)
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        congViecTuĐóngLuu?.cancel()
        let congViec = DispatchWorkItem { [weak self] in
            guard let self, let ma = self.maBanVeHienTai else { return }
            _ = try? QuanLyThuVien.dungChung.luuBanVe(
                maBanVe: ma,
                banVeThuong: self.khungVeThuong.drawing,
                banVeTrenCung: self.khungVeTrenCung.drawing,
                anhXemTruoc: self.taoAnhTongHop()
            )
        }
        congViecTuĐóngLuu = congViec
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: congViec)
    }
}
