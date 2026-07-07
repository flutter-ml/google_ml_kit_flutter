import Flutter
import MLKitSmartReply
import google_mlkit_commons

@objc
public class GoogleMlKitSmartReplyPlugin: NSObject, FlutterPlugin {
  private var instances: [String: SmartReply] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_smart_reply",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitSmartReplyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "nlp#startSmartReply":
      handleStartSmartReply(call: call, result: result)
    case "nlp#closeSmartReply":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleStartSmartReply(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let json = args["conversation"] as? [[String: Any]],
          let uid = args["id"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing arguments", details: nil))
      return
    }
    var conversation: [TextMessage] = []
    for object in json {
      guard let text = object["message"] as? String,
            let timestampNum = object["timestamp"] as? NSNumber,
            let userId = object["userId"] as? String else { continue }
      let timestamp = timestampNum.doubleValue
      let isLocalUser = userId == "local"
      let message = TextMessage(
        text: text,
        timestamp: timestamp,
        userID: userId,
        isLocalUser: isLocalUser
      )
      conversation.append(message)
    }

    let smartReply: SmartReply
    if let existing = instances[uid] {
      smartReply = existing
    } else {
      smartReply = SmartReply.smartReply()
      instances[uid] = smartReply
    }

    smartReply.suggestReplies(for: conversation) { suggestionResult, error in
      if let error = error as NSError? {
        result(FlutterError(
          code: "Error \(error.code)",
          message: error.domain,
          details: error.localizedDescription
        ))
        return
      }
      guard let suggestionResult = suggestionResult else {
        result(nil)
        return
      }
      var dict: [String: Any] = ["status": suggestionResult.status.rawValue]
      if suggestionResult.status.rawValue == 0 {  // MLKSmartReplyResultStatusSuccess
        dict["suggestions"] = suggestionResult.suggestions.map { $0.text }
      }
      result(dict)
    }
  }
}
