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
        
        // no text provided, return empty result
        guard let textSafe = text else {
            return result({})
        }
        
        // identify language on text
        languageId.identifyLanguage(for: textSafe) { (languageCode, error) in
            if let error = error {
                print("Failed with error: \(error)")
                return result(FlutterError(code: "idenfity_error",
                                    message: "error while identifying language: \(error)",
                                    details: nil)
                )
            }
            

            // success case
            if let languageCode = languageCode, languageCode != "und" {
                return result(languageCode)
            } else {
                // "und" <=> undetermined
                print("No language was identified")
                return result({})
            }
        }
    }
    
    
    
    private func identifyLanguages(text: String?, result: @escaping FlutterResult) {
        // https://firebase.google.com/docs/ml-kit/ios/identify-languages#get-the-possible-languages-of-a-string
        let languageId = LanguageIdentification.languageIdentification()

        // no text provided, return empty result
        guard let textSafe = text else {
            return result({})
        }
        
        // identify languages on text
        languageId.identifyPossibleLanguages(for: textSafe) { (identifiedLanguages, error) in
            
            if let error = error {
                print("Failed with error: \(error)")
                return result(FlutterError(code: "idenfity_error",
                                    message: "error while identifying language: \(error)",
                                    details: nil)
                )
            }
            
            guard let identifiedLanguages = identifiedLanguages,
                !identifiedLanguages.isEmpty,
                identifiedLanguages[0].languageTag != "und"
                else {
                    print("No languages were identified")
                    // no language detected
                    result([])
                    return
            }

            // serialize result
            let serializedResult = identifiedLanguages.map({ (identifiedLanguage) -> [String: Any] in
                return [
                    "languageCode": identifiedLanguage.languageTag,
                    "confidence": identifiedLanguage.confidence,
                ]
            })
            
            return result(serializedResult)
        }
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "identifyLanguage":
            identifyLanguage(text: call.arguments as? String, result: result)
        case "identifyLanguages":
            identifyLanguages(text: call.arguments as? String, result: result)
        default:
            return result(FlutterMethodNotImplemented)
        }
    }
}

