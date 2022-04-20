import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Extracts entities from the given text.
/// Creating an instance.
/// ```
/// final _entityExtractor = EntityExtractor(EntityExtractorOptions.english);
/// ```
class EntityExtractor {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_entity_extractor');

  final EntityExtractorLanguage language;

  EntityExtractor({required this.language});

  /// Extracts entities from the given text and returns [List<EntityAnnotation>]
  Future<List<EntityAnnotation>> extractEntities(String text,
      {List<EntityType>? filters,
      String? localeLanguage,
      String? timeZone}) async {
    final parameters = <String, dynamic>{
      'filters': filters != null && filters.isNotEmpty
          ? filters.map((e) => e.index).toList()
          : null,
      'locale': localeLanguage,
      'timezone': timeZone,
    };

    final result = await _channel.invokeMethod(
        'nlp#startEntityExtractor', <String, dynamic>{
      'parameters': parameters,
      'text': text,
      'language': language.name
    });

    final annotations = <EntityAnnotation>[];
    for (final dynamic json in result) {
      annotations.add(EntityAnnotation.fromJson(json));
    }
    return annotations;
  }

  Future<void> close() => _channel.invokeMethod('nlp#closeEntityExtractor');
}

/// Creating instance of [EntityExtractorModelManager]
/// ```
/// final entityModelManager = EntityModelManager();
/// ```
class EntityExtractorModelManager extends ModelManager {
  EntityExtractorModelManager()
      : super(
            channel: EntityExtractor._channel,
            method: 'nlp#manageEntityExtractionModels');
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
        case EntityType.unknown:
          break;
        case EntityType.address:
          entities.add(AddressEntity(raw));
          break;
        case EntityType.dateTime:
          entities.add(DateTimeEntity(
              raw,
              DateTimeGranularity.values[entity['dateTimeGranularity'].toInt()],
              entity['timestamp'].toInt()));
          break;
        case EntityType.email:
          entities.add(EmailEntity(raw));
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
          entities.add(MoneyEntity(raw, entity['fraction'].toInt(),
              entity['integer'].toInt(), entity['unnormalized']));
          break;
        case EntityType.paymentCard:
          entities.add(PaymentCardEntity(raw,
              CardNetwork.values[entity['network'].toInt()], entity['number']));
          break;
        case EntityType.phone:
          entities.add(PhoneEntity(raw));
          break;
        case EntityType.trackingNumber:
          entities.add(TrackingNumberEntity(
              raw,
              TrackingCarrier.values[entity['carrier'].toInt()],
              entity['number']));
          break;
        case EntityType.url:
          entities.add(UrlEntity(raw));
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
  final EntityType type;

  Entity(this.rawValue, this.type);

  @override
  String toString() => rawValue;
}

class AddressEntity extends Entity {
  AddressEntity(String string) : super(string, EntityType.address);
}

enum DateTimeGranularity {
  unknown,
  year,
  month,
  week,
  day,
  hour,
  minute,
  second,
}

class DateTimeEntity extends Entity {
  final DateTimeGranularity dateTimeGranularity;
  final int timeStamp;

  DateTimeEntity(String string, this.dateTimeGranularity, this.timeStamp)
      : super(string, EntityType.dateTime);
}

class EmailEntity extends Entity {
  EmailEntity(String string) : super(string, EntityType.email);
}

class FlightNumberEntity extends Entity {
  final String airlineCode;
  final String flightNumber;

  FlightNumberEntity(String string, this.airlineCode, this.flightNumber)
      : super(string, EntityType.flightNumber);
}

class IbanEntity extends Entity {
  final String iban;
  final String countryCode;

  IbanEntity(String string, this.iban, this.countryCode)
      : super(string, EntityType.iban);
}

class IsbnEntity extends Entity {
  final String isbn;

  IsbnEntity(String string, this.isbn) : super(string, EntityType.isbn);
}

class MoneyEntity extends Entity {
  final int fraction;
  final int integer;
  final String currency;

  MoneyEntity(String string, this.fraction, this.integer, this.currency)
      : super(string, EntityType.money);
}

enum CardNetwork {
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
  final CardNetwork network;
  final String number;

  PaymentCardEntity(String string, this.network, this.number)
      : super(string, EntityType.paymentCard);
}

class PhoneEntity extends Entity {
  PhoneEntity(String string) : super(string, EntityType.phone);
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
  final TrackingCarrier carrier;
  final String number;

  TrackingNumberEntity(String string, this.carrier, this.number)
      : super(string, EntityType.trackingNumber);
}

class UrlEntity extends Entity {
  UrlEntity(String string) : super(string, EntityType.url);
}
