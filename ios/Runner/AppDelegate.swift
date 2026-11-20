import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let appSettingsChannel = FlutterMethodChannel(
      name: "com.locvel.voite/app_settings",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    appSettingsChannel.setMethodCallHandler { call, result in
      guard call.method == "openAppSettings" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        result(FlutterError(code: "settings_unavailable", message: "App settings could not be opened.", details: nil))
        return
      }
      DispatchQueue.main.async {
        UIApplication.shared.open(url, options: [:]) { opened in
          if opened {
            result(nil)
          } else {
            result(FlutterError(code: "settings_unavailable", message: "App settings could not be opened.", details: nil))
          }
        }
      }
    }

    let storageChannel = FlutterMethodChannel(
      name: "com.locvel.voite/storage",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    storageChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "freeBytes":
        do {
          let attributes = try FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
          )
          result((attributes[.systemFreeSize] as? NSNumber)?.int64Value)
        } catch {
          result(FlutterError(code: "storage_unavailable", message: error.localizedDescription, details: nil))
        }
      case "protectAppData":
        guard
          let arguments = call.arguments as? [String: Any],
          let path = arguments["path"] as? String
        else {
          result(FlutterError(code: "invalid_path", message: "A file path is required.", details: nil))
          return
        }
        do {
          var url = URL(fileURLWithPath: path)
          var values = URLResourceValues()
          values.isExcludedFromBackup = true
          try url.setResourceValues(values)
          try (url as NSURL).setResourceValue(
            URLFileProtection.completeUnlessOpen,
            forKey: .fileProtectionKey
          )
          result(nil)
        } catch {
          result(FlutterError(code: "backup_exclusion_failed", message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let shareChannel = FlutterMethodChannel(
      name: "com.locvel.voite/share",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    shareChannel.setMethodCallHandler { call, result in
      let arguments = call.arguments as? [String: Any] ?? [:]
      let title = arguments["title"] as? String ?? "Share"
      var activityItems: [Any]
      switch call.method {
      case "shareText":
        guard let text = arguments["text"] as? String, !text.isEmpty else {
          result(FlutterError(code: "empty_text", message: "There is no transcript text to share.", details: nil))
          return
        }
        activityItems = [text]
      case "shareAudio":
        guard let path = arguments["path"] as? String else {
          result(FlutterError(code: "invalid_path", message: "A recording path is required.", details: nil))
          return
        }
        let fileURL = URL(fileURLWithPath: path).standardizedFileURL
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
          .appendingPathComponent("recordings", isDirectory: true).standardizedFileURL
        guard fileURL.path.hasPrefix(documentsURL.path + "/"),
              FileManager.default.fileExists(atPath: fileURL.path) else {
          result(FlutterError(code: "invalid_path", message: "Only a saved recording can be shared.", details: nil))
          return
        }
        activityItems = [fileURL]
      default:
        result(FlutterMethodNotImplemented)
        return
      }

      DispatchQueue.main.async {
        let keyWindow = UIApplication.shared.connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .flatMap { $0.windows }
          .first { $0.isKeyWindow }
        guard var presenter = keyWindow?.rootViewController else {
          result(FlutterError(code: "share_unavailable", message: "The share menu is unavailable.", details: nil))
          return
        }
        while let presented = presenter.presentedViewController {
          presenter = presented
        }
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.title = title
        if let popover = controller.popoverPresentationController {
          popover.sourceView = presenter.view
          popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.maxY - 1, width: 1, height: 1)
          popover.permittedArrowDirections = []
        }
        presenter.present(controller, animated: true) { result(nil) }
      }
    }
  }
}
