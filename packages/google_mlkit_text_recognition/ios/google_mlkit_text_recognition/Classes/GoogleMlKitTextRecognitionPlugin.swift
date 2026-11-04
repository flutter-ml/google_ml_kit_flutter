import Flutter
import MLKitVision
import MLKitTextRecognition
import MLKitTextRecognitionCommon
import google_mlkit_commons
#if canImport(MLKitTextRecognitionChinese)
import MLKitTextRecognitionChinese
#endif
#if canImport(MLKitTextRecognitionDevanagari)
import MLKitTextRecognitionDevanagari
#endif
#if canImport(MLKitTextRecognitionJapanese)
import MLKitTextRecognitionJapanese
#endif
#if canImport(MLKitTextRecognitionKorean)
import MLKitTextRecognitionKorean
#endif

@objc
public class GoogleMlKitTextRecognitionPlugin: NSObject, FlutterPlugin {
  private var instances: [String: TextRecognizer] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_text_recognizer",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitTextRecognitionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startTextRecognizer":
      handleDetection(call: call, result: result)
    case "vision#closeTextRecognizer":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(call: FlutterMethodCall) -> TextRecognizer {
    let scriptIndex = (call.arguments as? [String: Any])?["script"] as? Int ?? 0
    switch scriptIndex {
    case 0:
      return TextRecognizer.textRecognizer(options: TextRecognizerOptions())
    case 1:
      #if canImport(MLKitTextRecognitionChinese)
      return TextRecognizer.textRecognizer(options: ChineseTextRecognizerOptions())
      #else
      return TextRecognizer.textRecognizer(options: TextRecognizerOptions())
      #endif
    case 2:
      #if canImport(MLKitTextRecognitionDevanagari)
      return TextRecognizer.textRecognizer(options: DevanagariTextRecognizerOptions())
      #else
      return TextRecognizer.textRecognizer(options: TextRecognizerOptions())
      #endif
    case 3:
      #if canImport(MLKitTextRecognitionJapanese)
      return TextRecognizer.textRecognizer(options: JapaneseTextRecognizerOptions())
      #else
      return TextRecognizer.textRecognizer(options: TextRecognizerOptions())
      #endif
    case 4:
      #if canImport(MLKitTextRecognitionKorean)
      return TextRecognizer.textRecognizer(options: KoreanTextRecognizerOptions())
      #else
      return TextRecognizer.textRecognizer(options: TextRecognizerOptions())
      #endif
    default:
      return TextRecognizer.textRecognizer(options: TextRecognizerOptions())
    }
  }

  private func handleDetection(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let imageData = args["imageData"] as? [String: Any],
          let uid = args["id"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing arguments", details: nil))
      return
    }
    guard let image = VisionImage.visionImage(from: imageData) else {
      result(FlutterError(code: "invalid_image", message: "Invalid or missing image data", details: nil))
      return
    }

    let recognizer: TextRecognizer
    if let existing = instances[uid] {
      recognizer = existing
    } else {
      recognizer = initialize(call: call)
      instances[uid] = recognizer
    }

    recognizer.process(image) { visionText, error in
      if let error = error as NSError? {
        result(FlutterError(code: "Error \(error.code)", message: error.domain, details: error.localizedDescription))
        return
      }
      guard let visionText = visionText else {
        result(["text": "", "blocks": [] as [[String: Any]]])
        return
      }
      var textBlocks: [[String: Any]] = []
      for block in visionText.blocks {
        var blockData = self.addData(
          cornerPoints: block.cornerPoints,
          frame: block.frame,
          languages: block.recognizedLanguages,
          text: block.text,
          confidence: nil,
          angle: nil
        )
        var textLines: [[String: Any]] = []
        for line in block.lines {
          var lineData = self.addData(
            cornerPoints: line.cornerPoints,
            frame: line.frame,
            languages: line.recognizedLanguages,
            text: line.text,
            confidence: nil,
            angle: nil
          )
          var elementsData: [[String: Any]] = []
          for element in line.elements {
            var elementData = self.addData(
              cornerPoints: element.cornerPoints,
              frame: element.frame,
              languages: element.recognizedLanguages,
              text: element.text,
              confidence: nil,
              angle: nil
            )
            elementData["symbols"] = [] as [[String: Any]]
            elementsData.append(elementData)
          }
          lineData["elements"] = elementsData
          textLines.append(lineData)
        }
        blockData["lines"] = textLines
        textBlocks.append(blockData)
      }
      result(["text": visionText.text, "blocks": textBlocks])
    }
  }

  private func addData(
    cornerPoints: [NSValue],
    frame: CGRect,
    languages: [TextRecognizedLanguage],
    text: String,
    confidence: NSNumber?,
    angle: NSNumber?
  ) -> [String: Any] {
    let points = cornerPoints.map { (point: NSValue) -> [String: Double] in
      let cgPoint = point.cgPointValue
      return ["x": Double(cgPoint.x), "y": Double(cgPoint.y)]
    }
    let allLanguageData = languages.compactMap { $0.languageCode }
    return [
      "points": points,
      "rect": [
        "left": Double(frame.origin.x),
        "top": Double(frame.origin.y),
        "right": Double(frame.origin.x + frame.size.width),
        "bottom": Double(frame.origin.y + frame.size.height)
      ] as [String: Double],
      "recognizedLanguages": allLanguageData,
      "text": text,
      "confidence": confidence ?? NSNull(),
      "angle": angle ?? NSNull()
    ]
  }
}
