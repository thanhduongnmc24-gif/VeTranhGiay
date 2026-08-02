import UIKit

@main
final class UyQuyenUngDung: UIResponder, UIApplicationDelegate {
    var cuaSo: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let cuaSoMoi = UIWindow(frame: UIScreen.main.bounds)
        cuaSoMoi.rootViewController = UINavigationController(rootViewController: ManHinhVe())
        cuaSoMoi.tintColor = MauSac.mauNau
        cuaSoMoi.makeKeyAndVisible()
        cuaSo = cuaSoMoi
        return true
    }
}
