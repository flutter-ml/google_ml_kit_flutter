import Flutter
import MLKitVision
import MLKitTextRecognition
import MLKitTextRecognitionCommon
import google_mlkit_commons
import Vision
import UIKit
import CoreGraphics
import CoreImage
import CoreVideo
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

    let visionConfidences = self.computeVisionConfidences(from: imageData)

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
          var elementsData: [[String: Any]] = []
          var elementConfidences: [Float] = []
          for element in line.elements {
            let elementConfidence = self.matchConfidence(
              for: element.frame,
              in: visionConfidences
            )
            var elementData = self.addData(
              cornerPoints: element.cornerPoints,
              frame: element.frame,
              languages: element.recognizedLanguages,
              text: element.text,
              confidence: elementConfidence.map { NSNumber(value: $0) },
              angle: self.angle(from: element.cornerPoints)
            )
            elementData["symbols"] = [] as [[String: Any]]
            elementsData.append(elementData)
            if let c = elementConfidence { elementConfidences.append(c) }
          }
          let lineConfidence: NSNumber? = elementConfidences.isEmpty
            ? self.matchConfidence(for: line.frame, in: visionConfidences).map { NSNumber(value: $0) }
            : NSNumber(value: elementConfidences.reduce(0, +) / Float(elementConfidences.count))
          var lineData = self.addData(
            cornerPoints: line.cornerPoints,
            frame: line.frame,
            languages: line.recognizedLanguages,
            text: line.text,
            confidence: lineConfidence,
            angle: self.angle(from: line.cornerPoints)
          )
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

  /// Derives rotation angle in degrees from the top-left → top-right corner vector.
  /// MLKit returns cornerPoints clockwise starting top-left, so index 0→1 spans the top edge.
  private func angle(from cornerPoints: [NSValue]) -> NSNumber? {
    guard cornerPoints.count >= 2 else { return nil }
    let p0 = cornerPoints[0].cgPointValue
    let p1 = cornerPoints[1].cgPointValue
    let radians = atan2(p1.y - p0.y, p1.x - p0.x)
    return NSNumber(value: Double(radians) * 180.0 / .pi)
  }

  // MARK: - Apple Vision confidence pass

  private struct VisionConfidenceRect {
    let rect: CGRect
    let confidence: Float
  }

  /// Runs Apple's VNRecognizeTextRequest on the same image and returns observations
  /// in MLKit's pixel/top-left coordinate space so they can be matched by IoU.
  /// Returns empty array on failure — confidence stays nil, behavior degrades to pre-fork state.
  private func computeVisionConfidences(from imageData: [String: Any]) -> [VisionConfidenceRect] {
    guard let cgImage = Self.cgImage(from: imageData) else { return [] }
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
    do {
      try handler.perform([request])
    } catch {
      return []
    }
    guard let observations = request.results else { return [] }
    let width = CGFloat(cgImage.width)
    let height = CGFloat(cgImage.height)
    return observations.compactMap { obs in
      let bbox = obs.boundingBox  // normalized, bottom-left origin
      let pixelRect = CGRect(
        x: bbox.minX * width,
        y: (1.0 - bbox.maxY) * height,
        width: bbox.width * width,
        height: bbox.height * height
      )
      let confidence = obs.topCandidates(1).first?.confidence ?? obs.confidence
      return VisionConfidenceRect(rect: pixelRect, confidence: confidence)
    }
  }

  /// Finds the Vision observation with highest IoU against the MLKit element/line frame.
  /// Returns nil if no observation reaches the overlap threshold.
  private func matchConfidence(for frame: CGRect, in rects: [VisionConfidenceRect]) -> Float? {
    guard !rects.isEmpty, frame.width > 0, frame.height > 0 else { return nil }
    var bestIoU: CGFloat = 0
    var bestConfidence: Float? = nil
    for entry in rects {
      let intersection = frame.intersection(entry.rect)
      if intersection.isNull || intersection.isEmpty { continue }
      let interArea = intersection.width * intersection.height
      let unionArea = frame.width * frame.height + entry.rect.width * entry.rect.height - interArea
      guard unionArea > 0 else { continue }
      let iou = interArea / unionArea
      if iou > bestIoU {
        bestIoU = iou
        bestConfidence = entry.confidence
      }
    }
    return bestIoU >= 0.3 ? bestConfidence : nil
  }

  // MARK: - CGImage extraction from imageData

  /// Mirrors VisionImage.visionImage(from:) but exposes the underlying CGImage
  /// so Apple Vision can process the same pixels MLKit consumed.
  private static func cgImage(from imageData: [String: Any]) -> CGImage? {
    guard let imageType = imageData["type"] as? String else { return nil }
    switch imageType {
    case "file":
      guard let path = imageData["path"] as? String,
            let ui = UIImage(contentsOfFile: path) else { return nil }
      return ui.cgImage
    case "bytes":
      return cgImageFromBytes(imageData)
    case "bitmap":
      return cgImageFromBitmap(imageData)
    default:
      return nil
    }
  }

  private static func cgImageFromBytes(_ imageData: [String: Any]) -> CGImage? {
    guard let byteData = imageData["bytes"] as? FlutterStandardTypedData,
          let metadata = imageData["metadata"] as? [String: Any],
          let width = metadata["width"] as? NSNumber,
          let height = metadata["height"] as? NSNumber,
          let rawFormat = metadata["image_format"] as? NSNumber,
          let bytesPerRow = metadata["bytes_per_row"] as? NSNumber else {
      return nil
    }
    let w = Int(truncating: width)
    let h = Int(truncating: height)
    let bpr = Int(truncating: bytesPerRow)
    let format = OSType(truncating: rawFormat)
    let bufferSize = bpr * h
    guard bufferSize > 0, byteData.data.count >= bufferSize else { return nil }

    let copy = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: 1)
    let buf = UnsafeMutableBufferPointer(start: copy.assumingMemoryBound(to: UInt8.self), count: bufferSize)
    byteData.data.copyBytes(to: buf)

    var pxBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreateWithBytes(
      kCFAllocatorDefault,
      w, h, format,
      copy, bpr,
      { _, baseAddress in
        guard let baseAddress = baseAddress else { return }
        UnsafeMutableRawPointer(mutating: baseAddress).deallocate()
      },
      nil, nil, &pxBuffer
    )
    guard status == kCVReturnSuccess, let buffer = pxBuffer else {
      copy.deallocate()
      return nil
    }
    let ciImage = CIImage(cvPixelBuffer: buffer)
    let context = CIContext(options: nil)
    return context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: w, height: h))
  }

  private static func cgImageFromBitmap(_ imageDict: [String: Any]) -> CGImage? {
    guard let bitmapData = imageDict["bitmapData"] as? FlutterStandardTypedData else { return nil }
    if let metadata = imageDict["metadata"] as? [String: Any],
       let width = metadata["width"] as? NSNumber,
       let height = metadata["height"] as? NSNumber {
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bytesPerPixel = 4
      let bpr = bytesPerPixel * width.intValue
      var result: CGImage?
      bitmapData.data.withUnsafeBytes { raw in
        guard let base = raw.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
        guard let ctx = CGContext(
          data: UnsafeMutableRawPointer(mutating: base),
          width: width.intValue,
          height: height.intValue,
          bitsPerComponent: 8,
          bytesPerRow: bpr,
          space: colorSpace,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return }
        result = ctx.makeImage()
      }
      if let result = result { return result }
    }
    return UIImage(data: bitmapData.data)?.cgImage
  }
}

