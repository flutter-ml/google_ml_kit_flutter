import Flutter
import UIKit
// import of Firebase is done via magical Brige-Header

public class SwiftFirebaseLanguageidPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "firebase_languageid", binaryMessenger: registrar.messenger())
        let instance = SwiftFirebaseLanguageidPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func identifyLanguage(text: String?, result: @escaping FlutterResult) {
        // https://firebase.google.com/docs/ml-kit/ios/identify-languages#identify-the-language-of-a-string
        let languageId = LanguageIdentification.languageIdentification()
        
        guard let textSafe = text else {
            // TODO:
            result(FlutterError(code: "CAST_ERROR",
                                message: "Battery info unavailable",
                                details: nil)
            )
            return
        }
        
        languageId.identifyLanguage(for: textSafe) { (languageCode, error) in
            if let error = error {
                print("Failed with error: \(error)")
                return
            }
            

            if let languageCode = languageCode, languageCode != "und" {
                print("Identified Language: \(languageCode)")
                result(languageCode)
            } else {
                // https://firebase.google.com/docs/ml-kit/identify-languages
                // "und" <=> undetermined
                print("No language was identified")
                // TODO:
                result({})
            }
        }
    }
    
    
    
    private func identifyLanguages(text: String?, result: @escaping FlutterResult) {
        // https://firebase.google.com/docs/ml-kit/ios/identify-languages#get-the-possible-languages-of-a-string
        let languageId = LanguageIdentification.languageIdentification()

        guard let text = text else {
            // TODO: no guard needed here
            result(FlutterError(code: "CAST_ERROR",
                                message: "Battery info unavailable",
                                details: nil)
            )
            return
        }
        
        languageId.identifyPossibleLanguages(for: text) { (identifiedLanguages, error) in
            
            if let error = error {
                print("Failed with error: \(error)")
                result(FlutterError(code: "DETECTION_ERROR",
                                    message: error.localizedDescription,
                                    details: nil)
                )
                return
            }
            
            guard let identifiedLanguages = identifiedLanguages,
                !identifiedLanguages.isEmpty,
                identifiedLanguages[0].languageTag != "und"
                else {
                    // no language detected
                    result([])
                    return
            }
            
            let serializedResult = identifiedLanguages.map({ (identifiedLanguage) -> [String: Any] in
                return [
                    "languageCode": identifiedLanguage.languageTag,
                    "confidence": identifiedLanguage.confidence,
                ]
            })
            
            result(serializedResult)
        }
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "identifyLanguage":
            identifyLanguage(text: call.arguments as? String, result: result)
        case "identifyLanguages":
            identifyLanguages(text: call.arguments as? String, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

