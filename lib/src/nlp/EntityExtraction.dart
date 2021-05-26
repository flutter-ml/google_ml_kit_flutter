part of 'NaturalLanguage.dart';

/// Extracts entities from the given text.
/// Creating an instance.
/// ```
/// final _entityExtractor = GoogleMlKit.nlp.
///                          entityExtractor(EntityExtractorOptions.ENGLISH);
/// ```
class EntityExtractor {
  final String _language;
  bool _isOpened = false;
  bool _isClosed = false;

  EntityExtractor._(this._language);

  /// Extracts entities from the given text and returns [List<EntityAnnotation>]
  Future<List<EntityAnnotation>> extractEntities(String text,
      {List<int>? filters, String? localeLanguage, String? timeZone}) async {
    final parameters = <String, dynamic>{
      'filters': filters,
      'locale': localeLanguage,
      'timezone': timeZone,
    };

    final result = await NaturalLanguage.channel.invokeMethod(
        'nlp#startEntityExtractor', <String, dynamic>{
      'parameters': parameters,
      'text': text,
      'language': _language
    });

    var annotation = <EntityAnnotation>[];
    for (dynamic data in result) {
      annotation.add(EntityAnnotation.instance(data));
    }
    return annotation;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await NaturalLanguage.channel.invokeMethod('nlp#closeEntityExtractor');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

/// Creating instance of [EntityModelManager]
/// ```
/// final _onDeviceTranslator = GoogleMlKit.nlp
///      .onDeviceTranslator(sourceLanguage: TranslateLanguage.ENGLISH,
///       targetLanguage: TranslateLanguage.SPANISH);
/// ```
class EntityModelManager {
  EntityModelManager._();

  /// Checks whether a model is downloaded or not.
  Future<bool> isModelDownloaded(String modelTag) async {
    final result = await NaturalLanguage.channel.invokeMethod(
        "nlp#startEntityModelManager",
        <String, dynamic>{"task": "check", "model": modelTag});
    return result as bool;
  }

  /// Downloads a model.
  /// Returns `success` if model downloads succesfully or model is already downloaded.
  /// On failing to dowload it throws an error.
  Future<String> downloadModel(String modelTag,
      {bool isWifiRequired = true}) async {
    final result = await NaturalLanguage.channel.invokeMethod(
        "nlp#startEntityModelManager", <String, dynamic>{
      "task": "download",
      "model": modelTag,
      "wifi": isWifiRequired
    });
    return result.toString();
  }

  /// Deletes a model.
  /// Returns `success` if model is delted successfully or model is not present.
  Future<String> deleteModel(String modelTag) async {
    final result = await NaturalLanguage.channel
        .invokeMethod("nlp#startEntityModelManager", <String, dynamic>{
      "task": "delete",
      "model": modelTag,
    });
    return result.toString();
  }

  /// Returns a list of all downloaded models.
  /// These are `BCP-47` tags.
  Future<List<String>> getAvailableModels() async {
    final result = await NaturalLanguage.channel
        .invokeMethod("nlp#startEntityModelManager", <String, dynamic>{
      "task": "getModels",
    });

    var _languages = <String>[];

    for (dynamic data in result) {
      _languages.add(data.toString());
    }
    return _languages;
  }
}

class EntityExtractorOptions {
  static const String ARABIC = 'arabic';
  static const String CHINESE = 'chinese';
  static const String DUTCH = 'dutch';
  static const String ENGLISH = 'english';
  static const String FRENCH = 'french';
  static const String GERMAN = 'german';
  static const String ITALIAN = 'italian';
  static const String JAPANESE = 'japanese';
  static const String KOREAN = 'korean';
  static const String POLISH = 'polish';
  static const String PORTUGUESE = 'portuguese';
  static const String RUSSIAN = 'russian';
  static const String SPANISH = 'spanish';
  static const String THAI = 'thai';
  static const String TURKISH = 'turkish';
}

class Entity {
  final String _string;

  static const int TYPE_ADDRESS = 1;
  static const int TYPE_DATE_TIME = 2;
  static const int TYPE_EMAIL = 3;
  static const int TYPE_FLIGHT_NUMBER = 4;
  static const int TYPE_IBAN = 5;
  static const int TYPE_ISBN = 6;
  static const int TYPE_MONEY = 11;
  static const int TYPE_PAYMENT_CARD = 7;
  static const int TYPE_PHONE = 8;
  static const int TYPE_TRACKING_NUMBER = 9;
  static const int TYPE_URL = 10;

  Entity(this._string);

  @override
  String toString() => _string;
}

class EntityAnnotation {
  final int start;
  final int end;
  final String text;
  final List<Entity> entities;

  EntityAnnotation._(this.start, this.end, this.text, this.entities);

  static EntityAnnotation instance(Map<dynamic, dynamic> annotation) {
    var entities = <Entity>[];

    for (dynamic entity in annotation['entities']) {
      var type = entity['type'];
      var raw = entity['raw'];
      switch (type) {
        case Entity.TYPE_ADDRESS:
          entities.add(AddressEntity(raw));
          break;
        case Entity.TYPE_URL:
          entities.add(UrlEntity(raw));
          break;
        case Entity.TYPE_PHONE:
          entities.add(PhoneEntity(raw));
          break;
        case Entity.TYPE_EMAIL:
          entities.add(EmailEntity(raw));
          break;
        case Entity.TYPE_DATE_TIME:
          entities.add(DateTimeEntity(raw.toString(),
              entity['dateTimeGranularity'], entity['timestamp']));
          break;
        case Entity.TYPE_FLIGHT_NUMBER:
          entities
              .add(FlightNumberEntity(raw, entity['code'], entity['number']));
          break;
        case Entity.TYPE_IBAN:
          entities.add(IbanEntity(raw, entity['iban'], entity['code']));
          break;
        case Entity.TYPE_ISBN:
          entities.add(IsbnEntity(raw, entity['isbn']));
          break;
        case Entity.TYPE_MONEY:
          entities.add(MoneyEntity(raw, entity['fraction'], entity['integer'],
              entity['unnormalized']));
          break;
        case Entity.TYPE_PAYMENT_CARD:
          entities
              .add(PaymentCardEntity(raw, entity['network'], entity['number']));
          break;
        case Entity.TYPE_TRACKING_NUMBER:
          entities.add(
              TrackingNumberEntity(raw, entity['carrier'], entity['number']));
          break;
        default:
      }
    }

    return EntityAnnotation._(
        annotation['start'], annotation['end'], annotation['text'], entities);
  }
}

class DateTimeEntity extends Entity {
  final int _dateTimeGranularity;
  final int _timeStamp;
  DateTimeEntity(String string, this._dateTimeGranularity, this._timeStamp)
      : super(string);

  int getDateTimeGranularity() => _dateTimeGranularity;

  int getTimestampMillis() => _timeStamp;
}

class TrackingNumberEntity extends Entity {
  static const int CARRIER_AMAZON = 10;
  static const int CARRIER_DHL = 3;
  static const int CARRIER_FEDEX = 1;
  static const int CARRIER_ISRAEL_POST = 7;
  static const int CARRIER_I_PARCEL = 11;
  static const int CARRIER_LASERSHIP = 6;
  static const int CARRIER_MSC = 9;
  static const int CARRIER_ONTRAC = 5;
  static const int CARRIER_SWISS_POST = 8;
  static const int CARRIER_UNKNOWN = 0;
  static const int CARRIER_UPS = 2;
  static const int CARRIER_USPS = 4;

  final int _carrier;
  final String _number;

  TrackingNumberEntity(String string, this._carrier, this._number)
      : super(string);

  int getParcelCarrier() => _carrier;

  String getParcelTrackingNumber() => _number;
}

class PaymentCardEntity extends Entity {
  static const CARD_AMEX = 1;
  static const CARD_DINERS_CLUB = 2;
  static const CARD_DISCOVER = 3;
  static const CARD_INTER_PAYMENT = 4;
  static const CARD_JCB = 5;
  static const CARD_MAESTRO = 6;
  static const CARD_MASTERCARD = 7;
  static const CARD_MIR = 8;
  static const CARD_TROY = 9;
  static const CARD_UNIONPAY = 10;
  static const CARD_UNKNOWN = 0;
  static const CARD_VISA = 11;

  final int _network;
  final String _number;
  PaymentCardEntity(String string, this._network, this._number) : super(string);

  int getPaymentCardNetwork() => _network;

  String getPaymentCardNumber() => _number;
}

class IbanEntity extends Entity {
  final String _iban;
  final String _countryCode;

  IbanEntity(String string, this._iban, this._countryCode) : super(string);

  String getIban() => _iban;

  String getIbanCountryCode() => _countryCode;
}

class MoneyEntity extends Entity {
  final int _fraction;
  final int _integer;
  final String _currency;

  MoneyEntity(String string, this._fraction, this._integer, this._currency)
      : super(string);

  int getFractionalPart() => _fraction;

  int getIntegerPart() => _integer;

  String getUnnormalizedCurrency() => _currency;
}

class IsbnEntity extends Entity {
  final String _isbn;

  IsbnEntity(String string, this._isbn) : super(string);

  String getIsbn() => _isbn;
}

class FlightNumberEntity extends Entity {
  final String _airlineCode;
  final String _flightNumber;

  FlightNumberEntity(String string, this._airlineCode, this._flightNumber)
      : super(string);

  String getAirlineCode() => _airlineCode;

  String getFlightNumber() => _flightNumber;
}

class AddressEntity extends Entity {
  AddressEntity(String string) : super(string);
}

class UrlEntity extends Entity {
  UrlEntity(String string) : super(string);
}

class PhoneEntity extends Entity {
  PhoneEntity(String string) : super(string);
}

class EmailEntity extends Entity {
  EmailEntity(String string) : super(string);
}
