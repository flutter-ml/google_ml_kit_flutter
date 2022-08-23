#import "GoogleMlKitObjectDetectionPlugin.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitObjectDetection/MLKitObjectDetection.h>
#import <MLKitObjectDetectionCommon/MLKitObjectDetectionCommon.h>
#import <MLKitObjectDetectionCustom/MLKitObjectDetectionCustom.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#if MLKIT_FIREBASE_MODELS
#import <MLKitLinkFirebase/MLKitLinkFirebase.h>
#endif

#define channelName @"google_mlkit_object_detector"
#define startObjectDetector @"vision#startObjectDetector"
#define closeObjectDetector @"vision#closeObjectDetector"
#define manageFirebaseModels @"vision#manageFirebaseModels"

@implementation GoogleMlKitObjectDetectionPlugin {
    NSMutableDictionary *instances;
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitObjectDetectionPlugin* instance = [[GoogleMlKitObjectDetectionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startObjectDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeObjectDetector]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else if ([call.method isEqualToString:manageFirebaseModels]) {
#if MLKIT_FIREBASE_MODELS
        [self manageModel:call result:result];
#else
        result([FlutterError errorWithCode:@"ERROR_MISSING_MLKIT_FIREBASE_MODELS" message:@"You must define MLKIT_FIREBASE_MODELS=1 in your Podfile." details:nil]);
#endif
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    
    NSString *uid = call.arguments[@"id"];
    MLKObjectDetector *objectDetector = [instances objectForKey:uid];
    if (objectDetector == NULL) {
        NSDictionary *dictionary = call.arguments[@"options"];
        NSString *type = dictionary[@"type"];
        if ([@"base" isEqualToString:type]) {
            MLKObjectDetectorOptions *options = [self getDefaultOptions:dictionary];
            objectDetector = [MLKObjectDetector objectDetectorWithOptions:options];
        } else if ([@"local" isEqualToString:type]) {
            MLKCustomObjectDetectorOptions *options = [self getLocalOptions:dictionary];
            objectDetector = [MLKObjectDetector objectDetectorWithOptions:options];
        } else if ([@"remote" isEqualToString:type]) {
#if MLKIT_FIREBASE_MODELS
            MLKCustomObjectDetectorOptions *options = [self getRemoteOptions:dictionary];
            if (options == NULL) {
                FlutterError *error = [FlutterError errorWithCode:@"Error Model has not been downloaded yet"
                                                          message:@"Model has not been downloaded yet"
                                                          details:@"Model has not been downloaded yet"];
                result(error);
                return;
            }
            objectDetector = [MLKObjectDetector objectDetectorWithOptions:options];
#else
            result([FlutterError errorWithCode:@"ERROR_MISSING_MLKIT_FIREBASE_MODELS" message:@"You must define MLKIT_FIREBASE_MODELS=1 in your Podfile." details:nil]);
#endif
        } else {
            NSString *error = [NSString stringWithFormat:@"Invalid model type: %@", type];
            result([FlutterError errorWithCode:type
                                       message:error
                                       details:error]);
            return;
        }
        instances[uid] = objectDetector;
    }
    
    [objectDetector processImage:image
                      completion:^(NSArray *_Nullable objects,
                                   NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!objects) {
            result(@[]);
            return;
        }
        
        NSMutableArray *objectsData = [NSMutableArray array];
        for (MLKObject *object in objects) {
            NSMutableArray *labels = [NSMutableArray array];
            for (MLKObjectLabel *label in object.labels) {
                [labels addObject:@{
                    @"index" : @(label.index),
                    @"text" : label.text,
                    @"confidence" : @(label.confidence),
                }];
            }
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{
                @"rect" : @{
                    @"left" : @(object.frame.origin.x),
                    @"top" : @(object.frame.origin.y),
                    @"right" : @(object.frame.origin.x + object.frame.size.width),
                    @"bottom" : @(object.frame.origin.y + object.frame.size.height)
                },
                @"labels" : labels
            }];
            if (object.trackingID != NULL) {
                data[@"trackingId"] = object.trackingID;
            }
            [objectsData addObject:data];
        }
        
        result(objectsData);
    }];
}

- (MLKObjectDetectorOptions *)getDefaultOptions:(NSDictionary *)dictionary {
    NSNumber *mode = dictionary[@"mode"];
    BOOL classify = [[dictionary objectForKey:@"classify"] boolValue];
    BOOL multiple = [[dictionary objectForKey:@"multiple"] boolValue];
    
    MLKObjectDetectorOptions *options = [[MLKObjectDetectorOptions alloc] init];
    options.detectorMode = mode.intValue == 0 ? MLKObjectDetectorModeStream : MLKObjectDetectorModeSingleImage;
    options.shouldEnableClassification = classify;
    options.shouldEnableMultipleObjects = multiple;
    return options;
}

- (MLKCustomObjectDetectorOptions *)getLocalOptions:(NSDictionary *)dictionary {
    NSNumber *mode = dictionary[@"mode"];
    BOOL classify = [[dictionary objectForKey:@"classify"] boolValue];
    BOOL multiple = [[dictionary objectForKey:@"multiple"] boolValue];
    NSNumber *threshold = dictionary[@"threshold"];
    NSNumber *maxLabels = dictionary[@"maxLabels"];
    NSString *path = dictionary[@"path"];
    
    MLKLocalModel *localModel = [[MLKLocalModel alloc] initWithPath:path];
    MLKCustomObjectDetectorOptions *options =  [[MLKCustomObjectDetectorOptions alloc] initWithLocalModel:localModel];
    options.detectorMode = mode.intValue == 0 ? MLKObjectDetectorModeStream : MLKObjectDetectorModeSingleImage;
    options.shouldEnableClassification = classify;
    options.shouldEnableMultipleObjects = multiple;
    options.classificationConfidenceThreshold = threshold;
    options.maxPerObjectLabelCount = maxLabels.integerValue;
    return options;
}

#if MLKIT_FIREBASE_MODELS
- (MLKCustomObjectDetectorOptions *)getRemoteOptions:(NSDictionary *)dictionary {
    NSNumber *mode = dictionary[@"mode"];
    BOOL classify = [[dictionary objectForKey:@"classify"] boolValue];
    BOOL multiple = [[dictionary objectForKey:@"multiple"] boolValue];
    NSNumber *threshold = dictionary[@"threshold"];
    NSNumber *maxLabels = dictionary[@"maxLabels"];
    NSString *modelName = dictionary[@"modelName"];
    
    MLKFirebaseModelSource *firebaseModelSource = [[MLKFirebaseModelSource alloc] initWithName:modelName];
    MLKCustomRemoteModel *remoteModel = [[MLKCustomRemoteModel alloc] initWithRemoteModelSource:firebaseModelSource];
    
    MLKModelManager *modelManager = [MLKModelManager modelManager];
    BOOL isModelDownloaded = [modelManager isModelDownloaded:remoteModel];
    if (!isModelDownloaded) {
        return NULL;
    }
    
    MLKCustomObjectDetectorOptions *options = [[MLKCustomObjectDetectorOptions alloc] initWithRemoteModel:remoteModel];
    options.detectorMode = mode.intValue == 0 ? MLKObjectDetectorModeStream : MLKObjectDetectorModeSingleImage;
    options.shouldEnableClassification = classify;
    options.shouldEnableMultipleObjects = multiple;
    options.classificationConfidenceThreshold = threshold;
    options.maxPerObjectLabelCount = maxLabels.integerValue;
    return options;
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    MLKFirebaseModelSource *firebaseModelSource = [[MLKFirebaseModelSource alloc] initWithName:modelTag];
    MLKCustomRemoteModel *model = [[MLKCustomRemoteModel alloc] initWithRemoteModelSource:firebaseModelSource];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}
#endif

@end
