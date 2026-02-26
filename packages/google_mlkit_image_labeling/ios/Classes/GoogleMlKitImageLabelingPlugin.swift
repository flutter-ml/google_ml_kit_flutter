import Flutter
import MLKitCommon
import MLKitVision
import MLKitImageLabeling
import MLKitImageLabelingCommon
import MLKitImageLabelingCustom
import google_mlkit_commons

#if canImport(MLKitLinkFirebase)
import MLKitLinkFirebase
#endif

@objc
public class GoogleMlKitImageLabelingPlugin: NSObject, FlutterPlugin {
  private var instances: [String: ImageLabeler] = [:]
  #if canImport(MLKitLinkFirebase)
  private var genericModelManager: GenericModelManager?
  #endif

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_image_labeler",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitImageLabelingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startImageLabelDetector":
      handleDetection(call: call, result: result)
    case "vision#closeImageLabelDetector":
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

    let labeler: ImageLabeler
    if let existing = instances[uid] {
      labeler = existing
    } else {
      guard let dictionary = args["options"] as? [String: Any] else {
        result(FlutterError(code: "invalid_args", message: "Missing options", details: nil))
        return
      }
      let type = dictionary["type"] as? String ?? "base"
      switch type {
      case "base":
        labeler = ImageLabeler.imageLabeler(options: getDefaultOptions(dictionary))
      case "local":
        guard let options = getLocalOptions(dictionary) else {
          result(FlutterError(code: "invalid_args", message: "Missing path for local model", details: nil))
          return
        }
        labeler = ImageLabeler.imageLabeler(options: options)
      case "remote":
        #if canImport(MLKitLinkFirebase)
        guard let modelName = dictionary["modelName"] as? String, !modelName.isEmpty else {
          result(FlutterError(
            code: "invalid_args",
            message: "Missing or invalid modelName for remote model",
            details: nil
          ))
          return
        }
        if let options = getRemoteOptions(dictionary) {
          labeler = ImageLabeler.imageLabeler(options: options)
        } else {
          result(FlutterError(
            code: "Error Model has not been downloaded yet",
            message: "Model has not been downloaded yet",
            details: "Model has not been downloaded yet"
          ))
          return
        }
        #else
        result(FlutterError(
          code: "ERROR_MISSING_MLKIT_FIREBASE_MODELS",
          message: "Add the GoogleMLKit/LinkFirebase pod to your Podfile to use Firebase-hosted models.",
          details: nil
        ))
        return
        #endif
      default:
        result(FlutterError(
          code: type,
          message: "Invalid model type: \(type)",
          details: "Invalid model type: \(type)"
        ))
        return
      }
      instances[uid] = labeler
    }

    labeler.process(image) { labels, error in
      if let error = error as NSError? {
        result(FlutterError(code: "Error \(error.code)", message: error.domain, details: error.localizedDescription))
        return
      }
      guard let labels = labels else {
        result([])
        return
      }
      let labelData = labels.map { label in
        [
          "confidence": label.confidence,
          "index": label.index,
          "text": label.text
        ] as [String: Any]
      }
      result(labelData)
    }
  }

  private func getDefaultOptions(_ optionsData: [String: Any]) -> ImageLabelerOptions {
    let options = ImageLabelerOptions()
    if let conf = optionsData["confidenceThreshold"] as? NSNumber {
      options.confidenceThreshold = conf
    }
    return options
  }

  private func getLocalOptions(_ optionsData: [String: Any]) -> CustomImageLabelerOptions? {
    guard let path = optionsData["path"] as? String else { return nil }
    let localModel = LocalModel(path: path)
    let options = CustomImageLabelerOptions(localModel: localModel)
    if let conf = optionsData["confidenceThreshold"] as? NSNumber {
      options.confidenceThreshold = conf
    }
    if let maxCount = optionsData["maxCount"] as? NSNumber {
      options.maxResultCount = maxCount.intValue
    }
    return options
  }

  #if canImport(MLKitLinkFirebase)
  private func getRemoteOptions(_ optionsData: [String: Any]) -> CustomImageLabelerOptions? {
    guard let modelName = optionsData["modelName"] as? String else { return nil }
    let firebaseModelSource = FirebaseModelSource(name: modelName)
    let remoteModel = CustomRemoteModel(remoteModelSource: firebaseModelSource)
    guard ModelManager.modelManager().isModelDownloaded(remoteModel) else {
      return nil
    }
    let options = CustomImageLabelerOptions(remoteModel: remoteModel)
    if let conf = optionsData["confidenceThreshold"] as? NSNumber {
      options.confidenceThreshold = conf
    }
    if let maxCount = optionsData["maxCount"] as? NSNumber {
      options.maxResultCount = maxCount.intValue
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
