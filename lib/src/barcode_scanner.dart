part of 'google_ml_kit.dart';

class BarcodeScanner {
  final List<int> barcodeFormat;

  BarcodeScanner({List<int> formats})
  : barcodeFormat =
  formats == null ? const [Barcode.FORMAT_Default] : formats;

  bool _isOpened = false;
  bool _isClosed = false;

  Future<dynamic> processImage(InputImage inputImage) async {
    assert(inputImage!=null);
    _isOpened = true;
    List<dynamic> result =
    await GoogleMlKit.channel.invokeMethod("startBarcodeScanner",<String,dynamic>{
      "formats" : barcodeFormat,
      "imageData": inputImage._getImageData()
    });

    List<Barcode> barcodesList = <Barcode>[];
    for(dynamic item in result){
      barcodesList.add(Barcode._fromMap(item));
    }

    print(barcodesList);

    return barcodesList;
  }

  Future<void> close() async{
    if (!_isClosed && _isOpened) {
      await GoogleMlKit.channel.invokeMethod("closeBarcodeScanner");
      _isClosed = true;
      _isOpened = false;
    }
  }


}

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

class Barcode {
  Barcode._(
    {this.barcodeType,this.barcodeUnknown,this.barcodeWifi,
      this.barcodeUrl,
      this.barcodeEmail,
      this.barcodePhone,
      this.barcodeSMS,
      this.barcodeGeo,
      this.barcodeDriverLicense,
      this.barcodeContactInfo,
      this.barcodeCalenderEvent,
      });

  factory Barcode._fromMap(Map<dynamic,dynamic> barcodeData){
    switch(barcodeData["type"]){
      case BarcodeType.TYPE_UNKNOWN:
      case BarcodeType.TYPE_ISBN:
      case BarcodeType.TYPE_TEXT:
      case BarcodeType.TYPE_PRODUCT:
      return Barcode._(barcodeUnknown:BarcodeRawOnly._fromMap(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_WIFI:
      return Barcode._(barcodeWifi: BarcodeWifi._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_URL :
      return Barcode._(barcodeUrl:BarcodeUrl._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_EMAIL:
      return Barcode._(barcodeEmail:BarcodeEmail._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_PHONE:
      return Barcode._(barcodePhone:BarcodePhone._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_SMS:
      return Barcode._(barcodeSMS:BarcodeSMS._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_GEO:
      return Barcode._(barcodeGeo:BarcodeGeo._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_DRIVER_LICENSE:
      return Barcode._(barcodeDriverLicense:BarcodeDriverLicense._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_CONTACT_INFO:
      return Barcode._(barcodeContactInfo:BarcodeContactInfo._(barcodeData),barcodeType: barcodeData["type"]);
      case BarcodeType.TYPE_CALENDAR_EVENT:
      return Barcode._(barcodeCalenderEvent:BarcodeCalenderEvent._(barcodeData),barcodeType: barcodeData["type"]);
      default:
      return Barcode._(barcodeUnknown:BarcodeRawOnly._fromMap(barcodeData),barcodeType: barcodeData["type"]);
    }
  }

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

class BarcodeRawOnly {
  final int type;
  final String rawValue;
  final String displayValue;

  BarcodeRawOnly._fromMap(Map<dynamic, dynamic> barcodeData)
  : type = barcodeData["type"],
  rawValue = barcodeData["rawValue"],
  displayValue = barcodeData["displayValue"];
}

class BarcodeWifi extends BarcodeRawOnly {
  final String ssid;
  final String password;
  final int encryptionType;

  BarcodeWifi._(Map<dynamic, dynamic> barcodeData)
  : ssid = barcodeData["ssid"],
  password = barcodeData["password"],
  encryptionType = barcodeData["encryption"],
  super._fromMap(barcodeData);
}

class BarcodeUrl extends BarcodeRawOnly {
  final String url;
  final String title;

  BarcodeUrl._(Map<dynamic, dynamic> barcodeData)
  : url = barcodeData["url"],
  title = barcodeData["title"],
  super._fromMap(barcodeData);
}

class BarcodeEmail extends BarcodeRawOnly {
  final int type;
  final String address;
  final String body;
  final String subject;

  BarcodeEmail._(Map<dynamic, dynamic> barcodeData)
  : type = barcodeData["emailType"],
  address = barcodeData["address"],
  body = barcodeData["address"],
  subject = barcodeData["subject"],
  super._fromMap(barcodeData);
}

class BarcodePhone extends BarcodeRawOnly {
  final int type;
  final String number;

  BarcodePhone._(Map<dynamic, dynamic> barcodeData)
  : type = barcodeData["phoneType"],
  number = barcodeData["number"],
  super._fromMap(barcodeData);
}

class BarcodeSMS extends BarcodeRawOnly {
  final String message;
  final String phoneNumber;

  BarcodeSMS._(Map<dynamic, dynamic> barcodeData)
  : message = barcodeData["message"],
  phoneNumber = barcodeData["number"],
  super._fromMap(barcodeData);
}

class BarcodeGeo extends BarcodeRawOnly {
  final double latitude;
  final double longitude;

  BarcodeGeo._(Map<dynamic, dynamic> barcodeData)
  : latitude = barcodeData["latitude"],
  longitude = barcodeData["longitude"],
  super._fromMap(barcodeData);
}

class BarcodeDriverLicense extends BarcodeRawOnly {
  final String addressCity;
  final String addressState;
  final String addressZip;
  final String addressStreet;
  final String issueDate;
  final String birthDate;
  final String expiryDate;
  final String gender;
  final String licenseNumber;
  final String firstName;
  final String lastName;
  final String country;

  BarcodeDriverLicense._(Map<dynamic, dynamic> barcodeData)
  : addressCity = barcodeData["addressCity"],
  addressState = barcodeData["addressState"],
  addressZip = barcodeData["addressZip"],
  addressStreet = barcodeData["addressStreet"],
  issueDate = barcodeData["issueDate"],
  birthDate = barcodeData["birthDate"],
  expiryDate = barcodeData["expiryDate"],
  gender = barcodeData["gender"],
  licenseNumber = barcodeData["licenseNumber"],
  firstName = barcodeData["firstName"],
  lastName = barcodeData["lastName"],
  country = barcodeData["country"],
  super._fromMap(barcodeData);
}

class BarcodeContactInfo extends BarcodeRawOnly {
  final List<BarcodeAddress> barcodeAddresses;
  final List<BarcodeEmail> emails;
  final List<BarcodePhone> phoneNumbers;
  final String firstName;
  final String lastName;
  final String formattedName;
  final String organisationName;
  final List<String> urls;

  BarcodeContactInfo._(Map<dynamic, dynamic> barcodeData)
  : barcodeAddresses = barcodeData["addresses"] = barcodeData["addresses"]
  .map<BarcodeAddress>((address) => BarcodeAddress._fromMap(address)),
  emails = barcodeData["emails"] = barcodeData["emails"]
  .map<BarcodeEmail>((email) => BarcodeEmail._(email)),
  phoneNumbers = barcodeData["contactNumbers"] =
  barcodeData["contactNumbers"]
  .map<BarcodePhone>((number) => BarcodePhone),
  firstName = barcodeData["firstName"],
  lastName = barcodeData["lastName"],
  formattedName = barcodeData["formattedName"],
  organisationName = barcodeData["organisation"],
  urls = barcodeData["urls"] as List<String>,
  super._fromMap(barcodeData);
}

class BarcodeCalenderEvent extends BarcodeRawOnly {
  final String description;
  final String location;
  final String status;
  final String summary;
  final String organiser;
  final String startRawValue;
  final int startDate;
  final int startHour;
  final String endRawValue;
  final int endDate;
  final int endHour;

  BarcodeCalenderEvent._(Map<dynamic, dynamic> barcodeData)
  : description = barcodeData["description"],
  location = barcodeData["location"],
  status = barcodeData["status"],
  summary = barcodeData["summary"],
  organiser = barcodeData["organiser"],
  startRawValue = barcodeData["startRawValue"],
  startDate = barcodeData["startDate"],
  startHour = barcodeData["startHour"],
  endRawValue = barcodeData["endRawValue"],
  endDate = barcodeData["endDate"],
  endHour = barcodeData["endHour"],
  super._fromMap(barcodeData);
}

class BarcodeAddress {
  final String addressLines;
  final String type;

  BarcodeAddress._(this.addressLines, this.type);

  factory BarcodeAddress._fromMap(Map<dynamic, dynamic> address) {
    String addressType;
    switch (address["addressType"]) {
      case 0:
      addressType = "Unknown";
      break;
      case 1:
      addressType = "Home";
      break;
      case 2:
      addressType = "Work";
      break;
      default:
      addressType = "Unknown";
    }
    return BarcodeAddress._(address["addressLines"], addressType);
  }
}
