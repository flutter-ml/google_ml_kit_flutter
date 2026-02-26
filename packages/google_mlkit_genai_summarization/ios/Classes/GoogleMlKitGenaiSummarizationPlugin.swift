import Flutter

@objc
public class GoogleMlKitGenaiSummarizationPlugin: NSObject, FlutterPlugin {
  private var instances: [String: Any] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_genai_summarization",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitGenaiSummarizationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let unimplemented = FlutterError(
      code: "UNIMPLEMENTED",
      message: "GenAI APIs are currently only available on Android",
      details: nil
    )
    switch call.method {
    case "genai#checkFeatureStatus", "genai#downloadFeature", "genai#runInference", "genai#runInferenceStreaming":
      result(unimplemented)
    case "genai#closeSummarizer":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
