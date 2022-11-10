import 'dart:math';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A barcode scanner that scans and decodes barcodes from a given [InputImage].
class BarcodeScanner {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_barcode_scanning');

  /// List that restrict the scan to specific barcode formats.
  final List<BarcodeFormat> formats;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [BarcodeScanner].
  /// Returns a barcode scanner with the given [formats] options.
  BarcodeScanner({this.formats = const [BarcodeFormat.all]});

  /// Processes the given [InputImage] for barcode scanning. Returns a list of [Barcode].
  Future<List<Barcode>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod('vision#startBarcodeScanner', {
      'formats': formats.map((f) => f.rawValue).toList(),
      'id': id,
      'imageData': inputImage.toJson()
    });

    final barcodesList = <Barcode>[];
    for (final dynamic json in result) {
      barcodesList.add(Barcode.fromJson(json));
    }

    return barcodesList;
  }

  /// Closes the scanner and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeBarcodeScanner', {'id': id});
}

/// Barcode formats supported by the barcode scanner.
/// Options for specifying the barcode formats that the library can detect.
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

/// [Barcode] types returned by [BarcodeScanner].
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

  /// Barcode value type for geo coordinates.
  geoCoordinates,

  /// Barcode value type for calendar events.
  calendarEvent,

  /// Barcode value type for driver's license data.
  driverLicense,
}

/// A class to represent the contents of a barcode in an [InputImage].
class Barcode {
  /// The format type of the barcode value.
  ///
  /// For example, [BarcodeType.text], [BarcodeType.product], [BarcodeType.url], etc.
  ///
  final BarcodeType type;

  /// The format (symbology) of the barcode value.
  ///
  /// For example, [BarcodeFormat.upca], [BarcodeFormat.code128], [BarcodeFormat.dataMatrix]
  final BarcodeFormat format;

  /// A barcode value depending on the [BarcodeType] type set.
  final BarcodeValue? value;

  /// A barcode value in a user-friendly format.
  /// This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value.
  /// May include the supplement value.
  ///
  /// Null if nothing found.
  final String? displayValue;

  /// A barcode value as it was encoded in the barcode.
  ///
  /// Null if nothing found.
  final String? rawValue;

  /// Barcode bytes as encoded in the barcode.
  ///
  /// Null if nothing found.
  final Uint8List? rawBytes;

  /// The rectangle that holds the discovered barcode relative to the detected image in the view coordinate system.
  ///
  /// Could be null if the bounding rectangle can not be determined.
  final Rect? boundingBox;

  /// The four corner points of the barcode, in clockwise order starting with the top left relative to the detected image in the view coordinate system.
  ///
  /// Due to the possible perspective distortions, this is not necessarily a rectangle.
  final List<Point<int>>? cornerPoints;

  /// Constructor to create an instance of [Barcode].
  Barcode({
    required this.type,
    required this.format,
    required this.displayValue,
    required this.rawValue,
    required this.rawBytes,
    required this.boundingBox,
    required this.cornerPoints,
    required this.value,
  });

  /// Returns an instance of [Barcode] from a given [json].
  factory Barcode.fromJson(Map<dynamic, dynamic> json) {
    final type = BarcodeType.values[json['type'].toInt()];
    final format = BarcodeFormatValue.fromRawValue(json['format']);
    final displayValue = json['displayValue'];
    final rawValue = json['rawValue'];
    final rawBytes = json['rawBytes'];
    final boundingBox = json['boundingBoxLeft'] != null
        ? Rect.fromLTRB(
            (json['boundingBoxLeft']).toDouble(),
            (json['boundingBoxTop']).toDouble(),
            (json['boundingBoxRight']).toDouble(),
            (json['boundingBoxBottom']).toDouble())
        : null;
    BarcodeValue? value;
    final points = json['cornerPoints'];
    final List<Point<int>> cornerPoints = [];
    for (final point in points) {
      final cornerPoint = Point<int>(point['x'].toInt(), point['y'].toInt());
      cornerPoints.add(cornerPoint);
    }

    switch (type) {
      case BarcodeType.wifi:
        value = BarcodeWifi.fromJson(json);
        break;
      case BarcodeType.url:
        value = BarcodeUrl.fromJson(json);
        break;
      case BarcodeType.email:
        value = BarcodeEmail.fromJson(json);
        break;
      case BarcodeType.phone:
        value = BarcodePhone.fromJson(json);
        break;
      case BarcodeType.sms:
        value = BarcodeSMS.fromJson(json);
        break;
      case BarcodeType.geoCoordinates:
        value = BarcodeGeoPoint.fromJson(json);
        break;
      case BarcodeType.driverLicense:
        value = BarcodeDriverLicense.fromJson(json);
        break;
      case BarcodeType.contactInfo:
        value = BarcodeContactInfo.fromJson(json);
        break;
      case BarcodeType.calendarEvent:
        value = BarcodeCalenderEvent.fromJson(json);
        break;
      default:
        break;
    }

    return Barcode(
      type: type,
      format: format,
      value: value,
      displayValue: displayValue,
      rawValue: rawValue,
      rawBytes: rawBytes,
      boundingBox: boundingBox,
      cornerPoints: cornerPoints.isEmpty ? null : cornerPoints,
    );
  }
}

/// Stores info obtained from a barcode.
abstract class BarcodeValue {}

/// Stores wifi info obtained from a barcode.
class BarcodeWifi extends BarcodeValue {
  /// SSID of the wifi.
  final String? ssid;

  /// Password of the wifi.
  final String? password;

  /// Encryption type of wifi.
  final int? encryptionType;

  /// Constructor to create an instance of [BarcodeWifi].
  BarcodeWifi({this.ssid, this.password, this.encryptionType});

  /// Returns an instance of [BarcodeWifi] from a given [json].
  factory BarcodeWifi.fromJson(Map<dynamic, dynamic> json) => BarcodeWifi(
        ssid: json['ssid'],
        password: json['password'],
        encryptionType: json['encryption'],
      );
}

/// Stores url info of the bookmark obtained from a barcode.
class BarcodeUrl extends BarcodeValue {
  /// String having the url address of bookmark.
  final String? url;

  /// Title of the bookmark.
  final String? title;

  /// Constructor to create an instance of [BarcodeUrl].
  BarcodeUrl({this.url, this.title});

  /// Returns an instance of [BarcodeUrl] from a given [json].
  factory BarcodeUrl.fromJson(Map<dynamic, dynamic> json) => BarcodeUrl(
        url: json['url'],
        title: json['title'],
      );
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

/// Stores an email message obtained from a barcode.
class BarcodeEmail extends BarcodeValue {
  /// Type of the email sent.
  final BarcodeEmailType? type;

  /// Email address of sender.
  final String? address;

  /// Body of the email.
  final String? body;

  /// Subject of email.
  final String? subject;

  /// Constructor to create an instance of [BarcodeEmail].
  BarcodeEmail({this.type, this.address, this.body, this.subject});

  /// Returns an instance of [BarcodeEmail] from a given [json].
  factory BarcodeEmail.fromJson(Map<dynamic, dynamic> json) => BarcodeEmail(
        type: BarcodeEmailType.values[json['emailType']],
        address: json['address'],
        body: json['body'],
        subject: json['subject'],
      );
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

/// Stores a phone number obtained from a barcode.
class BarcodePhone extends BarcodeValue {
  /// Type of the phone number.
  final BarcodePhoneType? type;

  /// Phone number.
  final String? number;

  /// Constructor to create an instance of [BarcodePhone].
  BarcodePhone({this.type, this.number});

  /// Returns an instance of [BarcodePhone] from a given [json].
  factory BarcodePhone.fromJson(Map<dynamic, dynamic> json) => BarcodePhone(
        type: BarcodePhoneType.values[json['phoneType']],
        number: json['number'],
      );
}

/// Stores an SMS message obtained from a barcode.
class BarcodeSMS extends BarcodeValue {
  /// Message present in the SMS.
  final String? message;

  /// Phone number of the sender.
  final String? phoneNumber;

  /// Constructor to create an instance of [BarcodeSMS].
  BarcodeSMS({this.message, this.phoneNumber});

  /// Returns an instance of [BarcodeSMS] from a given [json].
  factory BarcodeSMS.fromJson(Map<dynamic, dynamic> json) => BarcodeSMS(
        message: json['message'],
        phoneNumber: json['number'],
      );
}

/// Stores GPS coordinates obtained from a barcode.
class BarcodeGeoPoint extends BarcodeValue {
  /// Latitude co-ordinates of the location.
  final double? latitude;

  //// Longitude co-ordinates of the location.
  final double? longitude;

  /// Constructor to create an instance of [BarcodeGeoPoint].
  BarcodeGeoPoint({this.latitude, this.longitude});

  /// Returns an instance of [BarcodeGeoPoint] from a given [json].
  factory BarcodeGeoPoint.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeGeoPoint(
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}

/// Stores driver’s license or ID card data representation obtained from a barcode.
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

  /// Constructor to create an instance of [BarcodeDriverLicense].
  BarcodeDriverLicense({
    this.addressCity,
    this.addressState,
    this.addressZip,
    this.addressStreet,
    this.issueDate,
    this.birthDate,
    this.expiryDate,
    this.gender,
    this.licenseNumber,
    this.firstName,
    this.lastName,
    this.country,
  });

  /// Returns an instance of [BarcodeDriverLicense] from a given [json].
  factory BarcodeDriverLicense.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeDriverLicense(
        addressCity: json['addressCity'],
        addressState: json['addressState'],
        addressZip: json['addressZip'],
        addressStreet: json['addressStreet'],
        issueDate: json['issueDate'],
        birthDate: json['birthDate'],
        expiryDate: json['expiryDate'],
        gender: json['gender'],
        licenseNumber: json['licenseNumber'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        country: json['country'],
      );
}

/// Stores a person’s or organization’s business card obtained from a barcode.
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

  /// Name prefix.
  final String? prefix;

  /// Name pronunciation.
  final String? pronunciation;

  /// Job title.
  final String? jobTitle;

  /// Organization of the contact person.
  final String? organizationName;

  /// Url's of contact person.
  final List<String> urls;

  /// Constructor to create an instance of [BarcodeContactInfo].
  BarcodeContactInfo({
    required this.addresses,
    required this.emails,
    required this.phoneNumbers,
    required this.urls,
    this.firstName,
    this.middleName,
    this.lastName,
    this.formattedName,
    this.prefix,
    this.pronunciation,
    this.jobTitle,
    this.organizationName,
  });

  /// Returns an instance of [BarcodeContactInfo] from a given [json].
  factory BarcodeContactInfo.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeContactInfo(
        addresses: _getBarcodeAddresses(json),
        emails: _getBarcodeEmails(json),
        phoneNumbers: _getBarcodePhones(json),
        firstName: json['firstName'],
        middleName: json['middleName'],
        lastName: json['lastName'],
        formattedName: json['formattedName'],
        prefix: json['prefix'],
        pronunciation: json['pronunciation'],
        jobTitle: json['jobTitle'],
        organizationName: json['organization'],
        urls: _getUrls(json['urls']),
      );
}

/// Stores a calendar event obtained from a barcode.
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

  /// Constructor to create an instance of [BarcodeCalenderEvent].
  BarcodeCalenderEvent({
    this.description,
    this.location,
    this.status,
    this.summary,
    this.organizer,
    this.start,
    this.end,
  });

  /// Returns an instance of [BarcodeCalenderEvent] from a given [json].
  factory BarcodeCalenderEvent.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeCalenderEvent(
        description: json['description'],
        location: json['location'],
        status: json['status'],
        summary: json['summary'],
        organizer: json['organizer'],
        start: _getDateTime(json['start']),
        end: _getDateTime(json['end']),
      );
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

/// Stores an address obtained from a barcode.
class BarcodeAddress {
  /// Address lines found.
  final List<String> addressLines;

  /// The address type.
  final BarcodeAddressType? type;

  /// Constructor to create an instance of [BarcodeAddress].
  BarcodeAddress({required this.addressLines, this.type});

  /// Returns an instance of [BarcodeAddress] from a given [json].
  factory BarcodeAddress.fromJson(Map<dynamic, dynamic> json) {
    final lines = <String>[];
    for (final dynamic line in json['addressLines']) {
      lines.add(line);
    }
    return BarcodeAddress(
      addressLines: lines,
      type: BarcodeAddressType.values[json['addressType']],
    );
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
    list.add(BarcodeEmail.fromJson(email));
  });
  return list;
}

List<BarcodePhone> _getBarcodePhones(dynamic json) {
  final list = <BarcodePhone>[];
  json['phones']?.forEach((phone) {
    phone['type'] = BarcodeType.phone.index;
    phone['format'] = json['format'];
    list.add(BarcodePhone.fromJson(phone));
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
