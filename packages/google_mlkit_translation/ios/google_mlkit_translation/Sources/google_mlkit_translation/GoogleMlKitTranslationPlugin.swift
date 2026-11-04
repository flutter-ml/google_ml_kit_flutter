import Flutter
import MLKitTranslate
import google_mlkit_commons

@objc
public class GoogleMlKitTranslationPlugin: NSObject, FlutterPlugin {
    private var instances: [String: Translator] = [:]
    private var genericModelManager: GenericModelManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "google_mlkit_on_device_translator",
            binaryMessenger: registrar.messenger()
        )
        let instance = GoogleMlKitTranslationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "nlp#startLanguageTranslator":
            handleTranslation(call: call, result: result)
        case "nlp#manageLanguageModelModels":
            manageModel(call: call, result: result)
        case "nlp#closeLanguageTranslator":
            if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
                instances.removeValue(forKey: uid)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(call: FlutterMethodCall) -> Translator? {
        guard let args = call.arguments as? [String: Any],
            let sourceTag = args["source"] as? String,
            let targetTag = args["target"] as? String
        else {
            return nil
        }
        // TranslateLanguage(rawValue:) is non-failable; invalid tags may fail at runtime when the translator is used.
        let sourceLang = TranslateLanguage(rawValue: sourceTag)
        let targetLang = TranslateLanguage(rawValue: targetTag)
        let options = TranslatorOptions(sourceLanguage: sourceLang, targetLanguage: targetLang)
        return Translator.translator(options: options)
    }

    private func handleTranslation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let text = args["text"] as? String,
            let uid = args["id"] as? String
        else {
            result(FlutterError(code: "invalid_args", message: "Missing arguments", details: nil))
            return
        }

        let translator: Translator
        if let existing = instances[uid] {
            translator = existing
        } else {
            guard let newTranslator = initialize(call: call) else {
                result(
                    FlutterError(
                        code: "invalid_args",
                        message: "Missing or invalid source/target language",
                        details: nil
                    ))
                return
            }
            translator = newTranslator
            instances[uid] = translator
        }

        translator.downloadModelIfNeeded { error in
            if let error = error as NSError? {
                result(
                    FlutterError(
                        code: "Error \(error.code)", message: error.domain,
                        details: error.localizedDescription))
                return
            }
            translator.translate(text) { translatedText, error in
                if let error = error as NSError? {
                    result(
                        FlutterError(
                            code: "Error \(error.code)", message: error.domain,
                            details: error.localizedDescription))
                    return
                }
                result(translatedText ?? "")
            }
        }
    }

    private func manageModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let modelTag = args["model"] as? String
        else {
            result(
                FlutterError(code: "invalid_args", message: "Missing model argument", details: nil))
            return
        }
        // TranslateLanguage(rawValue:) is non-failable; invalid tags may fail when the model is used.
        let lang = TranslateLanguage(rawValue: modelTag)
        let model = TranslateRemoteModel.translateRemoteModel(language: lang)
        if genericModelManager == nil {
            genericModelManager = GenericModelManager()
        }
        genericModelManager?.manage(model: model, call: call, result: result)
    }
}
