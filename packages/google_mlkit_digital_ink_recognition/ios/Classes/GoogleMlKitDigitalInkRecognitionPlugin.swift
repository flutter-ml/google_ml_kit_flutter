import Flutter
import MLKitCommon
import MLKitDigitalInkRecognition
import google_mlkit_commons

@objc
public class GoogleMlKitDigitalInkRecognitionPlugin: NSObject, FlutterPlugin {
  private var instances: [String: DigitalInkRecognizer] = [:]
  private var genericModelManager: GenericModelManager?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_digital_ink_recognizer",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitDigitalInkRecognitionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startDigitalInkRecognizer":
      handleDetection(call: call, result: result)
    case "vision#manageInkModels":
      manageModel(call: call, result: result)
    case "vision#closeDigitalInkRecognizer":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleDetection(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let modelTag = args["model"] as? String,
          let uid = args["id"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing arguments", details: nil))
      return
    }

    guard let identifier = DigitalInkRecognitionModelIdentifier(forLanguageTag: modelTag) else {
      result(FlutterError(code: "invalid_model", message: "Invalid language tag: \(modelTag)", details: nil))
      return
    }
    let model = DigitalInkRecognitionModel(modelIdentifier: identifier)
    guard ModelManager.modelManager().isModelDownloaded(model) else {
      result(FlutterError(
        code: "Error Model has not been downloaded yet",
        message: "Model has not been downloaded yet",
        details: "Model has not been downloaded yet"
      ))
      return
    }

    let recognizer: DigitalInkRecognizer
    if let existing = instances[uid] {
      recognizer = existing
    } else {
      let options = DigitalInkRecognizerOptions(model: model)
      recognizer = DigitalInkRecognizer.digitalInkRecognizer(options: options)
      instances[uid] = recognizer
    }

    guard let strokeList = args["ink"] as? [String: Any],
          let strokesData = strokeList["strokes"] as? [[String: Any]] else {
      result(FlutterError(code: "invalid_args", message: "Missing ink data", details: nil))
      return
    }
    let strokes = strokesData.map { strokeMap -> Stroke in
      guard let pointsList = strokeMap["points"] as? [[String: Any]] else {
        return Stroke(points: [])
      }
      let points = pointsList.map { pointMap -> StrokePoint in
        let coordX = (pointMap["x"] as? NSNumber)?.floatValue ?? 0
        let coordY = (pointMap["y"] as? NSNumber)?.floatValue ?? 0
        let timeMs = (pointMap["t"] as? NSNumber)?.intValue ?? 0
        return StrokePoint(x: coordX, y: coordY, t: timeMs)
      }
      return Stroke(points: points)
    }
    let ink = Ink(strokes: strokes)

    let contextMap = args["context"] as? [String: Any]
    var context: DigitalInkRecognitionContext?
    if let ctx = contextMap {
      let preContext = ctx["preContext"] as? String ?? ""
      var writingArea: WritingArea?
      if let writingAreaMap = ctx["writingArea"] as? [String: Any],
         let width = writingAreaMap["width"] as? NSNumber,
         let height = writingAreaMap["height"] as? NSNumber {
        writingArea = WritingArea(width: width.floatValue, height: height.floatValue)
      }
      context = DigitalInkRecognitionContext(preContext: preContext, writingArea: writingArea)
    }

    func process(recognitionResult: DigitalInkRecognitionResult?, error: Error?) {
      if let error = error {
        let nsError = error as NSError
        result(FlutterError(
          code: "Error \(nsError.code)",
          message: nsError.domain,
          details: nsError.localizedDescription
        ))
        return
      }
      guard let recognitionResult = recognitionResult else {
        result(nil)
        return
      }
      let candidates = recognitionResult.candidates.map { candidate in
        [
          "text": candidate.text,
          "score": candidate.score?.doubleValue ?? 0
        ] as [String: Any]
      }
      result(candidates)
    }

    if let ctx = context {
      recognizer.recognize(ink: ink, context: ctx) { recognitionResult, error in
        process(recognitionResult: recognitionResult, error: error)
      }
    } else {
      recognizer.recognize(ink: ink) { recognitionResult, error in
        process(recognitionResult: recognitionResult, error: error)
      }
    }
  }

  private func manageModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let modelTag = args["model"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing model argument", details: nil))
      return
    }
    guard let identifier = DigitalInkRecognitionModelIdentifier(forLanguageTag: modelTag) else {
      result(FlutterError(code: "invalid_model", message: "Invalid language tag: \(modelTag)", details: nil))
      return
    }
    let model = DigitalInkRecognitionModel(modelIdentifier: identifier)
    let manager = GenericModelManager()
    genericModelManager = manager
    manager.manage(model: model, call: call, result: result)
  }
}
