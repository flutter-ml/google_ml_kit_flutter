import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A class that extracts entities from the given input text.
class EntityExtractor {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_entity_extractor');

  /// The language used when parsing entities in the text.
  final EntityExtractorLanguage language;

  EntityExtractor({required this.language});

  /// Annotates the given text with the given parameters such as reference time, preferred locale, reference time zone and entity types filter.
  /// Returns a list of [EntityAnnotation] or returns empty list if there is no identified entity.
  Future<List<EntityAnnotation>> annotateText(
    String text, {
    int? referenceTime,
    String? preferredLocale,
    String? referenceTimeZone,
    List<EntityType>? entityTypesFilter,
  }) async {
    final parameters = <String, dynamic>{
      'filters': entityTypesFilter != null && entityTypesFilter.isNotEmpty
          ? entityTypesFilter.map((e) => e.index).toList()
          : null,
      'locale': preferredLocale,
      'timezone': referenceTimeZone,
      'time': referenceTime,
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

  /// Closes the extractor and releases its resources.
  Future<void> close() => _channel.invokeMethod('nlp#closeEntityExtractor');
}

/// A subclass of [ModelManager] that manages [EntityExtractorRemoteModel].
/// Calling download model always return false, model is downloaded if needed when annotating text.
class EntityExtractorModelManager extends ModelManager {
  EntityExtractorModelManager()
      : super(
            channel: EntityExtractor._channel,
            method: 'nlp#manageEntityExtractionModels');
}

/// Languages supported by [EntityExtractor].
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

/// An object that contains the possible entities associated with a piece of the text.
class EntityAnnotation {
  /// The start of the annotation in the given text.
  final int start;

  /// The end of the annotation in the given text.
  final int end;

  /// The text segment within the original text that this annotation refers to
  final String text;

  /// A list of possible entities in the given span of text.
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
          entities.add(PaymentCardEntity(
              raw,
              PaymentCardNetwork.values[entity['network'].toInt()],
              entity['number']));
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

/// The type of an extracted entity.
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

/// An entity extracted from a piece of text.
abstract class Entity {
  /// The string representation of the entity.
  final String rawValue;

  /// The type of an extracted entity.
  final EntityType type;

  Entity(this.rawValue, this.type);

  @override
  String toString() => rawValue;
}

/// An address entity extracted from text.
class AddressEntity extends Entity {
  AddressEntity(String string) : super(string, EntityType.address);
}

/// The precision of a timestamp that was extracted from text.
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

/// A date and time entity extracted from text.
class DateTimeEntity extends Entity {
  /// The granularity of the date and time.
  final DateTimeGranularity dateTimeGranularity;

  /// The parsed timestamp in milliseconds from the epoch of 1970-01-01T00:00:00Z (UTC timezone).
  final int timestamp;

  DateTimeEntity(String string, this.dateTimeGranularity, this.timestamp)
      : super(string, EntityType.dateTime);
}

/// An email entity extracted from text.
class EmailEntity extends Entity {
  EmailEntity(String string) : super(string, EntityType.email);
}

/// An flight number entity extracted from text.
class FlightNumberEntity extends Entity {
  /// The IATA airline designator (two or three letters).
  final String airlineCode;

  /// The flight number (1 to 4 digit number).
  final String flightNumber;

  FlightNumberEntity(String string, this.airlineCode, this.flightNumber)
      : super(string, EntityType.flightNumber);
}

/// An IBAN entity extracted from text.
class IbanEntity extends Entity {
  /// The full IBAN number in canonical form.
  final String iban;

  /// The ISO 3166-1 alpha-2 country code (two letters).
  final String countryCode;

  IbanEntity(String string, this.iban, this.countryCode)
      : super(string, EntityType.iban);
}

/// An ISBN entity extracted from text.
class IsbnEntity extends Entity {
  /// The full ISBN number in canonical form.
  final String isbn;

  IsbnEntity(String string, this.isbn) : super(string, EntityType.isbn);
}

/// A money entity extracted from text.
class MoneyEntity extends Entity {
  /// The fractional part of the detected annotation. This is the integer written to the right of the decimal separator.
  final int fractionPart;

  /// The integer part of the detected annotation. This is the integer written to the left of the decimal separator.
  final int integerPart;

  /// The currency part of the detected annotation. No formatting is applied so this will return a subset of the initial string.
  final String unnormalizedCurrency;

  MoneyEntity(String string, this.fractionPart, this.integerPart,
      this.unnormalizedCurrency)
      : super(string, EntityType.money);
}

/// The supported payment card networks that can be detected.
enum PaymentCardNetwork {
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

/// A payment card entity extracted from text.
class PaymentCardEntity extends Entity {
  /// The payment card network.
  final PaymentCardNetwork network;

  /// The payment card number in canonical form.
  final String number;

  PaymentCardEntity(String string, this.network, this.number)
      : super(string, EntityType.paymentCard);
}

/// A phone number entity extracted from text.
class PhoneEntity extends Entity {
  PhoneEntity(String string) : super(string, EntityType.phone);
}

/// The supported parcel tracking carriers that can be detected.
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

/// A tracking number extracted from text.
class TrackingNumberEntity extends Entity {
  /// The parcel tracking carrier.
  final TrackingCarrier carrier;

  /// The parcel tracking number in canonical form.
  final String number;

  TrackingNumberEntity(String string, this.carrier, this.number)
      : super(string, EntityType.trackingNumber);
}

/// An URL entity extracted from text.
class UrlEntity extends Entity {
  UrlEntity(String string) : super(string, EntityType.url);
}
