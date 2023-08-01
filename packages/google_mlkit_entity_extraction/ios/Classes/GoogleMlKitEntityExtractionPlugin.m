#import "GoogleMlKitEntityExtractionPlugin.h"
#import <MLKitEntityExtraction/MLKitEntityExtraction.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_entity_extractor"
#define startEntityExtractor @"nlp#startEntityExtractor"
#define closeEntityExtractor @"nlp#closeEntityExtractor"
#define manageEntityExtractionModels @"nlp#manageEntityExtractionModels"

@implementation GoogleMlKitEntityExtractionPlugin {
    NSMutableDictionary *instances;
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitEntityExtractionPlugin* instance = [[GoogleMlKitEntityExtractionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startEntityExtractor]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:manageEntityExtractionModels]) {
        [self manageModel:call result:result];
    } else if ([call.method isEqualToString:closeEntityExtractor]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *text = call.arguments[@"text"];
    
    NSString *uid = call.arguments[@"id"];
    MLKEntityExtractor *entityExtractor = [instances objectForKey:uid];
    if (entityExtractor == NULL) {
        NSString *language = call.arguments[@"language"];
        MLKEntityExtractorOptions *options = [[MLKEntityExtractorOptions alloc] initWithModelIdentifier:language];
        entityExtractor = [MLKEntityExtractor entityExtractorWithOptions:options];
        instances[uid] = entityExtractor;
    }
    
    MLKEntityExtractionParams *params = [[MLKEntityExtractionParams alloc] init];
    NSDictionary *parameters = call.arguments[@"parameters"];
    
    NSString *timezone = parameters[@"timezone"];
    if ([timezone isKindOfClass: [NSString class]] && timezone.length > 0) {
        params.referenceTimeZone = [NSTimeZone timeZoneWithAbbreviation:timezone];
    }

    NSString *time = parameters[@"time"];
    if ([time isKindOfClass: [NSNumber class]]) {
        // NSTimeInterval should is expressed in seconds, not milliseconds
        params.referenceTime = [NSDate dateWithTimeIntervalSince1970: time.doubleValue / 1000];
    }
    
    NSString *locale = parameters[@"locale"];
    if ([locale isKindOfClass: [NSString class]] && locale.length > 0) {
        params.preferredLocale = [NSLocale localeWithLocaleIdentifier:locale];
    }
    
    NSArray *filtersValues = parameters[@"filters"];
    if ([filtersValues isKindOfClass: [NSArray class]] && filtersValues.count > 0) {
        NSMutableSet *filters = [NSMutableSet set];
        for(NSNumber *number in filtersValues) {
            int value = number.intValue;
            switch(value) {
                case 1:
                    [filters addObject:MLKEntityExtractionEntityTypeAddress];
                    break;
                case 2:
                    [filters addObject:MLKEntityExtractionEntityTypeDateTime];
                    break;
                case 3:
                    [filters addObject:MLKEntityExtractionEntityTypeEmail];
                    break;
                case 4:
                    [filters addObject:MLKEntityExtractionEntityTypeFlightNumber];
                    break;
                case 5:
                    [filters addObject:MLKEntityExtractionEntityTypeIBAN];
                    break;
                case 6:
                    [filters addObject:MLKEntityExtractionEntityTypeISBN];
                    break;
                case 7:
                    [filters addObject:MLKEntityExtractionEntityTypePaymentCard];
                    break;
                case 8:
                    [filters addObject:MLKEntityExtractionEntityTypePhone];
                    break;
                case 9:
                    [filters addObject:MLKEntityExtractionEntityTypeTrackingNumber];
                    break;
                case 10:
                    [filters addObject:MLKEntityExtractionEntityTypeURL];
                    break;
                case 11:
                    [filters addObject:MLKEntityExtractionEntityTypeMoney];
                    break;
                default:
                    break;
            }
        }
        params.typesFilter = filters;
    }
    
    [entityExtractor downloadModelIfNeededWithCompletion:^(NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        }
        // Model downloaded successfully. Okay to annotate.
        
        [entityExtractor annotateText:text
                           withParams:params
                           completion:^(NSArray *_Nullable annotations,
                                        NSError *_Nullable error) {
            if (error) {
                result(getFlutterError(error));
                return;
            } else if (!annotations) {
                result(NULL);
                return;
            }
            
            NSMutableArray *allAnnotations = [NSMutableArray array];
            for (MLKEntityAnnotation *annotation in annotations) {
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                data[@"text"] = [text substringWithRange:annotation.range];
                data[@"start"] = @((int)annotation.range.location);
                data[@"end"] = @((int)(annotation.range.location + annotation.range.length));
                
                NSMutableArray *allEntities = [NSMutableArray array];
                NSArray *entities = annotation.entities;
                for (MLKEntity *entity in entities) {
                    NSMutableDictionary *entityData = [NSMutableDictionary dictionary];
                    int type = 0;
                    
                    if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeAddress]) {
                        type = 1;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeDateTime]) {
                        type = 2;
                        entityData[@"dateTimeGranularity"] = @(entity.dateTimeEntity.dateTimeGranularity);
                        // result is expected in milliseconds, not seconds.
                        entityData[@"timestamp"] = @(entity.dateTimeEntity.dateTime.timeIntervalSince1970 * 1000);
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeEmail]) {
                        type = 3;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeFlightNumber]) {
                        type = 4;
                        entityData[@"code"] = entity.flightNumberEntity.airlineCode;
                        entityData[@"number"] = entity.flightNumberEntity.flightNumber;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeIBAN]) {
                        type = 5;
                        entityData[@"iban"] = entity.IBANEntity.IBAN;
                        entityData[@"code"] = entity.IBANEntity.countryCode;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeISBN]) {
                        type = 6;
                        entityData[@"isbn"] = entity.ISBNEntity.ISBN;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypePaymentCard]) {
                        type = 7;
                        entityData[@"network"] = @(entity.paymentCardEntity.paymentCardNetwork);
                        entityData[@"number"] = entity.paymentCardEntity.paymentCardNumber;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypePhone]) {
                        type = 8;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeTrackingNumber]) {
                        type = 9;
                        entityData[@"carrier"] = @(entity.trackingNumberEntity.parcelCarrier);
                        entityData[@"number"] = entity.trackingNumberEntity.parcelTrackingNumber;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeURL]) {
                        type = 10;
                    } else if ([entity.entityType isEqualToString: MLKEntityExtractionEntityTypeMoney]) {
                       type = 11;
                       entityData[@"fraction"] = @(entity.moneyEntity.fractionalPart);
                       entityData[@"integer"] = @(entity.moneyEntity.integerPart);
                       entityData[@"unnormalized"] = entity.moneyEntity.unnormalizedCurrency;
                    }
                    
                    entityData[@"type"] = @(type);
                    entityData[@"raw"] = [NSString stringWithFormat:@"%@", entity];
                    
                    [allEntities addObject:entityData];
                }
                data[@"entities"] = allEntities;
                [allAnnotations addObject:data];
            }
            
            result(allAnnotations);
        }];
    }];
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    MLKEntityExtractionRemoteModel *model =  [MLKEntityExtractionRemoteModel entityExtractorRemoteModelWithIdentifier:modelTag];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
