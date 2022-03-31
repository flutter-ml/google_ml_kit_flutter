import 'package:flutter/services.dart';

/// Extracts entities from the given text.
/// Creating an instance.
/// ```
/// final _entityExtractor = EntityExtractor(EntityExtractorOptions.ENGLISH);
/// ```
class EntityExtractor {
  final String _language;
  bool _isOpened = false;
  bool _isClosed = false;
  static const MethodChannel _channel =
      MethodChannel('google_ml_kit_entity_extraction');

  EntityExtractor(this._language);

  /// Extracts entities from the given text and returns [List<EntityAnnotation>]
  Future<List<EntityAnnotation>> extractEntities(String text,
      {List<int>? filters, String? localeLanguage, String? timeZone}) async {
    final parameters = <String, dynamic>{
      'filters': filters,
      'locale': localeLanguage,
      'timezone': timeZone,
    };

    final result = await _channel.invokeMethod(
        'nlp#startEntityExtractor', <String, dynamic>{
      'parameters': parameters,
      'text': text,
      'language': _language
    });

    final annotation = <EntityAnnotation>[];
    for (final dynamic data in result) {
      annotation.add(EntityAnnotation.instance(data));
    }
    return annotation;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await _channel.invokeMethod('nlp#closeEntityExtractor');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

/// Creating instance of [EntityModelManager]
/// ```
/// final entityModelManager = EntityModelManager();
/// ```
class EntityModelManager {
  static const MethodChannel _channel =
      MethodChannel('google_ml_kit_entity_extraction');

  EntityModelManager();

  /// Checks whether a model is downloaded or not.
  Future<bool> isModelDownloaded(String modelTag) async {
    final result = await _channel.invokeMethod('nlp#startEntityModelManager',
        <String, dynamic>{'task': 'check', 'model': modelTag});
    return result as bool;
  }

  /// Downloads a model.
  /// Returns `success` if model downloads succesfully or model is already downloaded.
  /// On failing to dowload it throws an error.
  Future<String> downloadModel(String modelTag,
      {bool isWifiRequired = true}) async {
    final result = await _channel.invokeMethod(
        'nlp#startEntityModelManager', <String, dynamic>{
      'task': 'download',
      'model': modelTag,
      'wifi': isWifiRequired
    });
    return result.toString();
  }

  /// Deletes a model.
  /// Returns `success` if model is delted successfully or model is not present.
  Future<String> deleteModel(String modelTag) async {
    final result = await _channel
        .invokeMethod('nlp#startEntityModelManager', <String, dynamic>{
      'task': 'delete',
      'model': modelTag,
    });
    return result.toString();
  }

  /// Returns a list of all downloaded models.
  /// These are `BCP-47` tags.
  Future<List<String>> getAvailableModels() async {
    final result = await _channel
        .invokeMethod('nlp#startEntityModelManager', <String, dynamic>{
      'task': 'getModels',
    });

    final _languages = <String>[];

    for (final dynamic data in result) {
      _languages.add(data.toString());
    }
    return _languages;
  }
}

class EntityExtractorOptions {
  static const String arabic = 'arabic';
  static const String chinese = 'chinese';
  static const String dutch = 'dutch';
  static const String english = 'english';
  static const String french = 'french';
  static const String german = 'german';
  static const String italian = 'italian';
  static const String japanese = 'japanese';
  static const String korean = 'korean';
  static const String polish = 'polish';
  static const String portuguese = 'portuguese';
  static const String russian = 'russian';
  static const String spanish = 'spanish';
  static const String thai = 'thai';
  static const String turkish = 'turkish';
}

class Entity {
  final String _string;

  static const int unknown = 0;
  static const int address = 1;
  static const int dateTime = 2;
  static const int email = 3;
  static const int flightNumber = 4;
  static const int iban = 5;
  static const int isbn = 6;
  static const int money = 11;
  static const int paymentCard = 7;
  static const int phone = 8;
  static const int trackingNumber = 9;
  static const int url = 10;

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
    final entities = <Entity>[];

    for (final dynamic entity in annotation['entities']) {
      final type = entity['type'];
      final raw = entity['raw'];
      switch (type) {
        case Entity.address:
          entities.add(AddressEntity(raw));
          break;
        case Entity.url:
          entities.add(UrlEntity(raw));
          break;
        case Entity.phone:
          entities.add(PhoneEntity(raw));
          break;
        case Entity.email:
          entities.add(EmailEntity(raw));
          break;
        case Entity.dateTime:
          entities.add(DateTimeEntity(raw.toString(),
              entity['dateTimeGranularity'], entity['timestamp']));
          break;
        case Entity.flightNumber:
          entities
              .add(FlightNumberEntity(raw, entity['code'], entity['number']));
          break;
        case Entity.iban:
          entities.add(IbanEntity(raw, entity['iban'], entity['code']));
          break;
        case Entity.isbn:
          entities.add(IsbnEntity(raw, entity['isbn']));
          break;
        case Entity.money:
          entities.add(MoneyEntity(raw, entity['fraction'], entity['integer'],
              entity['unnormalized']));
          break;
        case Entity.paymentCard:
          entities
              .add(PaymentCardEntity(raw, entity['network'], entity['number']));
          break;
        case Entity.trackingNumber:
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
  static const int unknown = 0;
  static const int fedex = 1;
  static const int ups = 2;
  static const int dhl = 3;
  static const int usps = 4;
  static const int ontrac = 5;
  static const int lasership = 6;
  static const int israelPost = 7;
  static const int swissPost = 8;
  static const int mcs = 9;
  static const int amazon = 10;
  static const int iParcel = 11;

  final int _carrier;
  final String _number;

  TrackingNumberEntity(String string, this._carrier, this._number)
      : super(string);

  int getParcelCarrier() => _carrier;

  String getParcelTrackingNumber() => _number;
}

class PaymentCardEntity extends Entity {
  static const int unknown = 0;
  static const int amex = 1;
  static const int dinersClub = 2;
  static const int discover = 3;
  static const int interPayment = 4;
  static const int jcb = 5;
  static const int maestro = 6;
  static const int mastercard = 7;
  static const int mir = 8;
  static const int troy = 9;
  static const int unionpay = 10;
  static const int visa = 11;

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
