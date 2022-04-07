import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/commons.dart';

/// Class to scan the barcode in [InputImage]
/// Creating an instance of [BarcodeScanner]
///
/// BarcodeScanner barcodeScanner = GoogleMlKit.instance.barcodeScanner([List of Barcode formats (optional)]);
class BarcodeScanner {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_barcode_scanning');

  // List of barcode formats that can be provided to the instance to restrict search to specific barcode formats.
  final List<BarcodeFormat> formats;

  BarcodeScanner({this.formats = const [BarcodeFormat.all]});

  /// Function to process the [InputImage] and returns a list of [Barcode]
  Future<List<Barcode>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod('vision#startBarcodeScanner', {
      'formats': formats.map((f) => f.rawValue).toList(),
      'imageData': inputImage.toJson()
    });

    final barcodesList = <Barcode>[];
    for (final dynamic json in result) {
      barcodesList.add(Barcode.fromJson(json));
    }

    return barcodesList;
  }

  /// To close the instance of barcodeScanner.
  Future<void> close() => _channel.invokeMethod('vision#closeBarcodeScanner');
}

/// Barcode formats supported by the barcode scanner.
enum BarcodeFormat {
  /// Barcode format representing all supported formats.
  all,

  /// Barcode format unknown to the current SDK.
  unknown,

  /// Barcode format constant for Code 128.
  code128,

  /// Barcode format constant for Code 39.
  code39,

  /// Barcode format constant for Code 93.
  code93,

  /// Barcode format constant for CodaBar.
  codabar,

  /// Barcode format constant for Data Matrix.
  dataMatrix,

  /// Barcode format constant for EAN-13.
  ean13,

  /// Barcode format constant for EAN-8.
  ean8,

  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  itf,

  /// Barcode format constant for QR Code.
  qrCode,

  /// Barcode format constant for UPC-A.
  upca,

  /// Barcode format constant for UPC-E.
  upce,

  /// Barcode format constant for PDF-417.
  pdf417,

  /// Barcode format constant for AZTEC.
  aztec,
}

extension BarcodeFormatValue on BarcodeFormat {
  int get rawValue {
    switch (this) {
      case BarcodeFormat.all:
        return 0xFFFF;
      case BarcodeFormat.unknown:
        return 0;
      case BarcodeFormat.code128:
        return 0x0001;
      case BarcodeFormat.code39:
        return 0x0002;
      case BarcodeFormat.code93:
        return 0x0004;
      case BarcodeFormat.codabar:
        return 0x0008;
      case BarcodeFormat.dataMatrix:
        return 0x0010;
      case BarcodeFormat.ean13:
        return 0x0020;
      case BarcodeFormat.ean8:
        return 0x0040;
      case BarcodeFormat.itf:
        return 0x0080;
      case BarcodeFormat.qrCode:
        return 0x0100;
      case BarcodeFormat.upca:
        return 0x0200;
      case BarcodeFormat.upce:
        return 0x0400;
      case BarcodeFormat.pdf417:
        return 0x0800;
      case BarcodeFormat.aztec:
        return 0x1000;
    }
  }

  static BarcodeFormat fromRawValue(int rawValue) {
    return BarcodeFormat.values.firstWhere(
        (element) => element.rawValue == rawValue,
        orElse: () => BarcodeFormat.unknown);
  }
}

/// All supported Barcode Types.
enum BarcodeType {
  /// Unknown Barcode value types.
  unknown,

  /// Barcode value type for contact info.
  contactInfo,

  /// Barcode value type for email addresses.
  email,

  /// Barcode value type for ISBNs.
  isbn,

  /// Barcode value type for phone numbers.
  phone,

  /// Barcode value type for product codes.
  product,

  /// Barcode value type for SMS details.
  sms,

  /// Barcode value type for plain text.
  text,

  /// Barcode value type for URLs/bookmarks.
  url,

  /// Barcode value type for Wi-Fi access point details.
  wifi,

  /// Barcode value type for geographic coordinates.
  geographicCoordinates,

  /// Barcode value type for calendar events.
  calendarEvent,

  /// Barcode value type for driver's license data.
  driverLicense,
}

/// Class to represent the contents of barcode.
class Barcode {
  /// Type([BarcodeType]) of the barcode detected.
  final BarcodeType type;
  final BarcodeValue value;

  Barcode({
    required this.type,
    required this.value,
  });

  factory Barcode.fromJson(Map<dynamic, dynamic> json) {
    final BarcodeType type = BarcodeType.values[json['type']];
    switch (type) {
      case BarcodeType.unknown:
      case BarcodeType.isbn:
      case BarcodeType.text:
      case BarcodeType.product:
        return Barcode(value: BarcodeValue(json), type: type);
      case BarcodeType.wifi:
        return Barcode(value: BarcodeWifi(json), type: type);
      case BarcodeType.url:
        return Barcode(value: BarcodeUrl(json), type: type);
      case BarcodeType.email:
        return Barcode(value: BarcodeEmail(json), type: type);
      case BarcodeType.phone:
        return Barcode(value: BarcodePhone(json), type: type);
      case BarcodeType.sms:
        return Barcode(value: BarcodeSMS(json), type: type);
      case BarcodeType.geographicCoordinates:
        return Barcode(value: BarcodeGeo(json), type: type);
      case BarcodeType.driverLicense:
        return Barcode(value: BarcodeDriverLicense(json), type: type);
      case BarcodeType.contactInfo:
        return Barcode(value: BarcodeContactInfo(json), type: type);
      case BarcodeType.calendarEvent:
        return Barcode(value: BarcodeCalenderEvent(json), type: type);
      default:
        return Barcode(value: BarcodeValue(json), type: type);
    }
  }
}

/// Base for storing barcode data.
/// Any type of barcode has at least these three parameters.
class BarcodeValue {
  /// The format type of the barcode value.
  ///
  /// For example, [BarcodeType.text], [BarcodeType.product], [BarcodeType.url], etc.
  ///
  final BarcodeType type;

  /// The format (symbology) of the barcode value.
  ///
  /// For example, [BarcodeFormat.upca], [BarcodeFormat.code128], [BarcodeFormat.dataMatrix]
  final BarcodeFormat format;

  /// Barcode value as it was encoded in the barcode.
  ///
  /// Null if nothing found.
  final String? rawValue;

  /// Barcode bytes as encoded in the barcode.
  ///
  /// Null if nothing found.
  final Uint8List? rawBytes;

  /// Barcode value in a user-friendly format.
  /// This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value.
  /// May include the supplement value.
  ///
  /// Null if nothing found.
  final String? displayValue;

  /// The bounding rectangle of the detected barcode.
  ///
  /// Could be null if the bounding rectangle can not be determined.
  final Rect? boundingBox;

  BarcodeValue(Map<dynamic, dynamic> json)
      : type = BarcodeType.values[json['type']],
        format = BarcodeFormatValue.fromRawValue(json['format']),
        rawValue = json['rawValue'],
        rawBytes = json['rawBytes'],
        displayValue = json['displayValue'],
        boundingBox = json['boundingBoxLeft'] != null
            ? Rect.fromLTRB(
                (json['boundingBoxLeft']).toDouble(),
                (json['boundingBoxTop']).toDouble(),
                (json['boundingBoxRight']).toDouble(),
                (json['boundingBoxBottom']).toDouble())
            : null;
}

/// Class to store wifi info obtained from a barcode.
class BarcodeWifi extends BarcodeValue {
  /// SSID of the wifi.
  final String? ssid;

  /// Password of the wifi.
  final String? password;

  /// Encryption type of wifi.
  final int? encryptionType;

  BarcodeWifi(Map<dynamic, dynamic> json)
      : ssid = json['ssid'],
        password = json['password'],
        encryptionType = json['encryption'],
        super(json);
}

/// Class to store url info of the bookmark obtained from a barcode.
class BarcodeUrl extends BarcodeValue {
  /// String having the url address of bookmark.
  final String? url;

  /// Title of the bookmark.
  final String? title;

  BarcodeUrl(Map<dynamic, dynamic> json)
      : url = json['url'],
        title = json['title'],
        super(json);
}

/// The type of email for [BarcodeEmail.type].
enum BarcodeEmailType {
  /// Unknown email type.
  unknown,

  /// Barcode work email type.
  work,

  /// Barcode home email type.
  home,
}

/// A email message.
class BarcodeEmail extends BarcodeValue {
  /// Type of the email sent.
  final BarcodeEmailType? emailType;

  /// Email address of sender.
  final String? address;

  /// Body of the email.
  final String? body;

  /// Subject of email.
  final String? subject;

  BarcodeEmail(Map<dynamic, dynamic> json)
      : emailType = BarcodeEmailType.values[json['emailType']],
        address = json['address'],
        body = json['body'],
        subject = json['subject'],
        super(json);
}

/// The type of phone number for [BarcodePhone.type].
enum BarcodePhoneType {
  /// Unknown phone type.
  unknown,

  /// Barcode work phone type.
  work,

  /// Barcode home phone type.
  home,

  /// Barcode fax phone type.
  fax,

  /// Barcode mobile phone type.
  mobile,
}

/// A phone number.
class BarcodePhone extends BarcodeValue {
  /// Type of the phone number.
  final BarcodePhoneType? phoneType;

  /// Phone number.
  final String? number;

  BarcodePhone(Map<dynamic, dynamic> json)
      : phoneType = BarcodePhoneType.values[json['phoneType']],
        number = json['number'],
        super(json);
}

/// Class extending over [BarcodeValue] to store a SMS.
class BarcodeSMS extends BarcodeValue {
  /// Message present in the SMS.
  final String? message;

  /// Phone number of the sender.
  final String? phoneNumber;

  BarcodeSMS(Map<dynamic, dynamic> json)
      : message = json['message'],
        phoneNumber = json['number'],
        super(json);
}

/// Class extending over [BarcodeValue] that represents a geolocation.
class BarcodeGeo extends BarcodeValue {
  /// Latitude co-ordinates of the location.
  final double? latitude;

  //// Longitude co-ordinates of the location.
  final double? longitude;

  BarcodeGeo(Map<dynamic, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'],
        super(json);
}

///Class extending over [BarcodeValue] that models a driver's licence cars.
class BarcodeDriverLicense extends BarcodeValue {
  /// City of holder's address.
  final String? addressCity;

  /// State of the holder's address.
  final String? addressState;

  /// Zip code code of the holder's address.
  final String? addressZip;

  /// Street of the holder's address.
  final String? addressStreet;

  /// Date on which the license was issued.
  final String? issueDate;

  /// Birth date of the card holder.
  final String? birthDate;

  /// Expiry date of the license.
  final String? expiryDate;

  /// Gender of the holder.
  final String? gender;

  /// Driver license ID.
  final String? licenseNumber;

  /// First name of the holder.
  final String? firstName;

  /// Last name of the holder.
  final String? lastName;

  /// Country of the holder.
  final String? country;

  BarcodeDriverLicense(Map<dynamic, dynamic> json)
      : addressCity = json['addressCity'],
        addressState = json['addressState'],
        addressZip = json['addressZip'],
        addressStreet = json['addressStreet'],
        issueDate = json['issueDate'],
        birthDate = json['birthDate'],
        expiryDate = json['expiryDate'],
        gender = json['gender'],
        licenseNumber = json['licenseNumber'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        country = json['country'],
        super(json);
}

/// Class extending over [BarcodeValue] that models a contact info.
class BarcodeContactInfo extends BarcodeValue {
  /// Contact person's addresses.
  final List<BarcodeAddress> addresses;

  /// Email addresses of the contact person.
  final List<BarcodeEmail> emails;

  /// Phone numbers of the contact person.
  final List<BarcodePhone> phoneNumbers;

  /// First name of the contact person.
  final String? firstName;

  /// Middle name of the person.
  final String? middleName;

  /// Last name of the person.
  final String? lastName;

  /// Properly formatted name of the person.
  final String? formattedName;

  /// Name prefix
  final String? prefix;

  /// Name pronunciation
  final String? pronunciation;

  /// Job title
  final String? jobTitle;

  /// Organization of the contact person.
  final String? organizationName;

  /// Url's of contact person.
  final List<String> urls;

  BarcodeContactInfo(Map<dynamic, dynamic> json)
      : addresses = _getBarcodeAddresses(json),
        emails = _getBarcodeEmails(json),
        phoneNumbers = _getBarcodePhones(json),
        firstName = json['firstName'],
        middleName = json['middleName'],
        lastName = json['lastName'],
        formattedName = json['formattedName'],
        prefix = json['prefix'],
        pronunciation = json['pronunciation'],
        jobTitle = json['jobTitle'],
        organizationName = json['organization'],
        urls = _getUrls(json['urls']),
        super(json);
}

/// Class extending over [BarcodeValue] that models a calender event.
class BarcodeCalenderEvent extends BarcodeValue {
  /// Description of the event.
  final String? description;

  /// Location of the event.
  final String? location;

  /// Status of the event -> whether the event is completed or not.
  final String? status;

  /// A short summary of the event.
  final String? summary;

  /// A person or the organisation who is organising the event.
  final String? organizer;

  /// Start DateTime of the calender event.
  final DateTime? start;

  /// End DateTime of the calender event.
  final DateTime? end;

  BarcodeCalenderEvent(Map<dynamic, dynamic> json)
      : description = json['description'],
        location = json['location'],
        status = json['status'],
        summary = json['summary'],
        organizer = json['organizer'],
        start = _getDateTime(json['start']),
        end = _getDateTime(json['end']),
        super(json);
}

/// Address type constants for [BarcodeAddress.type]
enum BarcodeAddressType {
  /// Barcode unknown address type.
  unknown,

  /// Barcode work address type.
  work,

  /// Barcode home address type.
  home,
}

/// Class to store the information of address type barcode detected in a [InputImage].
class BarcodeAddress {
  /// Address lines found.
  final List<String> addressLines;

  /// Denoted the address type -> Home, Work or Unknown.
  final BarcodeAddressType? type;

  BarcodeAddress(this.addressLines, this.type);

  factory BarcodeAddress.fromJson(Map<dynamic, dynamic> json) {
    final lines = <String>[];
    for (final dynamic line in json['addressLines']) {
      lines.add(line);
    }
    return BarcodeAddress(
        lines, BarcodeAddressType.values[json['addressType']]);
  }
}

DateTime? _getDateTime(dynamic barcodeData) {
  if (barcodeData is double) {
    return DateTime.fromMillisecondsSinceEpoch(barcodeData.toInt() * 1000);
  } else if (barcodeData is String) {
    return DateTime.parse(barcodeData);
  }
  return null;
}

List<BarcodeAddress> _getBarcodeAddresses(dynamic json) {
  final list = <BarcodeAddress>[];
  json['addresses']?.forEach((address) {
    list.add(BarcodeAddress.fromJson(address));
  });
  return list;
}

List<BarcodeEmail> _getBarcodeEmails(dynamic json) {
  final list = <BarcodeEmail>[];
  json['emails']?.forEach((email) {
    email['type'] = BarcodeType.email.index;
    email['format'] = json['format'];
    list.add(BarcodeEmail(email));
  });
  return list;
}

List<BarcodePhone> _getBarcodePhones(dynamic json) {
  final list = <BarcodePhone>[];
  json['phones']?.forEach((phone) {
    phone['type'] = BarcodeType.phone.index;
    phone['format'] = json['format'];
    list.add(BarcodePhone(phone));
  });
  return list;
}

List<String> _getUrls(dynamic json) {
  final list = <String>[];
  json.forEach((url) {
    list.add(url.toString());
  });
  return list;
}
