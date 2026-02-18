import Flutter
import UIKit

@objc
public class GoogleMlKitDocumentScannerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_document_scanner",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitDocumentScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPlatformVersion" {
      result("iOS " + UIDevice.current.systemVersion)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
