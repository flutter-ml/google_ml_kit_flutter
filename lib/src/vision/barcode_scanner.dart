part of 'vision.dart';

///Class to scan the barcode in [InputImage]
///Creating an instance of [BarcodeScanner]
///
/// BarcodeScanner barcodeScanner = GoogleMlKit.instance.barcodeScanner([List of Barcode formats (optional)]);
class BarcodeScanner {
  //List of barcode formats that can be provided to the instance to restrict search to specific barcode formats.
  final List<int> barcodeFormats;

  BarcodeScanner({List<int>? formats})
      : barcodeFormats = formats ?? const [BarcodeFormat.Default];

  bool _isOpened = false;
  bool _isClosed = false;

  ///Function to process the [InputImage] and returns a list of [Barcode]
  Future<dynamic> processImage(InputImage inputImage) async {
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

///All supported Barcode Types.
class BarcodeType {
  static const int TYPE_UNKNOWN = 0;
  static const int TYPE_CONTACT_INFO = 1;
  static const int TYPE_EMAIL = 2;
  static const int TYPE_ISBN = 3;
  static const int TYPE_PHONE = 4;
  static const int TYPE_PRODUCT = 5;
  static const int TYPE_SMS = 6;
  static const int TYPE_TEXT = 7;
  static const int TYPE_URL = 8;
  static const int TYPE_WIFI = 9;
  static const int TYPE_GEO = 10;
  static const int TYPE_CALENDAR_EVENT = 11;
  static const int TYPE_DRIVER_LICENSE = 12;
}

///Barcode formats supported by the barcode scanner.
class BarcodeFormat {
  static const int Default = 0;
  static const int Code_128 = 1;
  static const int Code_39 = 2;
  static const int Code_93 = 4;
  static const int Codebar = 8;
  static const int EAN_13 = 32;
  static const int EAN_8 = 64;
  static const int ITF = 128;
  static const int UPC_A = 512;
  static const int UPC_E = 1024;
  static const int QR_Code = 256;
  static const int PDF417 = 2048;
  static const int Aztec = 4096;
  static const int Data_Matrix = 16;
}

///Class to represent the contents of barcode.
class Barcode {
  Barcode._({
    this.type,
    this.info,
  });

  ///Type([BarcodeType]) of the barcode detected.
  final int? type;
  final BarcodeInfo? info;

  factory Barcode._fromMap(Map<dynamic, dynamic> barcodeData) {
    int type = barcodeData['type'];
    switch (type) {
      case BarcodeType.TYPE_UNKNOWN:
      case BarcodeType.TYPE_ISBN:
      case BarcodeType.TYPE_TEXT:
      case BarcodeType.TYPE_PRODUCT:
        return Barcode._(info: BarcodeInfo._fromMap(barcodeData), type: type);
      case BarcodeType.TYPE_WIFI:
        return Barcode._(info: BarcodeWifi._(barcodeData), type: type);
      case BarcodeType.TYPE_URL:
        return Barcode._(info: BarcodeUrl._(barcodeData), type: type);
      case BarcodeType.TYPE_EMAIL:
        return Barcode._(info: BarcodeEmail._(barcodeData), type: type);
      case BarcodeType.TYPE_PHONE:
        return Barcode._(info: BarcodePhone._(barcodeData), type: type);
      case BarcodeType.TYPE_SMS:
        return Barcode._(info: BarcodeSMS._(barcodeData), type: type);
      case BarcodeType.TYPE_GEO:
        return Barcode._(info: BarcodeGeo._(barcodeData), type: type);
      case BarcodeType.TYPE_DRIVER_LICENSE:
        return Barcode._(info: BarcodeDriverLicense._(barcodeData), type: type);
      case BarcodeType.TYPE_CONTACT_INFO:
        return Barcode._(info: BarcodeContactInfo._(barcodeData), type: type);
      case BarcodeType.TYPE_CALENDAR_EVENT:
        return Barcode._(info: BarcodeCalenderEvent._(barcodeData), type: type);
      default:
        return Barcode._(info: BarcodeInfo._fromMap(barcodeData), type: type);
    }
  }
}

///Base for storing barcode data.
///Any type of barcode has at least these three parameters.
class BarcodeInfo {
  final int type;
  final String rawValue;
  final String displayValue;
  final Rect boundingBox;

  BarcodeInfo._fromMap(Map<dynamic, dynamic> barcodeData)
      : type = barcodeData['type'],
        rawValue = barcodeData['rawValue'],
        displayValue = barcodeData['displayValue'],
        boundingBox = Rect.fromLTRB(
            (barcodeData['boundingBoxLeft']).toDouble(),
            (barcodeData['boundingBoxTop']).toDouble(),
            (barcodeData['boundingBoxRight']).toDouble(),
            (barcodeData['boundingBoxBottom']).toDouble());
}

///Class to store wifi info obtained from a barcode.
class BarcodeWifi extends BarcodeInfo {
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
class BarcodeUrl extends BarcodeInfo {
  ///String having the url address of bookmark.
  final String? url;

  ///Title of the bookmark.
  final String? title;

  BarcodeUrl._(Map<dynamic, dynamic> barcodeData)
      : url = barcodeData['url'],
        title = barcodeData['title'],
        super._fromMap(barcodeData);
}

///A email message.
class BarcodeEmail extends BarcodeInfo {
  ///Type of the email sent.
  ///0 = Unknown
  ///1 = Work
  ///2 = Home
  final int? emailType;

  ///Email address of sender.
  final String? address;

  ///Body of the email.
  final String? body;

  ///Subject of email.
  final String? subject;

  BarcodeEmail._(Map<dynamic, dynamic> barcodeData)
      : emailType = barcodeData['emailType'],
        address = barcodeData['address'],
        body = barcodeData['body'],
        subject = barcodeData['subject'],
        super._fromMap(barcodeData);
}

///A phone number.
class BarcodePhone extends BarcodeInfo {
  ///Type of the phone number.
  ///0 = Unknown
  ///1 = Work
  ///2 = Home
  final int? phoneType;

  ///Phone numer.
  final String? number;

  BarcodePhone._(Map<dynamic, dynamic> barcodeData)
      : phoneType = barcodeData['phoneType'],
        number = barcodeData['number'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeInfo] to store a SMS.
class BarcodeSMS extends BarcodeInfo {
  ///Message present in the SMS.
  final String? message;

  ///Phone number of the sender.
  final String? phoneNumber;

  BarcodeSMS._(Map<dynamic, dynamic> barcodeData)
      : message = barcodeData['message'],
        phoneNumber = barcodeData['number'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeInfo] that represents a geolocation.
class BarcodeGeo extends BarcodeInfo {
  ///Latitude co-ordinates of the location.
  final double? latitude;

  ////Longitude co-ordinates of the location.
  final double? longitude;

  BarcodeGeo._(Map<dynamic, dynamic> barcodeData)
      : latitude = barcodeData['latitude'],
        longitude = barcodeData['longitude'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeInfo] that models a driver's licence cars.
class BarcodeDriverLicense extends BarcodeInfo {
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

///Class extending over [BarcodeInfo] that models a contact info.
class BarcodeContactInfo extends BarcodeInfo {
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

///Class extending over [BarcodeInfo] that models a calender event.
class BarcodeCalenderEvent extends BarcodeInfo {
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

///Class to store the information of address type barcode detected in a [InputImage].
class BarcodeAddress {
  ///Formatted address, can be more than one line.
  final String? addressLines;

  ///Denoted the address type -> Home, Work or Unknown.
  final String? type;

  BarcodeAddress._(this.addressLines, this.type);

  factory BarcodeAddress._fromMap(Map<dynamic, dynamic> address) {
    String addressType;
    switch (address['addressType']) {
      case 0:
        addressType = 'Unknown';
        break;
      case 1:
        addressType = 'Home';
        break;
      case 2:
        addressType = 'Work';
        break;
      default:
        addressType = 'Unknown';
    }
    return BarcodeAddress._(address['addressLines'], addressType);
  }
}
