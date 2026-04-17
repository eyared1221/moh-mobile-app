import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty,
       !mapsApiKey.hasPrefix("$(") {
      GMSServices.provideAPIKey(mapsApiKey)
    }

    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let mapsConfigChannel = FlutterMethodChannel(
        name: "com.yegna_health/maps_config",
        binaryMessenger: controller.binaryMessenger
      )
      mapsConfigChannel.setMethodCallHandler { call, result in
        if call.method == "getGoogleMapsApiKey" {
          let value = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
          result(value.hasPrefix("$(") ? "" : value)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
