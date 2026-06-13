import Flutter
import MLKitCommon

@objc
public class GenericModelManager: NSObject {
  /// Tracks observer tokens and callback per in-flight download so we remove observers and avoid overwriting callbacks.
  private var pendingDownloads: [ObjectIdentifier: PendingDownload] = [:]
  /// Observer tokens by key so we can always remove them in completeDownload,
  /// even when pending was already consumed (e.g. duplicate notification).
  private var observerTokensByKey: [ObjectIdentifier: (success: NSObjectProtocol, fail: NSObjectProtocol)] = [:]
  private let pendingDownloadsLock = NSLock()

  @objc(manageModel:call:result:)
  public func manage(
    model: RemoteModel,
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    let modelManager = ModelManager.modelManager()
    guard let task = call.arguments as? [String: Any],
          let taskName = task["task"] as? String else {
      result(FlutterMethodNotImplemented)
      return
    }

    switch taskName {
    case "download":
      if modelManager.isModelDownloaded(model) {
        result("success")
        return
      }
      let modelObject = model as AnyObject
      let key = ObjectIdentifier(modelObject)
      do {
        pendingDownloadsLock.lock()
        defer { pendingDownloadsLock.unlock() }
        if pendingDownloads[key] != nil {
          result(FlutterError(
            code: "download_in_progress",
            message: "A download for this model is already in progress",
            details: nil
          ))
          return
        }
        let successToken = NotificationCenter.default.addObserver(
          forName: Notification.Name.mlkitModelDownloadDidSucceed,
          object: model,
          queue: .main
        ) { [weak self] _ in
          self?.completeDownload(key: key, success: true)
        }
        let failToken = NotificationCenter.default.addObserver(
          forName: Notification.Name.mlkitModelDownloadDidFail,
          object: model,
          queue: .main
        ) { [weak self] _ in
          self?.completeDownload(key: key, success: false)
        }
        pendingDownloads[key] = PendingDownload(
          successToken: successToken,
          failToken: failToken,
          result: result
        )
        observerTokensByKey[key] = (success: successToken, fail: failToken)
      }
      // Call download after releasing the lock so a synchronous notification cannot deadlock
      // (completeDownload needs the lock). pendingDownloads is already populated above.
      let conditions = ModelDownloadConditions(
        allowsCellularAccess: true,
        allowsBackgroundDownloading: true
      )
      modelManager.download(model, conditions: conditions)

    case "delete":
      modelManager.deleteDownloadedModel(model) { error in
        if error == nil {
          result("success")
        } else {
          result("error")
        }
      }

    case "check":
      let isDownloaded = modelManager.isModelDownloaded(model)
      result(isDownloaded)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Removes observers for this download and invokes the stored callback once. Called on main queue.
  /// Always removes observer tokens when present so we don't leak them if both success and fail fire (race).
  private func completeDownload(key: ObjectIdentifier, success: Bool) {
    pendingDownloadsLock.lock()
    let pending = pendingDownloads.removeValue(forKey: key)
    let tokens = observerTokensByKey.removeValue(forKey: key)
    pendingDownloadsLock.unlock()
    if let tokens = tokens {
      NotificationCenter.default.removeObserver(tokens.success)
      NotificationCenter.default.removeObserver(tokens.fail)
    }
    if let pending = pending {
      pending.result(success ? "success" : "error")
    }
  }

  deinit {
    pendingDownloadsLock.lock()
    let copyPending = pendingDownloads
    let copyTokens = observerTokensByKey
    pendingDownloads.removeAll()
    observerTokensByKey.removeAll()
    pendingDownloadsLock.unlock()
    for (_, tokens) in copyTokens {
      NotificationCenter.default.removeObserver(tokens.success)
      NotificationCenter.default.removeObserver(tokens.fail)
    }
    for pending in copyPending.values {
      pending.result(FlutterError(
        code: "cancelled",
        message: "Model manager deallocated during download",
        details: nil
      ))
    }
  }
}

private final class PendingDownload {
  let successToken: NSObjectProtocol
  let failToken: NSObjectProtocol
  let result: FlutterResult

  init(successToken: NSObjectProtocol, failToken: NSObjectProtocol, result: @escaping FlutterResult) {
    self.successToken = successToken
    self.failToken = failToken
    self.result = result
  }
}
