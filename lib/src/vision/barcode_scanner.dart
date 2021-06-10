part of 'vision.dart';

///Class to scan the barcode in [InputImage]
///Creating an instance of [BarcodeScanner]
///
/// BarcodeScanner barcodeScanner = GoogleMlKit.instance.barcodeScanner([List of Barcode formats (optional)]);
class BarcodeScanner {
  //List of barcode formats that can be provided to the instance to restrict search to specific barcode formats.
  final List<int> barcodeFormats;

  BarcodeScanner({List<int>? formats})
      : barcodeFormats = formats ?? const [BarcodeFormat.all];

  bool _isOpened = false;
  bool _isClosed = false;

  ///Function to process the [InputImage] and returns a list of [Barcode]
  Future<List<Barcode>> processImage(InputImage inputImage) async {
    _isOpened = true;
    final result = await Vision.channel.invokeMethod(
        'vision#startBarcodeScanner', <String, dynamic>{
      'formats': barcodeFormats,
      'imageData': inputImage._getImageData()
    });

    final barcodesList = <Barcode>[];
    for (dynamic item in result) {
      barcodesList.add(Barcode._fromMap(item));
    }

    return barcodesList;
  }

  ///To close the instance of barcodeScanner.
  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await Vision.channel.invokeMethod('vision#closeBarcodeScanner');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

///Barcode formats supported by the barcode scanner.
class BarcodeFormat {
  /// Barcode format constant representing the union of all supported formats.
  static const int all = 0xFFFF;

  /// Barcode format unknown to the current SDK.
  static const int unknown = 0;

  /// Barcode format constant for Code 128.
  static const int code128 = 0x0001;

  /// Barcode format constant for Code 39.
  static const int code39 = 0x0002;

  /// Barcode format constant for Code 93.
  static const int code93 = 0x0004;

  /// Barcode format constant for CodaBar.
  static const int codabar = 0x0008;

  /// Barcode format constant for Data Matrix.
  static const int dataMatrix = 0x0010;

  /// Barcode format constant for EAN-13.
  static const int ean13 = 0x0020;

  /// Barcode format constant for EAN-8.
  static const int ean8 = 0x0040;

  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  static const int itf = 0x0080;

  /// Barcode format constant for QR Code.
  static const int qrCode = 0x0100;

  /// Barcode format constant for UPC-A.
  static const int upca = 0x0200;

  /// Barcode format constant for UPC-E.
  static const int upce = 0x0400;

  /// Barcode format constant for PDF-417.
  static const int pdf417 = 0x0800;

  /// Barcode format constant for AZTEC.
  static const int aztec = 0x1000;
}

///All supported Barcode Types.
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

///Class to represent the contents of barcode.
class Barcode {
  Barcode._({
    required this.type,
    required this.value,
  });

  ///Type([BarcodeType]) of the barcode detected.
  final BarcodeType type;
  final BarcodeValue value;

  factory Barcode._fromMap(Map<dynamic, dynamic> barcodeData) {
    BarcodeType type = BarcodeType.values[barcodeData['type']];
    switch (type) {
      case BarcodeType.unknown:
      case BarcodeType.isbn:
      case BarcodeType.text:
      case BarcodeType.product:
        return Barcode._(value: BarcodeValue._fromMap(barcodeData), type: type);
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
        return Barcode._(value: BarcodeValue._fromMap(barcodeData), type: type);
    }
  }
}

///Base for storing barcode data.
///Any type of barcode has at least these three parameters.
class BarcodeValue {
  /// The format type of the barcode value.
  ///
  /// For example, [BarcodeType.text], [BarcodeType.product], [BarcodeType.url], etc.
  ///
  final BarcodeType type;

  /// The format (symbology) of the barcode value.
  ///
  /// For example, [BarcodeFormat.upca], [BarcodeFormat.code128], [BarcodeFormat.dataMatrix]
  final int format;

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

  BarcodeValue._fromMap(Map<dynamic, dynamic> barcodeData)
      : type = BarcodeType.values[barcodeData['type']],
        format = barcodeData['format'],
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

///Class to store wifi info obtained from a barcode.
class BarcodeWifi extends BarcodeValue {
  ///SSID of the wifi.
  final String? ssid;

  ///Password of the wifi.
  final String? password;

  ///Encryption type of wifi.
  final int? encryptionType;

  BarcodeWifi._(Map<dynamic, dynamic> barcodeData)
      : ssid = barcodeData['ssid'],
        password = barcodeData['password'],
        encryptionType = barcodeData['encryption'],
        super._fromMap(barcodeData);
}

///Class to store url info of the bookmark obtained from a barcode.
class BarcodeUrl extends BarcodeValue {
  ///String having the url address of bookmark.
  final String? url;

  ///Title of the bookmark.
  final String? title;

  BarcodeUrl._(Map<dynamic, dynamic> barcodeData)
      : url = barcodeData['url'],
        title = barcodeData['title'],
        super._fromMap(barcodeData);
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

///A email message.
class BarcodeEmail extends BarcodeValue {
  ///Type of the email sent.
  final BarcodeEmailType? emailType;

  ///Email address of sender.
  final String? address;

  ///Body of the email.
  final String? body;

  ///Subject of email.
  final String? subject;

  BarcodeEmail._(Map<dynamic, dynamic> barcodeData)
      : emailType = BarcodeEmailType.values[barcodeData['emailType']],
        address = barcodeData['address'],
        body = barcodeData['body'],
        subject = barcodeData['subject'],
        super._fromMap(barcodeData);
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

///A phone number.
class BarcodePhone extends BarcodeValue {
  ///Type of the phone number.
  final BarcodePhoneType? phoneType;

  ///Phone number.
  final String? number;

  BarcodePhone._(Map<dynamic, dynamic> barcodeData)
      : phoneType = BarcodePhoneType.values[barcodeData['phoneType']],
        number = barcodeData['number'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeValue] to store a SMS.
class BarcodeSMS extends BarcodeValue {
  ///Message present in the SMS.
  final String? message;

  ///Phone number of the sender.
  final String? phoneNumber;

  BarcodeSMS._(Map<dynamic, dynamic> barcodeData)
      : message = barcodeData['message'],
        phoneNumber = barcodeData['number'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeValue] that represents a geolocation.
class BarcodeGeo extends BarcodeValue {
  ///Latitude co-ordinates of the location.
  final double? latitude;

  ////Longitude co-ordinates of the location.
  final double? longitude;

  BarcodeGeo._(Map<dynamic, dynamic> barcodeData)
      : latitude = barcodeData['latitude'],
        longitude = barcodeData['longitude'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeValue] that models a driver's licence cars.
class BarcodeDriverLicense extends BarcodeValue {
  ///City of holder's address.
  final String? addressCity;

  ///State of the holder's address.
  final String? addressState;

  ///Zip code code of the holder's address.
  final String? addressZip;

  ///Street of the holder's address.
  final String? addressStreet;

  ///Date on which the license was issued.
  final String? issueDate;

  ///Birth date of the card holder.
  final String? birthDate;

  ///Expiry date of the license.
  final String? expiryDate;

  ///Gender of the holder.
  final String? gender;

  ///Driver license ID.
  final String? licenseNumber;

  ////First name of the holder.
  final String? firstName;

  ///Last name of the holder.
  final String? lastName;

  ///Country of the holder.
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
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeValue] that models a contact info.
class BarcodeContactInfo extends BarcodeValue {
  ///Contact person's addresses.
  final List<BarcodeAddress>? barcodeAddresses;

  ///Email addresses of the contact person.
  final List<BarcodeEmail>? emails;

  ///Phone numbers of the contact person.
  final List<BarcodePhone>? phoneNumbers;

  ///First name of the contact person.
  final String? firstName;

  ///Last name of the peron.
  final String? lastName;

  ///Properly formatted name of the person.
  final String? formattedName;

  ///Organisation of the contact person.
  final String? organisationName;

  ///Url's of contact person.
  final List<String>? urls;

  BarcodeContactInfo._(Map<dynamic, dynamic> barcodeData)
      : barcodeAddresses = barcodeData['addresses'] = barcodeData['addresses']
            .map<BarcodeAddress>((address) => BarcodeAddress._fromMap(address)),
        emails = barcodeData['emails'] = barcodeData['emails']
            .map<BarcodeEmail>((email) => BarcodeEmail._(email)),
        phoneNumbers = barcodeData['contactNumbers'] =
            barcodeData['contactNumbers']
                .map<BarcodePhone>((number) => BarcodePhone),
        firstName = barcodeData['firstName'],
        lastName = barcodeData['lastName'],
        formattedName = barcodeData['formattedName'],
        organisationName = barcodeData['organisation'],
        urls = barcodeData['urls'] as List<String>,
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeValue] that models a calender event.
class BarcodeCalenderEvent extends BarcodeValue {
  ///Description of the event.
  final String? description;

  ///Location of the event.
  final String? location;

  ///Status of the event -> whether the event is completed or not.
  final String? status;

  ///A short summary of the event.
  final String? summary;

  ///A person or the organisation who is organising the event.
  final String? organiser;

  ///String representing the raw value of the start time as encoded in the barcode.
  final String? startRawValue;

  ///Day of the month on which the event takes place.
  final int? startDate;

  ///Start hour of the calender event.
  final int? startHour;

  ///String representing the raw value of the end time of event as encoded in the barcode.
  final String? endRawValue;

  ///End day of the calender event.
  final int? endDate;

  ///Ending hour of the event.
  final int? endHour;

  BarcodeCalenderEvent._(Map<dynamic, dynamic> barcodeData)
      : description = barcodeData['description'],
        location = barcodeData['location'],
        status = barcodeData['status'],
        summary = barcodeData['summary'],
        organiser = barcodeData['organiser'],
        startRawValue = barcodeData['startRawValue'],
        startDate = barcodeData['startDate'],
        startHour = barcodeData['startHour'],
        endRawValue = barcodeData['endRawValue'],
        endDate = barcodeData['endDate'],
        endHour = barcodeData['endHour'],
        super._fromMap(barcodeData);
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

///Class to store the information of address type barcode detected in a [InputImage].
class BarcodeAddress {
  ///Formatted address, can be more than one line.
  final String? addressLines;

  ///Denoted the address type -> Home, Work or Unknown.
  final BarcodeAddressType? type;

  BarcodeAddress._(this.addressLines, this.type);

  factory BarcodeAddress._fromMap(Map<dynamic, dynamic> address) {
    return BarcodeAddress._(address['addressLines'],
        BarcodeAddressType.values[address['addressType']]);
  }
}
