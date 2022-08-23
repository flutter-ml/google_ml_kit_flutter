#import "GoogleMlKitImageLabelingPlugin.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitImageLabeling/MLKitImageLabeling.h>
#import <MLKitImageLabelingCommon/MLKitImageLabelingCommon.h>
#import <MLKitImageLabelingCustom/MLKitImageLabelingCustom.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#if MLKIT_FIREBASE_MODELS
#import <MLKitLinkFirebase/MLKitLinkFirebase.h>
#endif

#define channelName @"google_mlkit_image_labeler"
#define startImageLabelDetector @"vision#startImageLabelDetector"
#define closeImageLabelDetector @"vision#closeImageLabelDetector"
#define manageFirebaseModels @"vision#manageFirebaseModels"

@implementation GoogleMlKitImageLabelingPlugin {
    NSMutableDictionary *instances;
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitImageLabelingPlugin* instance = [[GoogleMlKitImageLabelingPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startImageLabelDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeImageLabelDetector]) {
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
    MLKImageLabeler *labeler = [instances objectForKey:uid];
    if (labeler == NULL) {
        NSDictionary *dictionary = call.arguments[@"options"];
        NSString *type = dictionary[@"type"];
        if ([@"base" isEqualToString:type]) {
            MLKImageLabelerOptions *options = [self getDefaultOptions:dictionary];
            labeler = [MLKImageLabeler imageLabelerWithOptions:options];
        } else if ([@"local" isEqualToString:type]) {
            MLKCustomImageLabelerOptions *options = [self getLocalOptions:dictionary];
            labeler = [MLKImageLabeler imageLabelerWithOptions:options];
        } else if ([@"remote" isEqualToString:type]) {
#if MLKIT_FIREBASE_MODELS
            MLKCustomImageLabelerOptions *options = [self getRemoteOptions:dictionary];
            if (options == NULL) {
                FlutterError *error = [FlutterError errorWithCode:@"Error Model has not been downloaded yet"
                                                          message:@"Model has not been downloaded yet"
                                                          details:@"Model has not been downloaded yet"];
                result(error);
                return;
            }
            labeler = [MLKImageLabeler imageLabelerWithOptions:options];
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
        instances[uid] = labeler;
    }
    
    [labeler processImage:image
               completion:^(NSArray<MLKImageLabel *> *_Nullable labels,
                            NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!labels) {
            result(@[]);
        }
        
        NSMutableArray *labelData = [NSMutableArray array];
        for (MLKImageLabel *label in labels) {
            NSDictionary *data = @{
                @"confidence" : @(label.confidence),
                @"index" : @(label.index),
                @"text" : label.text,
            };
            [labelData addObject:data];
        }
        
        result(labelData);
    }];
}

- (MLKImageLabelerOptions *)getDefaultOptions:(NSDictionary *)optionsData {
    NSNumber *conf = optionsData[@"confidenceThreshold"];
    MLKImageLabelerOptions *options = [MLKImageLabelerOptions new];
    options.confidenceThreshold = conf;
    return options;
}

- (MLKCustomImageLabelerOptions *)getLocalOptions:(NSDictionary *)optionsData {
    NSNumber *conf = optionsData[@"confidenceThreshold"];
    NSNumber *maxCount = optionsData[@"maxCount"];
    NSString *path = optionsData[@"path"];
    
    MLKLocalModel *localModel = [[MLKLocalModel alloc] initWithPath:path];
    MLKCustomImageLabelerOptions *options = [[MLKCustomImageLabelerOptions alloc] initWithLocalModel:localModel];
    options.confidenceThreshold = conf;
    options.maxResultCount = maxCount.intValue;
    return options;
}

#if MLKIT_FIREBASE_MODELS
- (MLKCustomImageLabelerOptions *)getRemoteOptions:(NSDictionary *)optionsData {
    NSNumber *conf = optionsData[@"confidenceThreshold"];
    NSNumber *maxCount = optionsData[@"maxCount"];
    NSString *modelName = optionsData[@"modelName"];
    
    MLKFirebaseModelSource *firebaseModelSource = [[MLKFirebaseModelSource alloc] initWithName:modelName];
    MLKCustomRemoteModel *remoteModel = [[MLKCustomRemoteModel alloc] initWithRemoteModelSource:firebaseModelSource];
    
    MLKModelManager *modelManager = [MLKModelManager modelManager];
    BOOL isModelDownloaded = [modelManager isModelDownloaded:remoteModel];
    if (!isModelDownloaded) {
        return NULL;
    }
    
    MLKCustomImageLabelerOptions *options = [[MLKCustomImageLabelerOptions alloc] initWithRemoteModel:remoteModel];
    options.confidenceThreshold = conf;
    options.maxResultCount = maxCount.intValue;
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
