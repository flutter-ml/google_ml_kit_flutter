import Flutter

@objc
public class GoogleMlKitSubjectSegmentationPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_subject_segmentation",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitSubjectSegmentationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }
}
