part of 'vision.dart';

/// Class to scan the barcode in [InputImage]
/// Creating an instance of [BarcodeScanner]
///
/// BarcodeScanner barcodeScanner = GoogleMlKit.instance.barcodeScanner([List of Barcode formats (optional)]);
class BarcodeScanner {
  // List of barcode formats that can be provided to the instance to restrict search to specific barcode formats.
  final List<BarcodeFormat> barcodeFormats;

  BarcodeScanner({List<BarcodeFormat>? formats})
      : barcodeFormats = formats ?? const [BarcodeFormat.all];

  bool _isOpened = false;
  bool _isClosed = false;

  /// Function to process the [InputImage] and returns a list of [Barcode]
  Future<List<Barcode>> processImage(InputImage inputImage) async {
    _isOpened = true;
    final result =
        await Vision.channel.invokeMethod('vision#startBarcodeScanner', {
      'formats': barcodeFormats.map((f) => f.value).toList(),
      'imageData': inputImage._getImageData()
    });

    final barcodesList = <Barcode>[];
    for (dynamic item in result) {
      barcodesList.add(Barcode._fromMap(item));
    }

    return barcodesList;
  }

  /// To close the instance of barcodeScanner.
  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await Vision.channel.invokeMethod('vision#closeBarcodeScanner');
      _isClosed = true;
      _isOpened = false;
    }
  }
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

extension _BarcodeFormatValue on BarcodeFormat {
  static BarcodeFormat of(int value) {
    switch (value) {
      case 0xFFFF:
        return BarcodeFormat.all;
      case 0x0001:
        return BarcodeFormat.code128;
      case 0x0002:
        return BarcodeFormat.code39;
      case 0x0004:
        return BarcodeFormat.code93;
      case 0x0008:
        return BarcodeFormat.codabar;
      case 0x0010:
        return BarcodeFormat.dataMatrix;
      case 0x0020:
        return BarcodeFormat.ean13;
      case 0x0040:
        return BarcodeFormat.ean8;
      case 0x0080:
        return BarcodeFormat.itf;
      case 0x0100:
        return BarcodeFormat.qrCode;
      case 0x0200:
        return BarcodeFormat.upca;
      case 0x0400:
        return BarcodeFormat.upce;
      case 0x0800:
        return BarcodeFormat.pdf417;
      case 0x1000:
        return BarcodeFormat.aztec;
      default:
        return BarcodeFormat.unknown;
    }
  }

  int get value {
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
  Barcode._({
    required this.type,
    required this.value,
  });

  /// Type([BarcodeType]) of the barcode detected.
  final BarcodeType type;
  final BarcodeValue value;

  factory Barcode._fromMap(Map<dynamic, dynamic> barcodeData) {
    BarcodeType type = BarcodeType.values[barcodeData['type']];
    switch (type) {
      case BarcodeType.unknown:
      case BarcodeType.isbn:
      case BarcodeType.text:
      case BarcodeType.product:
        return Barcode._(value: BarcodeValue._(barcodeData), type: type);
      case BarcodeType.wifi:
        return Barcode._(value: BarcodeWifi._(barcodeData), type: type);
      case BarcodeType.url:
        return Barcode._(value: BarcodeUrl._(barcodeData), type: type);
      case BarcodeType.email:
        return Barcode._(value: BarcodeEmail._(barcodeData), type: type);
      case BarcodeType.phone:
        return Barcode._(value: BarcodePhone._(barcodeData), type: type);
      case BarcodeType.sms:
        return Barcode._(value: BarcodeSMS._(barcodeData), type: type);
      case BarcodeType.geographicCoordinates:
        return Barcode._(value: BarcodeGeo._(barcodeData), type: type);
      case BarcodeType.driverLicense:
        return Barcode._(
            value: BarcodeDriverLicense._(barcodeData), type: type);
      case BarcodeType.contactInfo:
        return Barcode._(value: BarcodeContactInfo._(barcodeData), type: type);
      case BarcodeType.calendarEvent:
        return Barcode._(
            value: BarcodeCalenderEvent._(barcodeData), type: type);
      default:
        return Barcode._(value: BarcodeValue._(barcodeData), type: type);
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

  BarcodeValue._(Map<dynamic, dynamic> barcodeData)
      : type = BarcodeType.values[barcodeData['type']],
        format = _BarcodeFormatValue.of(barcodeData['format']),
        rawValue = barcodeData['rawValue'],
        rawBytes = barcodeData['rawBytes'],
        displayValue = barcodeData['displayValue'],
        boundingBox = barcodeData['boundingBoxLeft'] != null
            ? Rect.fromLTRB(
                (barcodeData['boundingBoxLeft']).toDouble(),
                (barcodeData['boundingBoxTop']).toDouble(),
                (barcodeData['boundingBoxRight']).toDouble(),
                (barcodeData['boundingBoxBottom']).toDouble())
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

  BarcodeWifi._(Map<dynamic, dynamic> barcodeData)
      : ssid = barcodeData['ssid'],
        password = barcodeData['password'],
        encryptionType = barcodeData['encryption'],
        super._(barcodeData);
}

/// Class to store url info of the bookmark obtained from a barcode.
class BarcodeUrl extends BarcodeValue {
  /// String having the url address of bookmark.
  final String? url;

  /// Title of the bookmark.
  final String? title;

  BarcodeUrl._(Map<dynamic, dynamic> barcodeData)
      : url = barcodeData['url'],
        title = barcodeData['title'],
        super._(barcodeData);
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

  BarcodeEmail._(Map<dynamic, dynamic> barcodeData)
      : emailType = BarcodeEmailType.values[barcodeData['emailType']],
        address = barcodeData['address'],
        body = barcodeData['body'],
        subject = barcodeData['subject'],
        super._(barcodeData);
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

  BarcodePhone._(Map<dynamic, dynamic> barcodeData)
      : phoneType = BarcodePhoneType.values[barcodeData['phoneType']],
        number = barcodeData['number'],
        super._(barcodeData);
}

/// Class extending over [BarcodeValue] to store a SMS.
class BarcodeSMS extends BarcodeValue {
  /// Message present in the SMS.
  final String? message;

  /// Phone number of the sender.
  final String? phoneNumber;

  BarcodeSMS._(Map<dynamic, dynamic> barcodeData)
      : message = barcodeData['message'],
        phoneNumber = barcodeData['number'],
        super._(barcodeData);
}

/// Class extending over [BarcodeValue] that represents a geolocation.
class BarcodeGeo extends BarcodeValue {
  /// Latitude co-ordinates of the location.
  final double? latitude;

  //// Longitude co-ordinates of the location.
  final double? longitude;

  BarcodeGeo._(Map<dynamic, dynamic> barcodeData)
      : latitude = barcodeData['latitude'],
        longitude = barcodeData['longitude'],
        super._(barcodeData);
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

  BarcodeDriverLicense._(Map<dynamic, dynamic> barcodeData)
      : addressCity = barcodeData['addressCity'],
        addressState = barcodeData['addressState'],
        addressZip = barcodeData['addressZip'],
        addressStreet = barcodeData['addressStreet'],
        issueDate = barcodeData['issueDate'],
        birthDate = barcodeData['birthDate'],
        expiryDate = barcodeData['expiryDate'],
        gender = barcodeData['gender'],
        licenseNumber = barcodeData['licenseNumber'],
        firstName = barcodeData['firstName'],
        lastName = barcodeData['lastName'],
        country = barcodeData['country'],
        super._(barcodeData);
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

  BarcodeContactInfo._(Map<dynamic, dynamic> barcodeData)
      : addresses = _getBarcodeAddresses(barcodeData),
        emails = _getBarcodeEmails(barcodeData),
        phoneNumbers = _getBarcodePhones(barcodeData),
        firstName = barcodeData['firstName'],
        middleName = barcodeData['middleName'],
        lastName = barcodeData['lastName'],
        formattedName = barcodeData['formattedName'],
        prefix = barcodeData['prefix'],
        pronunciation = barcodeData['pronunciation'],
        jobTitle = barcodeData['jobTitle'],
        organizationName = barcodeData['organization'],
        urls = _getUrls(barcodeData['urls']),
        super._(barcodeData);
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

  BarcodeCalenderEvent._(Map<dynamic, dynamic> barcodeData)
      : description = barcodeData['description'],
        location = barcodeData['location'],
        status = barcodeData['status'],
        summary = barcodeData['summary'],
        organizer = barcodeData['organizer'],
        start = _getDateTime(barcodeData['start']),
        end = _getDateTime(barcodeData['end']),
        super._(barcodeData);
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

  BarcodeAddress._(this.addressLines, this.type);

  factory BarcodeAddress._fromMap(Map<dynamic, dynamic> address) {
    var lines = <String>[];
    for (dynamic line in address['addressLines']) {
      lines.add(line);
    }
    return BarcodeAddress._(
        lines, BarcodeAddressType.values[address['addressType']]);
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

List<BarcodeAddress> _getBarcodeAddresses(dynamic barcodeData) {
  var list = <BarcodeAddress>[];
  barcodeData['addresses']?.forEach((address) {
    list.add(BarcodeAddress._fromMap(address));
  });
  return list;
}

List<BarcodeEmail> _getBarcodeEmails(dynamic barcodeData) {
  var list = <BarcodeEmail>[];
  barcodeData['emails']?.forEach((email) {
    email['type'] = BarcodeType.email.index;
    email['format'] = barcodeData['format'];
    list.add(BarcodeEmail._(email));
  });
  return list;
}

List<BarcodePhone> _getBarcodePhones(dynamic barcodeData) {
  var list = <BarcodePhone>[];
  barcodeData['phones']?.forEach((phone) {
    phone['type'] = BarcodeType.phone.index;
    phone['format'] = barcodeData['format'];
    list.add(BarcodePhone._(phone));
  });
  return list;
}

List<String> _getUrls(dynamic urls) {
  var list = <String>[];
  urls.forEach((url) {
    list.add(url.toString());
  });
  return list;
}
