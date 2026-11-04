import Flutter
import MLKitLanguageID
import google_mlkit_commons

@objc
public class GoogleMlKitLanguageIdPlugin: NSObject, FlutterPlugin {
  private var instances: [String: LanguageIdentification] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_language_identifier",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitLanguageIdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "nlp#startLanguageIdentifier":
      handleDetection(call: call, result: result)
    case "nlp#closeLanguageIdentifier":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(call: FlutterMethodCall) -> LanguageIdentification? {
    guard let args = call.arguments as? [String: Any],
          let confidence = args["confidence"] as? NSNumber else { return nil }
    let options = LanguageIdentificationOptions(confidenceThreshold: confidence.floatValue)
    return LanguageIdentification.languageIdentification(options: options)
  }

  private func handleDetection(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let uid = args["id"] as? String,
          let text = args["text"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing arguments", details: nil))
      return
    }

    let languageId: LanguageIdentification
    if let existing = instances[uid] {
      languageId = existing
    } else {
      guard let newLanguageId = initialize(call: call) else {
        result(FlutterError(code: "invalid_args", message: "Invalid options", details: nil))
        return
      }
      languageId = newLanguageId
      instances[uid] = languageId
    }

    let possibleLanguages = (args["possibleLanguages"] as? NSNumber)?.boolValue ?? false
    if possibleLanguages {
      identifyPossibleLanguages(in: text, languageId: languageId, result: result)
    } else {
      identifyLanguage(in: text, languageId: languageId, result: result)
    }
  }

  private func identifyPossibleLanguages(
    in text: String,
    languageId: LanguageIdentification,
    result: @escaping FlutterResult
  ) {
    languageId.identifyPossibleLanguages(for: text) { identifiedLanguages, error in
      if let error = error as NSError? {
        result(FlutterError(
          code: "Error \(error.code)",
          message: error.domain,
          details: error.localizedDescription
        ))
        return
      }
      guard let list = identifiedLanguages else {
        result([])
        return
      }
      let resultArray = list.map { (lang: IdentifiedLanguage) -> [String: Any] in
        ["language": lang.languageTag, "confidence": NSNumber(value: lang.confidence)]
      }
      result(resultArray)
    }
  }

  private func identifyLanguage(
    in text: String,
    languageId: LanguageIdentification,
    result: @escaping FlutterResult
  ) {
    languageId.identifyLanguage(for: text) { languageTag, error in
      if let error = error as NSError? {
        result(FlutterError(
          code: "Error \(error.code)",
          message: error.domain,
          details: error.localizedDescription
        ))
        return
      }
      result(languageTag)
    }
  }
}
