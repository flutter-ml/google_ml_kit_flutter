import Flutter
import MLKitVision
import MLKitSegmentationSelfie
import MLKitSegmentationCommon
import google_mlkit_commons

@objc
public class GoogleMlKitSelfieSegmentationPlugin: NSObject, FlutterPlugin {
  private var instances: [String: Segmenter] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_selfie_segmenter",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitSelfieSegmentationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startSelfieSegmenter":
      handleDetection(call: call, result: result)
    case "vision#closeSelfieSegmenter":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(call: FlutterMethodCall) -> Segmenter? {
    guard let args = call.arguments as? [String: Any] else { return nil }
    let isStream = (args["isStream"] as? NSNumber)?.boolValue ?? false
    let enableRawSizeMask = (args["enableRawSizeMask"] as? NSNumber)?.boolValue ?? false
    let options = SelfieSegmenterOptions()
    options.segmenterMode = isStream ? .stream : .singleImage
    options.shouldEnableRawSizeMask = enableRawSizeMask
    return Segmenter.segmenter(options: options)
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

    let segmenter: Segmenter
    if let existing = instances[uid] {
      segmenter = existing
    } else {
      guard let newSegmenter = initialize(call: call) else {
        result(FlutterError(code: "invalid_args", message: "Invalid options", details: nil))
        return
      }
      segmenter = newSegmenter
      instances[uid] = segmenter
    }

    segmenter.process(image) { mask, error in
      if let error = error as NSError? {
        result(FlutterError(code: "Error \(error.code)", message: error.domain, details: error.localizedDescription))
        return
      }
      guard let mask = mask else {
        result(nil)
        return
      }
      let width = CVPixelBufferGetWidth(mask.buffer)
      let height = CVPixelBufferGetHeight(mask.buffer)
      CVPixelBufferLockBaseAddress(mask.buffer, .readOnly)
      let maskBytesPerRow = CVPixelBufferGetBytesPerRow(mask.buffer)
      guard let baseAddress = CVPixelBufferGetBaseAddress(mask.buffer) else {
        CVPixelBufferUnlockBaseAddress(mask.buffer, .readOnly)
        result(FlutterError(code: "error", message: "Failed to get pixel buffer base address", details: nil))
        return
      }
      let maskAddress = baseAddress.assumingMemoryBound(to: Float.self)
      var confidences: [NSNumber] = []
      var rowAddress = maskAddress
      for _ in 0..<height {
        for col in 0..<Int(width) {
          confidences.append(NSNumber(value: rowAddress[col]))
        }
        rowAddress = rowAddress.advanced(by: maskBytesPerRow / MemoryLayout<Float>.size)
      }
      CVPixelBufferUnlockBaseAddress(mask.buffer, .readOnly)
      result([
        "width": width,
        "height": height,
        "confidences": confidences
      ])
    }
  }
}
