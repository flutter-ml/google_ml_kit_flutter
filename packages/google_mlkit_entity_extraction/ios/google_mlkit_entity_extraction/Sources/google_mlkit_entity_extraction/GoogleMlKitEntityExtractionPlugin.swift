import Flutter
import google_mlkit_commons

#if canImport(MLKitEntityExtraction)
    import MLKitEntityExtraction
#endif

@objc
public class GoogleMlKitEntityExtractionPlugin: NSObject, FlutterPlugin {
    private var instances: [String: Any] = [:]
    private var genericModelManager: GenericModelManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "google_mlkit_entity_extractor",
            binaryMessenger: registrar.messenger()
        )
        let instance = GoogleMlKitEntityExtractionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        #if canImport(MLKitEntityExtraction)
            switch call.method {
            case "nlp#startEntityExtractor":
                handleDetection(call: call, result: result)
            case "nlp#manageEntityExtractionModels":
                manageModel(call: call, result: result)
            case "nlp#closeEntityExtractor":
                if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
                    instances.removeValue(forKey: uid)
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        #else
            let unimplemented = FlutterError(
                code: "UNIMPLEMENTED",
                message: "MLKitEntityExtraction is not available via Swift Package Manager on iOS",
                details: nil
            )
            switch call.method {
            case "nlp#closeEntityExtractor":
                if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
                    instances.removeValue(forKey: uid)
                }
                result(nil)
            default:
                result(unimplemented)
            }
        #endif
    }

    #if canImport(MLKitEntityExtraction)
        private func handleDetection(call: FlutterMethodCall, result: @escaping FlutterResult) {
            guard let args = call.arguments as? [String: Any],
                let text = args["text"] as? String,
                let uid = args["id"] as? String
            else {
                result(
                    FlutterError(code: "invalid_args", message: "Missing arguments", details: nil))
                return
            }

            let entityExtractor: EntityExtractor
            if let existing = instances[uid] as? EntityExtractor {
                entityExtractor = existing
            } else {
                guard let language = args["language"] as? String else {
                    result(
                        FlutterError(
                            code: "invalid_args", message: "Missing language", details: nil))
                    return
                }
                let modelIdentifier = EntityExtractionModelIdentifier(rawValue: language)
                let options = EntityExtractorOptions(modelIdentifier: modelIdentifier)
                entityExtractor = EntityExtractor.entityExtractor(options: options)
                instances[uid] = entityExtractor
            }

            let params = EntityExtractionParams()
            let parametersRaw = args["parameters"]
            let parameters: [String: Any] =
                (parametersRaw is NSNull) ? [:] : (parametersRaw as? [String: Any]) ?? [:]
            if let timezone = valueAsString(parameters["timezone"]), !timezone.isEmpty {
                params.referenceTimeZone = TimeZone(abbreviation: timezone)
            }
            if let time = valueAsNumber(parameters["time"]) {
                params.referenceTime = Date(timeIntervalSince1970: time.doubleValue / 1000)
            }
            if let locale = valueAsString(parameters["locale"]), !locale.isEmpty {
                params.preferredLocale = Locale(identifier: locale)
            }
            if let filtersValues = valueAsNumberArray(parameters["filters"]), !filtersValues.isEmpty {
                let filters: Set<EntityType> = Set(
                    filtersValues.compactMap { numberToEntityType($0.intValue) })
                params.typesFilter = filters
            }

            entityExtractor.downloadModelIfNeeded { error in
                if let error = error as NSError? {
                    result(
                        FlutterError(
                            code: "Error \(error.code)", message: error.domain,
                            details: error.localizedDescription))
                    return
                }
                entityExtractor.annotateText(text, params: params) { annotations, error in
                    if let error = error as NSError? {
                        result(
                            FlutterError(
                                code: "Error \(error.code)", message: error.domain,
                                details: error.localizedDescription))
                        return
                    }
                    guard let annotations = annotations else {
                        result(nil)
                        return
                    }
                    let allAnnotations = annotations.map { annotation -> [String: Any] in
                        let range = annotation.range
                        let substring = (text as NSString).substring(with: range)
                        let entities = annotation.entities.map { entity in
                            self.entityToDictionary(text: text, entity: entity)
                        }
                        return [
                            "text": substring,
                            "start": range.location,
                            "end": range.location + range.length,
                            "entities": entities
                        ]
                    }
                    result(allAnnotations)
                }
            }
        }

        private func numberToEntityType(_ value: Int) -> EntityType? {
            switch value {
            case 1: return .address
            case 2: return .dateTime
            case 3: return .email
            case 4: return .flightNumber
            case 5: return .IBAN
            case 6: return .ISBN
            case 7: return .paymentCard
            case 8: return .phone
            case 9: return .trackingNumber
            case 10: return .URL
            case 11: return .money
            default: return nil
            }
        }

        private func entityToDictionary(text: String, entity: Entity) -> [String: Any] {
            var entityData: [String: Any] = [
                "type": entityTypeToNumber(entity.entityType),
                "raw": String(describing: entity)
            ]
            if entity.entityType == .dateTime, let dateTimeEntity = entity.dateTimeEntity {
                entityData["dateTimeGranularity"] = dateTimeEntity.dateTimeGranularity.rawValue
                entityData["timestamp"] = dateTimeEntity.dateTime.timeIntervalSince1970 * 1000
            } else if entity.entityType == .flightNumber,
                let flightEntity = entity.flightNumberEntity {
                entityData["code"] = flightEntity.airlineCode
                entityData["number"] = flightEntity.flightNumber
            } else if entity.entityType == .IBAN, let ibanEntity = entity.ibanEntity {
                entityData["iban"] = ibanEntity.iban
                entityData["code"] = ibanEntity.countryCode
            } else if entity.entityType == .ISBN, let isbnEntity = entity.isbnEntity {
                entityData["isbn"] = isbnEntity.isbn
            } else if entity.entityType == .paymentCard, let cardEntity = entity.paymentCardEntity {
                entityData["network"] = cardEntity.paymentCardNetwork.rawValue
                entityData["number"] = cardEntity.paymentCardNumber
            } else if entity.entityType == .trackingNumber,
                let trackingEntity = entity.trackingNumberEntity {
                entityData["carrier"] = trackingEntity.parcelCarrier.rawValue
                entityData["number"] = trackingEntity.parcelTrackingNumber
            } else if entity.entityType == .money, let moneyEntity = entity.moneyEntity {
                entityData["fraction"] = moneyEntity.fractionalPart
                entityData["integer"] = moneyEntity.integerPart
                entityData["unnormalized"] = moneyEntity.unnormalizedCurrency
            }
            return entityData
        }

        private func entityTypeToNumber(_ type: EntityType) -> Int {
            switch type {
            case .address: return 1
            case .dateTime: return 2
            case .email: return 3
            case .flightNumber: return 4
            case .IBAN: return 5
            case .ISBN: return 6
            case .paymentCard: return 7
            case .phone: return 8
            case .trackingNumber: return 9
            case .URL: return 10
            case .money: return 11
            default: return 0
            }
        }

        private func valueAsString(_ value: Any?) -> String? {
            guard value != nil, value is NSNull == false else { return nil }
            return value as? String
        }

        private func valueAsNumber(_ value: Any?) -> NSNumber? {
            guard value != nil, value is NSNull == false else { return nil }
            return value as? NSNumber
        }

        private func valueAsNumberArray(_ value: Any?) -> [NSNumber]? {
            guard value != nil, value is NSNull == false else { return nil }
            return value as? [NSNumber]
        }

        private func manageModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
            guard let args = call.arguments as? [String: Any],
                let modelTag = args["model"] as? String
            else {
                result(
                    FlutterError(
                        code: "invalid_args", message: "Missing model argument", details: nil))
                return
            }
            let modelIdentifier = EntityExtractionModelIdentifier(rawValue: modelTag)
            let model = EntityExtractorRemoteModel.entityExtractorRemoteModel(
                identifier: modelIdentifier)
            if genericModelManager == nil {
                genericModelManager = GenericModelManager()
            }
            genericModelManager?.manage(model: model, call: call, result: result)
        }
    #endif
}
