import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Nạp Google Maps API Key từ Info.plist (được truyền từ ios/Flutter/Secrets.xcconfig)
    if let rawKey = Bundle.main.object(forInfoDictionaryKey: "MapApiKey") as? String {
      let apiKey = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if !apiKey.isEmpty && !apiKey.hasPrefix("$(") {
        GMSServices.provideAPIKey(apiKey)
      } else {
        NSLog("[GoogleMaps] Cảnh báo: Chưa cấu hình IOS_MAPS_API_KEY trong ios/Flutter/Secrets.xcconfig")
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
