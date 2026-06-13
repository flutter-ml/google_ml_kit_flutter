import Flutter
import MLKitCommon
import MLKitVision
import MLKitObjectDetection
import MLKitObjectDetectionCommon
import MLKitObjectDetectionCustom
import google_mlkit_commons

#if canImport(MLKitLinkFirebase)
import MLKitLinkFirebase
#endif

@objc
public class GoogleMlKitObjectDetectionPlugin: NSObject, FlutterPlugin {
  private var instances: [String: ObjectDetector] = [:]
  #if canImport(MLKitLinkFirebase)
  private var genericModelManager: GenericModelManager?
  #endif

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_object_detector",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitObjectDetectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startObjectDetector":
      handleDetection(call: call, result: result)
    case "vision#closeObjectDetector":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    case "vision#manageFirebaseModels":
      #if canImport(MLKitLinkFirebase)
      manageModel(call: call, result: result)
      #else
      result(FlutterError(
        code: "ERROR_MISSING_MLKIT_FIREBASE_MODELS",
        message: "Add the GoogleMLKit/LinkFirebase pod to your Podfile to use Firebase-hosted models.",
        details: nil
      ))
      #endif
    default:
      result(FlutterMethodNotImplemented)
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

    let objectDetector: ObjectDetector
    if let existing = instances[uid] {
      objectDetector = existing
    } else {
      guard let dictionary = args["options"] as? [String: Any] else {
        result(FlutterError(code: "invalid_args", message: "Missing options", details: nil))
        return
      }
      guard let detector = createDetector(from: dictionary, result: result) else { return }
      objectDetector = detector
      instances[uid] = objectDetector
    }

    objectDetector.process(image) { objects, error in
      if let error = error as NSError? {
        result(FlutterError(code: "Error \(error.code)", message: error.domain, details: error.localizedDescription))
        return
      }
      guard let objects = objects else {
        result([])
        return
      }
      let objectsData = objects.map { object -> [String: Any] in
        let labels = object.labels.map { label in
          [
            "index": label.index,
            "text": label.text,
            "confidence": label.confidence
          ] as [String: Any]
        }
        var data: [String: Any] = [
          "rect": [
            "left": Double(object.frame.origin.x),
            "top": Double(object.frame.origin.y),
            "right": Double(object.frame.origin.x + object.frame.size.width),
            "bottom": Double(object.frame.origin.y + object.frame.size.height)
          ] as [String: Double],
          "labels": labels
        ]
        if let trackingID = object.trackingID {
          data["trackingId"] = trackingID
        }
        return data
      }
      result(objectsData)
    }
  }

  private func createDetector(from dictionary: [String: Any], result: @escaping FlutterResult) -> ObjectDetector? {
    let type = dictionary["type"] as? String ?? "base"
    switch type {
    case "base":
      return ObjectDetector.objectDetector(options: getDefaultOptions(dictionary))
    case "local":
      guard let options = getLocalOptions(dictionary) else {
        result(FlutterError(code: "invalid_args", message: "Missing path for local model", details: nil))
        return nil
      }
      return ObjectDetector.objectDetector(options: options)
    case "remote":
      #if canImport(MLKitLinkFirebase)
      guard let modelName = dictionary["modelName"] as? String, !modelName.isEmpty else {
        result(FlutterError(
          code: "invalid_args",
          message: "Missing or invalid modelName for remote model",
          details: nil
        ))
        return nil
      }
      if let options = getRemoteOptions(dictionary) {
        return ObjectDetector.objectDetector(options: options)
      }
      result(FlutterError(
        code: "Error Model has not been downloaded yet",
        message: "Model has not been downloaded yet",
        details: "Model has not been downloaded yet"
      ))
      return nil
      #else
      result(FlutterError(
        code: "ERROR_MISSING_MLKIT_FIREBASE_MODELS",
        message: "Add the GoogleMLKit/LinkFirebase pod to your Podfile to use Firebase-hosted models.",
        details: nil
      ))
      return nil
      #endif
    default:
      result(FlutterError(
        code: type,
        message: "Invalid model type: \(type)",
        details: "Invalid model type: \(type)"
      ))
      return nil
    }
  }

  private func getDefaultOptions(_ dictionary: [String: Any]) -> ObjectDetectorOptions {
    let options = ObjectDetectorOptions()
    let mode = (dictionary["mode"] as? NSNumber)?.intValue ?? 0
    options.detectorMode = mode == 0 ? ObjectDetectorMode.stream : ObjectDetectorMode.singleImage
    options.shouldEnableClassification = (dictionary["classify"] as? NSNumber)?.boolValue ?? false
    options.shouldEnableMultipleObjects = (dictionary["multiple"] as? NSNumber)?.boolValue ?? false
    return options
  }

  private func getLocalOptions(_ dictionary: [String: Any]) -> CustomObjectDetectorOptions? {
    guard let path = dictionary["path"] as? String else { return nil }
    let localModel = LocalModel(path: path)
    let options = CustomObjectDetectorOptions(localModel: localModel)
    let mode = (dictionary["mode"] as? NSNumber)?.intValue ?? 0
    options.detectorMode = mode == 0 ? ObjectDetectorMode.stream : ObjectDetectorMode.singleImage
    options.shouldEnableClassification = (dictionary["classify"] as? NSNumber)?.boolValue ?? false
    options.shouldEnableMultipleObjects = (dictionary["multiple"] as? NSNumber)?.boolValue ?? false
    if let threshold = dictionary["threshold"] as? NSNumber {
      options.classificationConfidenceThreshold = threshold
    }
    if let maxLabels = dictionary["maxLabels"] as? NSNumber {
      options.maxPerObjectLabelCount = maxLabels.intValue
    }
    return options
  }

  #if canImport(MLKitLinkFirebase)
  private func getRemoteOptions(_ dictionary: [String: Any]) -> CustomObjectDetectorOptions? {
    guard let modelName = dictionary["modelName"] as? String else { return nil }
    let firebaseModelSource = FirebaseModelSource(name: modelName)
    let remoteModel = CustomRemoteModel(remoteModelSource: firebaseModelSource)
    guard ModelManager.modelManager().isModelDownloaded(remoteModel) else {
      return nil
    }
    let options = CustomObjectDetectorOptions(remoteModel: remoteModel)
    let mode = (dictionary["mode"] as? NSNumber)?.intValue ?? 0
    options.detectorMode = mode == 0 ? ObjectDetectorMode.stream : ObjectDetectorMode.singleImage
    options.shouldEnableClassification = (dictionary["classify"] as? NSNumber)?.boolValue ?? false
    options.shouldEnableMultipleObjects = (dictionary["multiple"] as? NSNumber)?.boolValue ?? false
    if let threshold = dictionary["threshold"] as? NSNumber {
      options.classificationConfidenceThreshold = threshold
    }
    if let maxLabels = dictionary["maxLabels"] as? NSNumber {
      options.maxPerObjectLabelCount = maxLabels.intValue
    }
    return options
  }

  private func manageModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let modelTag = args["model"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing model argument", details: nil))
      return
    }
    let firebaseModelSource = FirebaseModelSource(name: modelTag)
    let model = CustomRemoteModel(remoteModelSource: firebaseModelSource)
    let manager = GenericModelManager()
    genericModelManager = manager
    manager.manage(model: model, call: call, result: result)
  }
  #endif
}
