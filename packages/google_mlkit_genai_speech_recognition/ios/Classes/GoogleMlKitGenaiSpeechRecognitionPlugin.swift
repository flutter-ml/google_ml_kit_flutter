import Flutter

@objc
public class GoogleMlKitGenaiSpeechRecognitionPlugin: NSObject, FlutterPlugin {
  private var instances: [String: Any] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_genai_speech_recognition",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitGenaiSpeechRecognitionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let unimplemented = FlutterError(
      code: "UNIMPLEMENTED",
      message: "GenAI APIs are currently only available on Android",
      details: nil
    )
    switch call.method {
    case "genai#checkStatus", "genai#startRecognition", "genai#stopRecognition":
      result(unimplemented)
    case "genai#closeSpeechRecognizer":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
