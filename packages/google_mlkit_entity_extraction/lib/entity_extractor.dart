import 'package:flutter/services.dart';

/// Extracts entities from the given text.
/// Creating an instance.
/// ```
/// final _entityExtractor = EntityExtractor(EntityExtractorOptions.english);
/// ```
class EntityExtractor {
  final EntityExtractorLanguage language;

  bool _isOpened = false;
  bool _isClosed = false;
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_entity_extractor');

  EntityExtractor(this.language);

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
      'language': language.name
    });

    final annotation = <EntityAnnotation>[];
    for (final dynamic data in result) {
      annotation.add(EntityAnnotation.fromJson(data));
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
  static const MethodChannel _channel = EntityExtractor._channel;

  EntityModelManager();

  /// Checks whether a model is downloaded or not.
  Future<bool> isModelDownloaded(EntityExtractorLanguage language) async {
    final result = await _channel.invokeMethod(
        'nlp#manageEntityExtractionModels',
        <String, dynamic>{'task': 'check', 'model': language.name});
    return result as bool;
  }

  /// Downloads a model.
  /// Returns true if model downloads successfully or model is already downloaded.
  /// On failing to download it throws an error.
  Future<bool> downloadModel(EntityExtractorLanguage language,
      {bool isWifiRequired = true}) async {
    final result = await _channel.invokeMethod(
        'nlp#manageEntityExtractionModels', <String, dynamic>{
      'task': 'download',
      'model': language.name,
      'wifi': isWifiRequired
    });
    return result.toString() == 'success';
  }

  /// Deletes a model.
  /// Returns true if model is deleted successfully or model is not present.
  Future<bool> deleteModel(EntityExtractorLanguage language) async {
    final result = await _channel
        .invokeMethod('nlp#manageEntityExtractionModels', <String, dynamic>{
      'task': 'delete',
      'model': language.name,
    });
    return result.toString() == 'success';
  }

  /// Returns a list of all downloaded models.
  /// These are `BCP-47` tags.
  Future<List<String>> getAvailableModels() async {
    final result = await _channel
        .invokeMethod('nlp#manageEntityExtractionModels', <String, dynamic>{
      'task': 'getModels',
    });

    final _languages = <String>[];

    for (final dynamic data in result) {
      _languages.add(data.toString());
    }
    return _languages;
  }
}

enum EntityExtractorLanguage {
  arabic,
  chinese,
  dutch,
  english,
  french,
  german,
  italian,
  japanese,
  korean,
  polish,
  portuguese,
  russian,
  spanish,
  thai,
  turkish,
}

class EntityAnnotation {
  final int start;
  final int end;
  final String text;
  final List<Entity> entities;

  EntityAnnotation(this.start, this.end, this.text, this.entities);

  factory EntityAnnotation.fromJson(Map<dynamic, dynamic> json) {
    final entities = <Entity>[];
    for (final dynamic entity in json['entities']) {
      final value = entity['type'];
      final EntityType type = value < EntityType.values.length
          ? EntityType.values[value]
          : EntityType.unknown;
      final raw = entity['raw'].toString();
      switch (type) {
        case EntityType.address:
          entities.add(AddressEntity(raw));
          break;
        case EntityType.url:
          entities.add(UrlEntity(raw));
          break;
        case EntityType.phone:
          entities.add(PhoneEntity(raw));
          break;
        case EntityType.email:
          entities.add(EmailEntity(raw));
          break;
        case EntityType.dateTime:
          entities.add(DateTimeEntity(
              raw, entity['dateTimeGranularity'], entity['timestamp']));
          break;
        case EntityType.flightNumber:
          entities
              .add(FlightNumberEntity(raw, entity['code'], entity['number']));
          break;
        case EntityType.iban:
          entities.add(IbanEntity(raw, entity['iban'], entity['code']));
          break;
        case EntityType.isbn:
          entities.add(IsbnEntity(raw, entity['isbn']));
          break;
        case EntityType.money:
          entities.add(MoneyEntity(raw, entity['fraction'], entity['integer'],
              entity['unnormalized']));
          break;
        case EntityType.paymentCard:
          entities
              .add(PaymentCardEntity(raw, entity['network'], entity['number']));
          break;
        case EntityType.trackingNumber:
          entities.add(
              TrackingNumberEntity(raw, entity['carrier'], entity['number']));
          break;
        default:
          break;
      }
    }
    return EntityAnnotation(json['start'], json['end'], json['text'], entities);
  }

  @override
  String toString() {
    return '{start: $start, end: $end, text: $text, entities: $entities}';
  }
}

enum EntityType {
  unknown,
  address,
  dateTime,
  email,
  flightNumber,
  iban,
  isbn,
  money,
  paymentCard,
  phone,
  trackingNumber,
  url,
}

abstract class Entity {
  final String rawValue;

  Entity(this.rawValue);

  @override
  String toString() => rawValue;
}

class DateTimeEntity extends Entity {
  final int dateTimeGranularity;
  final int timeStamp;

  DateTimeEntity(String string, this.dateTimeGranularity, this.timeStamp)
      : super(string);
}

enum TrackingCarrier {
  unknown,
  fedex,
  ups,
  dhl,
  usps,
  ontrac,
  lasership,
  israelPost,
  swissPost,
  mcs,
  amazon,
  iParcel,
}

class TrackingNumberEntity extends Entity {
  final int carrier;
  final String number;

  TrackingNumberEntity(String string, this.carrier, this.number)
      : super(string);
}

enum CardNerwork {
  unknown,
  amex,
  dinersClub,
  discover,
  interPayment,
  jcb,
  maestro,
  mastercard,
  mir,
  troy,
  unionpay,
  visa,
}

class PaymentCardEntity extends Entity {
  final int network;
  final String number;

  PaymentCardEntity(String string, this.network, this.number) : super(string);
}

class IbanEntity extends Entity {
  final String iban;
  final String countryCode;

  IbanEntity(String string, this.iban, this.countryCode) : super(string);
}

class MoneyEntity extends Entity {
  final int fraction;
  final int integer;
  final String currency;

  MoneyEntity(String string, this.fraction, this.integer, this.currency)
      : super(string);
}

class IsbnEntity extends Entity {
  final String isbn;

  IsbnEntity(String string, this.isbn) : super(string);
}

class FlightNumberEntity extends Entity {
  final String airlineCode;
  final String flightNumber;

  FlightNumberEntity(String string, this.airlineCode, this.flightNumber)
      : super(string);
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
