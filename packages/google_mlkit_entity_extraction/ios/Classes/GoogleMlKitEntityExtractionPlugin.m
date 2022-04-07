#import "GoogleMlKitEntityExtractionPlugin.h"
#import <MLKitEntityExtraction/MLKitEntityExtraction.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_entity_extractor"
#define startEntityExtractor @"nlp#startEntityExtractor"
#define closeEntityExtractor @"nlp#closeEntityExtractor"
#define manageEntityExtractionModels @"nlp#manageEntityExtractionModels"

@implementation GoogleMlKitEntityExtractionPlugin {
    MLKEntityExtractor *entityExtractor;
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitEntityExtractionPlugin* instance = [[GoogleMlKitEntityExtractionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startEntityExtractor]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:manageEntityExtractionModels]) {
        [self manageModel:call result:result];
    } else if ([call.method isEqualToString:closeEntityExtractor]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *language = call.arguments[@"language"];
    NSDictionary *parameters = call.arguments[@"parameters"];
    NSString *text = call.arguments[@"text"];
    
    MLKEntityExtractorOptions *options = [[MLKEntityExtractorOptions alloc] initWithModelIdentifier:language];
    entityExtractor =
    [MLKEntityExtractor entityExtractorWithOptions:options];
    
    MLKEntityExtractionParams *params = [[MLKEntityExtractionParams alloc] init];
    
    NSString *timezone = parameters[@"timezone"];
    if (timezone != NULL) {
        params.referenceTimeZone = [NSTimeZone timeZoneWithAbbreviation:timezone];
    }
    
    NSString *locale = parameters[@"locale"];
    if (locale != NULL) {
        params.preferredLocale = [NSLocale localeWithLocaleIdentifier:locale];
    }
    
    [entityExtractor annotateText:text
                       withParams:params
                       completion:^(NSArray *_Nullable annotations, NSError *_Nullable error) {
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
            data[@"text"] = text;
            data[@"start"] = @((int)annotation.range.location);
            data[@"end"] = @((int)(annotation.range.location + annotation.range.length));
            
            NSMutableArray *allEntities = [NSMutableArray array];
            NSArray *entities = annotation.entities;
            for (MLKEntity *entity in entities) {
                NSMutableDictionary *entityData = [NSMutableDictionary dictionary];
                NSString *type = entity.entityType;
                entityData[@"type"] = type;
                entityData[@"raw"] = [NSString stringWithFormat:@"%@", entity];
                
                if ([type isEqualToString: MLKEntityExtractionEntityTypeDateTime]) {
                    entityData[@"dateTimeGranularity"] = @(entity.dateTimeEntity.dateTimeGranularity);
                    entityData[@"timestamp"] = @(entity.dateTimeEntity.dateTime.timeIntervalSince1970);
                }
                
                [allEntities addObject:entityData];
            }
            data[@"entities"] = allEntities;
            [allAnnotations addObject:data];
        }
        
        result(allAnnotations);
    }];
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    MLKEntityExtractionRemoteModel *model =  [MLKEntityExtractionRemoteModel entityExtractorRemoteModelWithIdentifier:modelTag];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
