#import "GoogleMlKitObjectDetectionPlugin.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitObjectDetection/MLKitObjectDetection.h>
#import <MLKitObjectDetectionCommon/MLKitObjectDetectionCommon.h>
#import <MLKitObjectDetectionCustom/MLKitObjectDetectionCustom.h>
#import <MLKitLinkFirebase/MLKitLinkFirebase.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_object_detector"
#define startObjectDetector @"vision#startObjectDetector"
#define closeObjectDetector @"vision#closeObjectDetector"
#define manageFirebaseModels @"vision#manageFirebaseModels"

@implementation GoogleMlKitObjectDetectionPlugin {
    MLKObjectDetector *objectDetector;
    GenericModelManager *genericModelManager;
    BOOL custom;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitObjectDetectionPlugin* instance = [[GoogleMlKitObjectDetectionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startObjectDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeObjectDetector]) {
    } else if ([call.method isEqualToString:manageFirebaseModels]) {
        [self manageModel:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    
    NSDictionary *dictionary = call.arguments[@"options"];
    BOOL isCustom = [[dictionary objectForKey:@"custom"] boolValue];
    
    if (objectDetector == NULL || custom != isCustom) {
        [self initiateDetector: dictionary];
    }
    
    [objectDetector
     processImage:image
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
            NSDictionary *data = @{
                @"rect" : @{
                    @"left" : @(object.frame.origin.x),
                    @"top" : @(object.frame.origin.y),
                    @"right" : @(object.frame.origin.x + object.frame.size.width),
                    @"bottom" : @(object.frame.origin.y + object.frame.size.height)
                },
                @"labels" : labels,
                @"trackingId" : object.trackingID,
                
            };
            [objectsData addObject:data];
        }
        
        result(objectsData);
    }];
}

- (void)initiateDetector:(NSDictionary *) dictionary {
    custom = [[dictionary objectForKey:@"custom"] boolValue];
    if (custom) {
        [self  initiateCustomDetector: dictionary];
    } else {
        [self  initiateBaseDetector: dictionary];
    }
}

- (void)initiateCustomDetector:(NSDictionary *) dictionary {
    NSNumber *mode = dictionary[@"mode"];
    BOOL classify = [[dictionary objectForKey:@"classify"] boolValue];
    BOOL multiple = [[dictionary objectForKey:@"multiple"] boolValue];
    NSNumber *threshold = dictionary[@"threshold"];
    NSNumber *maxLabels = dictionary[@"maxLabels"];
    NSString *modelType = dictionary[@"modelType"];
    NSString *modelIdentifier = dictionary[@"modelIdentifier"];
    
    MLKCustomObjectDetectorOptions *options;
    if ([modelType isEqualToString:@"local"]) {
        MLKLocalModel *localModel = [[MLKLocalModel alloc] initWithPath:modelIdentifier];
        options =  [[MLKCustomObjectDetectorOptions alloc] initWithLocalModel:localModel];
    } else {
        MLKFirebaseModelSource *firebaseModelSource = [[MLKFirebaseModelSource alloc]
                                                       initWithName:modelIdentifier];
        MLKCustomRemoteModel *remoteModel = [[MLKCustomRemoteModel alloc]
                                             initWithRemoteModelSource:firebaseModelSource];
        options = [[MLKCustomObjectDetectorOptions alloc] initWithRemoteModel:remoteModel];
    }
    options.detectorMode = mode.intValue == 0 ? MLKObjectDetectorModeStream : MLKObjectDetectorModeSingleImage;
    options.shouldEnableClassification = classify;
    options.shouldEnableMultipleObjects = multiple;
    options.classificationConfidenceThreshold = threshold;
    options.maxPerObjectLabelCount = maxLabels.integerValue;
    
    objectDetector = [MLKObjectDetector objectDetectorWithOptions:options];
}

- (void)initiateBaseDetector:(NSDictionary *) dictionary {
    NSNumber *mode = dictionary[@"mode"];
    BOOL classify = [[dictionary objectForKey:@"classify"] boolValue];
    BOOL multiple = [[dictionary objectForKey:@"multiple"] boolValue];
    
    MLKObjectDetectorOptions *options = [[MLKObjectDetectorOptions alloc] init];
    options.detectorMode = mode.intValue == 0 ? MLKObjectDetectorModeStream : MLKObjectDetectorModeSingleImage;
    options.shouldEnableClassification = classify;
    options.shouldEnableMultipleObjects = multiple;
    
    objectDetector = [MLKObjectDetector objectDetectorWithOptions:options];
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    MLKFirebaseModelSource *firebaseModelSource = [[MLKFirebaseModelSource alloc] initWithName:modelTag];
    MLKCustomRemoteModel *model = [[MLKCustomRemoteModel alloc] initWithRemoteModelSource:firebaseModelSource];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
