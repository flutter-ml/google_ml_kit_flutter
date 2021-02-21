part of 'google_ml_kit.dart';

///Class to scan the barcode in [InputImage]
///Creating an instance of [BarcodeScanner]
///
/// BarcodeScanner barcodeScanner = GoogleMlKit.instance.barcodeScanner([List of Barcode formats (optional)]);
class BarcodeScanner {
  //List of barcode formats that can be provided to the instance to restrict search to specific barcode formats.
  final List<int> barcodeFormat;

  BarcodeScanner({List<int> formats})
      : barcodeFormat = formats ?? const [Barcode.FORMAT_Default];

  bool _isOpened = false;
  bool _isClosed = false;

  ///Function to process the [InputImage] and returns a list of [Barcode]
  Future<dynamic> processImage(InputImage inputImage) async {
    assert(inputImage != null);
    _isOpened = true;
    final result = await GoogleMlKit.channel.invokeMethod(
        'startBarcodeScanner', <String, dynamic>{
      'formats': barcodeFormat,
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
      await GoogleMlKit.channel.invokeMethod('closeBarcodeScanner');
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

///Class to represent the contents of barcode.
class Barcode {
  Barcode._({
    this.barcodeType,
    this.barcodeUnknown,
    this.barcodeWifi,
    this.barcodeUrl,
    this.barcodeEmail,
    this.barcodePhone,
    this.barcodeSMS,
    this.barcodeGeo,
    this.barcodeDriverLicense,
    this.barcodeContactInfo,
    this.barcodeCalenderEvent,
  });

  factory Barcode._fromMap(Map<dynamic, dynamic> barcodeData) {
    switch (barcodeData['type']) {
      case BarcodeType.TYPE_UNKNOWN:
      case BarcodeType.TYPE_ISBN:
      case BarcodeType.TYPE_TEXT:
      case BarcodeType.TYPE_PRODUCT:
        return Barcode._(
            barcodeUnknown: BarcodeRawOnly._fromMap(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_WIFI:
        return Barcode._(
            barcodeWifi: BarcodeWifi._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_URL:
        return Barcode._(
            barcodeUrl: BarcodeUrl._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_EMAIL:
        return Barcode._(
            barcodeEmail: BarcodeEmail._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_PHONE:
        return Barcode._(
            barcodePhone: BarcodePhone._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_SMS:
        return Barcode._(
            barcodeSMS: BarcodeSMS._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_GEO:
        return Barcode._(
            barcodeGeo: BarcodeGeo._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_DRIVER_LICENSE:
        return Barcode._(
            barcodeDriverLicense: BarcodeDriverLicense._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_CONTACT_INFO:
        return Barcode._(
            barcodeContactInfo: BarcodeContactInfo._(barcodeData),
            barcodeType: barcodeData['type']);
      case BarcodeType.TYPE_CALENDAR_EVENT:
        return Barcode._(
            barcodeCalenderEvent: BarcodeCalenderEvent._(barcodeData),
            barcodeType: barcodeData['type']);
      default:
        return Barcode._(
            barcodeUnknown: BarcodeRawOnly._fromMap(barcodeData),
            barcodeType: barcodeData['type']);
    }
  }

  ///Barcode formats supported by the barcode scanner.
  static const int FORMAT_Default = 0;

  static const int FORMAT_Code_128 = 1;

  static const int FORMAT_Code_39 = 2;

  static const int FORMAT_Code_93 = 4;

  static const int FORMAT_Codabar = 8;

  static const int FORMAT_EAN_13 = 32;

  static const int FORMAT_EAN_8 = 64;

  static const int FORMAT_ITF = 128;

  static const int FORMAT_UPC_A = 512;

  static const int FORMAT_UPC_E = 1024;

  static const int FORMAT_QR_Code = 256;

  static const int FORMAT_PDF417 = 2048;

  static const int FORMAT_Aztec = 4096;

  static const int FORMAT_Data_Matrix = 16;

  ///Type([BarcodeType]) of the barcode detected.
  final int barcodeType;
  final BarcodeWifi barcodeWifi;
  final BarcodeUrl barcodeUrl;
  final BarcodeEmail barcodeEmail;
  final BarcodePhone barcodePhone;
  final BarcodeSMS barcodeSMS;
  final BarcodeGeo barcodeGeo;
  final BarcodeDriverLicense barcodeDriverLicense;
  final BarcodeContactInfo barcodeContactInfo;
  final BarcodeCalenderEvent barcodeCalenderEvent;
  final BarcodeRawOnly barcodeUnknown;
}

///Base for storing barcode data.
///Any type of barcode has at least these three parameters.
class BarcodeRawOnly {
  final int type;
  final String rawValue;
  final String displayValue;

  BarcodeRawOnly._fromMap(Map<dynamic, dynamic> barcodeData)
      : type = barcodeData['type'],
        rawValue = barcodeData['rawValue'],
        displayValue = barcodeData['displayValue'];
}

///Class to store wifi info obtained from a barcode.
class BarcodeWifi extends BarcodeRawOnly {
  ///SSID of the wifi.
  final String ssid;

  ///Password of the wifi.
  final String password;

  ///Encryption type of wifi.
  final int encryptionType;

  BarcodeWifi._(Map<dynamic, dynamic> barcodeData)
      : ssid = barcodeData['ssid'],
        password = barcodeData['password'],
        encryptionType = barcodeData['encryption'],
        super._fromMap(barcodeData);
}

///Class to store url info of the bookmark obtained from a barcode.
class BarcodeUrl extends BarcodeRawOnly {
  ///String having the url address of bookmark.
  final String url;

  ///Title of the bookmark.
  final String title;

  BarcodeUrl._(Map<dynamic, dynamic> barcodeData)
      : url = barcodeData['url'],
        title = barcodeData['title'],
        super._fromMap(barcodeData);
}

///A email message.
class BarcodeEmail extends BarcodeRawOnly {
  ///Type of the email sent.
  ///0 = Unknown
  ///1 = Work
  ///2 = Home
  final int emailType;

  ///Email address of sender.
  final String address;

  ///Body of the email.
  final String body;

  ///Subject of email.
  final String subject;

  BarcodeEmail._(Map<dynamic, dynamic> barcodeData)
      : emailType = barcodeData['emailType'],
        address = barcodeData['address'],
        body = barcodeData['address'],
        subject = barcodeData['subject'],
        super._fromMap(barcodeData);
}

///A phone number.
class BarcodePhone extends BarcodeRawOnly {
  ///Type of the phone number.
  ///0 = Unknown
  ///1 = Work
  ///2 = Home
  final int phoneType;

  ///Phone numer.
  final String number;

  BarcodePhone._(Map<dynamic, dynamic> barcodeData)
      : phoneType = barcodeData['phoneType'],
        number = barcodeData['number'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeRawOnly] to store a SMS.
class BarcodeSMS extends BarcodeRawOnly {
  ///Message present in the SMS.
  final String message;

  ///Phone number of the sender.
  final String phoneNumber;

  BarcodeSMS._(Map<dynamic, dynamic> barcodeData)
      : message = barcodeData['message'],
        phoneNumber = barcodeData['number'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeRawOnly] that represents a geolocation.
class BarcodeGeo extends BarcodeRawOnly {
  ///Latitude co-ordinates of the location.
  final double latitude;
  ////Longitude co-ordinates of the location.
  final double longitude;

  BarcodeGeo._(Map<dynamic, dynamic> barcodeData)
      : latitude = barcodeData['latitude'],
        longitude = barcodeData['longitude'],
        super._fromMap(barcodeData);
}

///Class extending over [BarcodeRawOnly] that models a driver's licence cars.
class BarcodeDriverLicense extends BarcodeRawOnly {
  ///City of holder's address.
  final String addressCity;

  ///State of the holder's address.
  final String addressState;

  ///Zip code code of the holder's address.
  final String addressZip;

  ///Street of the holder's address.
  final String addressStreet;

  ///Date on which the license was issued.
  final String issueDate;

  ///Birth date of the card holder.
  final String birthDate;

  ///Expiry date of the license.
  final String expiryDate;

  ///Gender of the holder.
  final String gender;

  ///Driver license ID.
  final String licenseNumber;
  ////First name of the holder.
  final String firstName;

  ///Last name of the holder.
  final String lastName;

  ///Country of the holder.
  final String country;

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

///Class extending over [BarcodeRawOnly] that models a contact info.
class BarcodeContactInfo extends BarcodeRawOnly {
  ///Contact person's addresses.
  final List<BarcodeAddress> barcodeAddresses;

  ///Email addresses of the contact person.
  final List<BarcodeEmail> emails;

  ///Phone numbers of the contact person.
  final List<BarcodePhone> phoneNumbers;

  ///First name of the contact person.
  final String firstName;

  ///Last name of the peron.
  final String lastName;

  ///Properly formatted name of the person.
  final String formattedName;

  ///Organisation of the contact person.
  final String organisationName;

  ///Url's of contact person.
  final List<String> urls;

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

///Class extending over [BarcodeRawOnly] that models a calender event.
class BarcodeCalenderEvent extends BarcodeRawOnly {
  ///Description of the event.
  final String description;

  ///Location of the event.
  final String location;

  ///Status of the event -> whether the event is completed or not.
  final String status;

  ///A short summary of the event.
  final String summary;

  ///A person or the organisation who is organising the event.
  final String organiser;

  ///String representing the raw value of the start time as encoded in the barcode.
  final String startRawValue;

  ///Day of the month on which the event takes place.
  final int startDate;

  ///Start hour of the calender event.
  final int startHour;

  ///String representing the raw value of the end time of event as encoded in the barcode.
  final String endRawValue;

  ///End day of the calender event.
  final int endDate;

  ///Ending hour of the event.
  final int endHour;

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
  final String addressLines;

  ///Denoted the address type -> Home, Work or Unknown.
  final String type;

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
