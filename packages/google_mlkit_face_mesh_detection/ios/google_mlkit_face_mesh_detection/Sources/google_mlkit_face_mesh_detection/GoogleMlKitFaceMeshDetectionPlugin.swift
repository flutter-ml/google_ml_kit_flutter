import Flutter
import google_mlkit_commons

@objc
public class GoogleMlKitFaceMeshDetectionPlugin: NSObject, FlutterPlugin {
  private var instances: [String: Any] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_face_mesh_detector",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitFaceMeshDetectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startFaceMeshDetector":
      handleDetection(call: call, result: result)
    case "vision#closeFaceMeshDetector":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleDetection(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // swiftlint:disable:next todo
    // TODO: waiting for Google to release Face Mesh API for iOS
    result(FlutterMethodNotImplemented)
  }
}
