#import "GoogleMlKitDigitalInkRecognitionPlugin.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitDigitalInkRecognition/MLKitDigitalInkRecognition.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_digital_ink_recognizer"
#define startDigitalInkRecognizer @"vision#startDigitalInkRecognizer"
#define closeDigitalInkRecognizer @"vision#closeDigitalInkRecognizer"
#define manageInkModels @"vision#manageInkModels"

@implementation GoogleMlKitDigitalInkRecognitionPlugin {
    NSMutableDictionary *instances;
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitDigitalInkRecognitionPlugin* instance = [[GoogleMlKitDigitalInkRecognitionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startDigitalInkRecognizer]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:manageInkModels]) {
        [self manageModel:call result:result];
    } else if ([call.method isEqualToString:closeDigitalInkRecognizer]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    
    MLKDigitalInkRecognitionModelIdentifier *identifier = [MLKDigitalInkRecognitionModelIdentifier modelIdentifierForLanguageTag:modelTag];
    MLKDigitalInkRecognitionModel *model = [[MLKDigitalInkRecognitionModel alloc] initWithModelIdentifier:identifier];
    MLKModelManager *modelManager = [MLKModelManager modelManager];
    
    BOOL isModelDownloaded = [modelManager isModelDownloaded:model];
    
    if (!isModelDownloaded) {
        FlutterError *error = [FlutterError errorWithCode:@"Error Model has not been downloaded yet"
                                                  message:@"Model has not been downloaded yet"
                                                  details:@"Model has not been downloaded yet"];
        result(error);
        return;
    }
    
    NSString *uid = call.arguments[@"id"];
    MLKDigitalInkRecognizer *recognizer = [instances objectForKey:uid];
    if (recognizer == NULL) {
        MLKDigitalInkRecognizerOptions *options = [[MLKDigitalInkRecognizerOptions alloc] initWithModel:model];
        recognizer = [MLKDigitalInkRecognizer digitalInkRecognizerWithOptions:options];
        instances[uid] = recognizer;
    }
    
    NSMutableArray *strokes = [NSMutableArray array];
    NSArray *strokeList = call.arguments[@"ink"][@"strokes"];
    for (NSDictionary *strokeMap in strokeList) {
        NSMutableArray *stroke = [NSMutableArray array];
        NSArray *pointsList = strokeMap[@"points"];
        for (NSDictionary *pointMap in pointsList) {
            NSNumber *x = pointMap[@"x"];
            NSNumber *y = pointMap[@"y"];
            NSNumber *t = pointMap[@"t"];
            MLKStrokePoint *strokePoint = [[MLKStrokePoint alloc] initWithX:x.floatValue y:y.floatValue t:t.longValue];
            [stroke addObject:strokePoint];
        }
        [strokes addObject:[[MLKStroke alloc] initWithPoints:stroke]];
    }
    MLKInk *ink = [[MLKInk alloc] initWithStrokes:strokes];
    
    MLKDigitalInkRecognitionContext *context;
    NSDictionary *contextMap = call.arguments[@"context"];
    if ([contextMap isKindOfClass: [NSDictionary class]]) {
        NSString *preContext = contextMap[@"preContext"];
        if ([preContext isKindOfClass: [NSNull class]]) {
            preContext = @"";
        }
        MLKWritingArea *writingArea;
        NSDictionary *writingAreaMap = contextMap[@"writingArea"];
        if ([writingAreaMap isKindOfClass: [NSDictionary class]]) {
            NSNumber *width = writingAreaMap[@"width"];
            NSNumber *height = writingAreaMap[@"height"];
            writingArea = [[MLKWritingArea alloc] initWithWidth:width.floatValue height:height.floatValue];
        }
        context = [[MLKDigitalInkRecognitionContext alloc] initWithPreContext:preContext writingArea:writingArea];
    }
    
    if (context != NULL) {
        [recognizer recognizeInk:ink
                         context:context
                      completion:^(MLKDigitalInkRecognitionResult * _Nullable recognitionResult,
                                   NSError * _Nullable error) {
            [self process:recognitionResult error:error result:result];
        }];
    } else {
        [recognizer recognizeInk:ink
                      completion:^(MLKDigitalInkRecognitionResult * _Nullable recognitionResult,
                                   NSError * _Nullable error) {
            [self process:recognitionResult error:error result:result];
        }];
    }
}

- (void )process:(MLKDigitalInkRecognitionResult *)recognitionResult
           error:(NSError *)error
          result:(FlutterResult)result {
    if (error) {
        result(getFlutterError(error));
        return;
    } else if (!recognitionResult) {
        result(NULL);
        return;
    }
    NSMutableArray *candidates = [NSMutableArray new];
    for(MLKDigitalInkRecognitionCandidate *candidate in recognitionResult.candidates) {
        NSDictionary *dictionary = @{@"text": candidate.text,
                                     @"score": @(candidate.score.doubleValue)};
        [candidates addObject:dictionary];
    }
    result(candidates);
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    MLKDigitalInkRecognitionModelIdentifier *identifier = [MLKDigitalInkRecognitionModelIdentifier modelIdentifierForLanguageTag:modelTag];
    MLKDigitalInkRecognitionModel *model = [[MLKDigitalInkRecognitionModel alloc] initWithModelIdentifier:identifier];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
