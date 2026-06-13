import Flutter
import MLKitVision
import MLKitBarcodeScanning
import google_mlkit_commons

@objc
public class GoogleMlKitBarcodeScanningPlugin: NSObject, FlutterPlugin {
  private var instances: [String: BarcodeScanner] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_barcode_scanning",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitBarcodeScanningPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startBarcodeScanner":
      handleDetection(call: call, result: result)
    case "vision#closeBarcodeScanner":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(call: FlutterMethodCall) -> BarcodeScanner? {
    guard let args = call.arguments as? [String: Any],
          let array = args["formats"] as? [NSNumber] else { return nil }
    var formats: Int = 0
    for num in array {
      formats += num.intValue
    }
    let options = BarcodeScannerOptions(formats: BarcodeFormat(rawValue: formats))
    return BarcodeScanner.barcodeScanner(options: options)
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

    let barcodeScanner: BarcodeScanner
    if let existing = instances[uid] {
      barcodeScanner = existing
    } else {
      guard let newScanner = initialize(call: call) else {
        result(FlutterError(code: "invalid_args", message: "Invalid options", details: nil))
        return
      }
      barcodeScanner = newScanner
      instances[uid] = barcodeScanner
    }

    barcodeScanner.process(image) { barcodes, error in
      if let error = error as NSError? {
        result(FlutterError(code: "Error \(error.code)", message: error.domain, details: error.localizedDescription))
        return
      }
      guard let barcodes = barcodes else {
        result([])
        return
      }
      result(barcodes.map { self.barcodeToDictionary($0) })
    }
  }

  private func barcodeToDictionary(_ barcode: Barcode) -> [String: Any] {
    var dictionary: [String: Any] = [
      "type": barcode.valueType.rawValue,
      "format": barcode.format.rawValue,
      "rect": [
        "left": Double(barcode.frame.origin.x),
        "top": Double(barcode.frame.origin.y),
        "right": Double(barcode.frame.origin.x + barcode.frame.size.width),
        "bottom": Double(barcode.frame.origin.y + barcode.frame.size.height)
      ] as [String: Double]
    ]
    dictionary["rawValue"] = barcode.rawValue ?? NSNull()
    dictionary["rawBytes"] = barcode.rawData ?? NSNull()
    dictionary["displayValue"] = barcode.displayValue ?? NSNull()
    let points = (barcode.cornerPoints ?? []).map { point -> [String: Double] in
      let cgPoint = point.cgPointValue
      return ["x": Double(cgPoint.x), "y": Double(cgPoint.y)]
    }
    dictionary["points"] = points

    switch barcode.valueType {
    case .wiFi:
      if let wifi = barcode.wifi { dictionary.merge(wifiToDictionary(wifi)) { _, new in new } }
    case .URL:
      if let url = barcode.url { dictionary.merge(urlToDictionary(url)) { _, new in new } }
    case .email:
      if let email = barcode.email { dictionary.merge(emailToDictionary(email)) { _, new in new } }
    case .phone:
      if let phone = barcode.phone { dictionary.merge(phoneToDictionary(phone)) { _, new in new } }
    case .SMS:
      if let sms = barcode.sms { dictionary.merge(smsToDictionary(sms)) { _, new in new } }
    case .geographicCoordinates:
      if let geo = barcode.geoPoint { dictionary.merge(geoPointToDictionary(geo)) { _, new in new } }
    case .driversLicense:
      if let license = barcode.driverLicense { dictionary.merge(driverLicenseToDictionary(license)) { _, new in new } }
    case .contactInfo:
      if let contact = barcode.contactInfo {
        dictionary.merge(contactInfoToDictionary(contact)) { _, new in new }
      }
    case .calendarEvent:
      if let calendar = barcode.calendarEvent {
        dictionary.merge(calendarEventToDictionary(calendar)) { _, new in new }
      }
    default:
      break
    }
    return dictionary
  }

  private func wifiToDictionary(_ wifi: BarcodeWifi) -> [String: Any] {
    [
      "ssid": wifi.ssid ?? NSNull(),
      "password": wifi.password ?? NSNull(),
      "encryption": wifi.type.rawValue
    ]
  }

  private func urlToDictionary(_ url: BarcodeURLBookmark) -> [String: Any] {
    [
      "title": url.title ?? NSNull(),
      "url": url.url ?? NSNull()
    ]
  }

  private func emailToDictionary(_ email: BarcodeEmail) -> [String: Any] {
    [
      "address": email.address ?? NSNull(),
      "body": email.body ?? NSNull(),
      "subject": email.subject ?? NSNull(),
      "emailType": email.type.rawValue
    ]
  }

  private func phoneToDictionary(_ phone: BarcodePhone) -> [String: Any] {
    [
      "number": phone.number ?? NSNull(),
      "phoneType": phone.type.rawValue
    ]
  }

  private func smsToDictionary(_ sms: BarcodeSMS) -> [String: Any] {
    [
      "number": sms.phoneNumber ?? NSNull(),
      "message": sms.message ?? NSNull()
    ]
  }

  private func geoPointToDictionary(_ geo: BarcodeGeoPoint) -> [String: Any] {
    [
      "longitude": geo.longitude,
      "latitude": geo.latitude
    ]
  }

  private func driverLicenseToDictionary(_ license: BarcodeDriverLicense) -> [String: Any] {
    [
      "firstName": license.firstName ?? NSNull(),
      "middleName": license.middleName ?? NSNull(),
      "lastName": license.lastName ?? NSNull(),
      "gender": license.gender ?? NSNull(),
      "addressCity": license.addressCity ?? NSNull(),
      "addressStreet": license.addressStreet ?? NSNull(),
      "addressState": license.addressState ?? NSNull(),
      "addressZip": license.addressZip ?? NSNull(),
      "birthDate": license.birthDate ?? NSNull(),
      "documentType": license.documentType ?? NSNull(),
      "licenseNumber": license.licenseNumber ?? NSNull(),
      "expiryDate": license.expiryDate ?? NSNull(),
      "issueDate": license.issuingDate ?? NSNull(),
      "country": license.issuingCountry ?? NSNull()
    ]
  }

  private func contactInfoToDictionary(_ contact: BarcodeContactInfo) -> [String: Any] {
    let addresses: [[String: Any]] = (contact.addresses ?? []).map { address in
      [
        "addressLines": address.addressLines ?? NSNull(),
        "addressType": address.type.rawValue
      ] as [String: Any]
    }
    let emails = (contact.emails ?? []).map { (email: BarcodeEmail) -> [String: Any] in
      [
        "address": email.address ?? NSNull(),
        "body": email.body ?? NSNull(),
        "subject": email.subject ?? NSNull(),
        "emailType": email.type.rawValue
      ] as [String: Any]
    }
    let phones = (contact.phones ?? []).map { (phone: BarcodePhone) -> [String: Any] in
      [
        "number": phone.number ?? NSNull(),
        "phoneType": phone.type.rawValue
      ] as [String: Any]
    }
    let name = contact.name
    return [
      "addresses": addresses,
      "emails": emails,
      "phones": phones,
      "urls": contact.urls ?? NSNull(),
      "formattedName": name?.formattedName ?? NSNull(),
      "firstName": name?.first ?? NSNull(),
      "lastName": name?.last ?? NSNull(),
      "middleName": name?.middle ?? NSNull(),
      "prefix": name?.prefix ?? NSNull(),
      "pronunciation": name?.pronunciation ?? NSNull(),
      "suffix": name?.suffix ?? NSNull(),
      "jobTitle": contact.jobTitle ?? NSNull(),
      "organization": contact.organization ?? NSNull()
    ]
  }

  private func calendarEventToDictionary(_ calendar: BarcodeCalendarEvent) -> [String: Any] {
    [
      "description": calendar.eventDescription ?? NSNull(),
      "location": calendar.location ?? NSNull(),
      "organizer": calendar.organizer ?? NSNull(),
      "status": calendar.status ?? NSNull(),
      "summary": calendar.summary ?? NSNull(),
      "start": calendar.start.map { NSNumber(value: $0.timeIntervalSince1970) } ?? NSNull(),
      "end": calendar.end.map { NSNumber(value: $0.timeIntervalSince1970) } ?? NSNull()
    ]
  }
}
