import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A class that extracts entities from the given input text.
class EntityExtractor {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_entity_extractor');

  /// The language used when parsing entities in the text.
  final EntityExtractorLanguage language;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [EntityExtractor].
  EntityExtractor({required this.language});

  /// Annotates the given text with the given parameters such as reference time, preferred locale, reference time zone and entity types filter.
  /// Returns a list of [EntityAnnotation] or returns empty list if there is no identified entity.
  ///
  /// [referenceTime] should be expressed in milliseconds since epoch.
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
      'id': id,
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
  Future<void> close() =>
      _channel.invokeMethod('nlp#closeEntityExtractor', {'id': id});
}

/// A subclass of [ModelManager] that manages [EntityExtractorRemoteModel].
class EntityExtractorModelManager extends ModelManager {
  /// Constructor to create an instance of [EntityExtractorModelManager].
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

  /// The text segment within the original text that this annotation refers to.
  final String text;

  /// A list of possible entities in the given span of text.
  final List<Entity> entities;

  /// Constructor to create an instance of [EntityAnnotation].
  EntityAnnotation(
      {required this.start,
      required this.end,
      required this.text,
      required this.entities});

  /// Returns an instance of [EntityAnnotation] from a given [json].
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
          entities.add(DateTimeEntity(raw,
              dateTimeGranularity: DateTimeGranularity
                  .values[entity['dateTimeGranularity'].toInt()],
              timestamp: entity['timestamp'].toInt()));
          break;
        case EntityType.email:
          entities.add(EmailEntity(raw));
          break;
        case EntityType.flightNumber:
          entities.add(FlightNumberEntity(raw,
              airlineCode: entity['code'], flightNumber: entity['number']));
          break;
        case EntityType.iban:
          entities.add(IbanEntity(raw,
              iban: entity['iban'], countryCode: entity['code']));
          break;
        case EntityType.isbn:
          entities.add(IsbnEntity(raw, isbn: entity['isbn']));
          break;
        case EntityType.money:
          entities.add(MoneyEntity(raw,
              fractionPart: entity['fraction'].toInt(),
              integerPart: entity['integer'].toInt(),
              unnormalizedCurrency: entity['unnormalized']));
          break;
        case EntityType.paymentCard:
          entities.add(PaymentCardEntity(raw,
              network: PaymentCardNetwork.values[entity['network'].toInt()],
              number: entity['number']));
          break;
        case EntityType.phone:
          entities.add(PhoneEntity(raw));
          break;
        case EntityType.trackingNumber:
          entities.add(TrackingNumberEntity(raw,
              carrier: TrackingCarrier.values[entity['carrier'].toInt()],
              number: entity['number']));
          break;
        case EntityType.url:
          entities.add(UrlEntity(raw));
          break;
      }
    }
    return EntityAnnotation(
        start: json['start'],
        end: json['end'],
        text: json['text'],
        entities: entities);
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
  paymentCard,
  phone,
  trackingNumber,
  url,
  money,
}

/// An entity extracted from a piece of text.
abstract class Entity {
  /// The string representation of the entity.
  final String rawValue;

  /// The type of an extracted entity.
  final EntityType type;

  /// Constructor to create an instance of [Entity].
  Entity({required this.rawValue, required this.type});

  @override
  String toString() => '{type: ${type.name}}';
}

/// An address entity extracted from text.
class AddressEntity extends Entity {
  /// Constructor to create an instance of [AddressEntity].
  AddressEntity(String rawValue)
      : super(rawValue: rawValue, type: EntityType.address);
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

  /// Constructor to create an instance of [DateTimeEntity].
  DateTimeEntity(String rawValue,
      {required this.dateTimeGranularity, required this.timestamp})
      : super(rawValue: rawValue, type: EntityType.dateTime);

  @override
  String toString() =>
      '{type: ${type.name}, timestamp: $timestamp, granularity: ${dateTimeGranularity.name}}';
}

/// An email entity extracted from text.
class EmailEntity extends Entity {
  /// Constructor to create an instance of [EmailEntity].
  EmailEntity(String rawValue)
      : super(rawValue: rawValue, type: EntityType.email);
}

/// An flight number entity extracted from text.
class FlightNumberEntity extends Entity {
  /// The IATA airline designator (two or three letters).
  final String airlineCode;

  /// The flight number (1 to 4 digit number).
  final String flightNumber;

  /// Constructor to create an instance of [FlightNumberEntity].
  FlightNumberEntity(String rawValue,
      {required this.airlineCode, required this.flightNumber})
      : super(rawValue: rawValue, type: EntityType.flightNumber);

  @override
  String toString() =>
      '{type: ${type.name}, flightNumber: $flightNumber, airlineCode: $airlineCode}';
}

/// An IBAN entity extracted from text.
class IbanEntity extends Entity {
  /// The full IBAN number in canonical form.
  final String iban;

  /// The ISO 3166-1 alpha-2 country code (two letters).
  final String countryCode;

  /// Constructor to create an instance of [IbanEntity].
  IbanEntity(String rawValue, {required this.iban, required this.countryCode})
      : super(rawValue: rawValue, type: EntityType.iban);

  @override
  String toString() =>
      '{type: ${type.name}, iban: $iban, countryCode: $countryCode}';
}

/// An ISBN entity extracted from text.
class IsbnEntity extends Entity {
  /// The full ISBN number in canonical form.
  final String isbn;

  /// Constructor to create an instance of [IsbnEntity].
  IsbnEntity(String rawValue, {required this.isbn})
      : super(rawValue: rawValue, type: EntityType.isbn);

  @override
  String toString() => '{type: ${type.name}, isbn: $isbn}';
}

/// A money entity extracted from text.
class MoneyEntity extends Entity {
  /// The fractional part of the detected annotation. This is the integer written to the right of the decimal separator.
  final int fractionPart;

  /// The integer part of the detected annotation. This is the integer written to the left of the decimal separator.
  final int integerPart;

  /// The currency part of the detected annotation. No formatting is applied so this will return a subset of the initial string.
  final String unnormalizedCurrency;

  /// Constructor to create an instance of [MoneyEntity].
  MoneyEntity(String rawValue,
      {required this.fractionPart,
      required this.integerPart,
      required this.unnormalizedCurrency})
      : super(rawValue: rawValue, type: EntityType.money);

  @override
  String toString() => '{type: ${type.name}, currency: $unnormalizedCurrency}';
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

  /// Constructor to create an instance of [PaymentCardEntity].
  PaymentCardEntity(String rawValue,
      {required this.network, required this.number})
      : super(rawValue: rawValue, type: EntityType.paymentCard);

  @override
  String toString() =>
      '{type: ${type.name}, number: $number, network: $network}';
}

/// A phone number entity extracted from text.
class PhoneEntity extends Entity {
  /// Constructor to create an instance of [PhoneEntity].
  PhoneEntity(String rawValue)
      : super(rawValue: rawValue, type: EntityType.phone);
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

  /// Constructor to create an instance of [TrackingNumberEntity].
  TrackingNumberEntity(String rawValue,
      {required this.carrier, required this.number})
      : super(rawValue: rawValue, type: EntityType.trackingNumber);

  @override
  String toString() =>
      '{type: ${type.name}, number: $number, carrier: $carrier}';
}

/// An URL entity extracted from text.
class UrlEntity extends Entity {
  /// Constructor to create an instance of [UrlEntity].
  UrlEntity(String rawValue) : super(rawValue: rawValue, type: EntityType.url);
}
