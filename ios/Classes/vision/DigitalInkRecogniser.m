#import "GoogleMlKitPlugin.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitDigitalInkRecognition/MLKitDigitalInkRecognition.h>

#define startDigitalInkRecognizer @"vision#startDigitalInkRecognizer"
#define closeDigitalInkRecognizer @"vision#closeDigitalInkRecognizer"
#define manageInkModels @"vision#manageInkModels"

@implementation DigitalInkRecogniser {
    MLKDigitalInkRecognizer *recognizer;
    FlutterResult downloadInkResult;
}

- (NSArray *)getMethodsKeys {
    return @[startDigitalInkRecognizer,
             closeDigitalInkRecognizer,
             manageInkModels];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startDigitalInkRecognizer]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:manageInkModels]) {
        [self manageInkModel:call result:result];
    } else if ([call.method isEqualToString:closeDigitalInkRecognizer]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *pointsList = call.arguments[@"points"];
    NSString *modelTag = call.arguments[@"modelTag"];
    
    MLKDigitalInkRecognitionModelIdentifier *identifier =
    [MLKDigitalInkRecognitionModelIdentifier modelIdentifierForLanguageTag:modelTag];
    MLKDigitalInkRecognitionModel *model = [[MLKDigitalInkRecognitionModel alloc]
                                            initWithModelIdentifier:identifier];
    
    MLKModelManager *modelManager = [MLKModelManager modelManager];
    
    BOOL isModelDownloaded = [modelManager isModelDownloaded:model];
    
    if (!isModelDownloaded) {
        FlutterError *error = [FlutterError errorWithCode:@"Error Model has not been downloaded yet"
                                                  message:@"Model has not been downloaded yet"
                                                  details:@"Model has not been downloaded yet"];
        result(error);
        return;
    }
    
    MLKDigitalInkRecognizerOptions *options = [[MLKDigitalInkRecognizerOptions alloc] initWithModel:model];
    recognizer = [MLKDigitalInkRecognizer digitalInkRecognizerWithOptions:options];
    
    NSMutableArray *points = [NSMutableArray array];
    for (NSDictionary *pointMap in pointsList) {
        NSNumber *x = pointMap[@"x"];
        NSNumber *y = pointMap[@"y"];
        MLKStrokePoint *strokePoint = [[MLKStrokePoint alloc] initWithX:x.floatValue y:y.floatValue];
        [points addObject:strokePoint];
    }
    
    NSMutableArray *strokes = [NSMutableArray array];
    [strokes addObject:[[MLKStroke alloc] initWithPoints:points]];
    
    MLKInk *ink = [[MLKInk alloc] initWithStrokes:strokes];
    
    [recognizer recognizeInk:ink
                  completion:^(MLKDigitalInkRecognitionResult * _Nullable recognitionResult, NSError * _Nullable error) {
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
    }];
}

- (void)manageInkModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *task = call.arguments[@"task"];
    NSString *modelTag = call.arguments[@"modelTag"];
    
    MLKDigitalInkRecognitionModelIdentifier *identifier = [MLKDigitalInkRecognitionModelIdentifier modelIdentifierForLanguageTag:modelTag];
    MLKDigitalInkRecognitionModel *model = [[MLKDigitalInkRecognitionModel alloc] initWithModelIdentifier:identifier];
    
    MLKModelManager *modelManager = [MLKModelManager modelManager];
    
    if ([task isEqualToString:@"download"]) {
        MLKModelDownloadConditions *downloadConditions = [[MLKModelDownloadConditions alloc]
                                                          initWithAllowsCellularAccess:YES
                                                          allowsBackgroundDownloading:YES];
        [modelManager downloadModel:model conditions:downloadConditions];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTestNotification:)
                                                     name:MLKModelDownloadDidSucceedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTestNotification:)
                                                     name:MLKModelDownloadDidFailNotification
                                                   object:nil];
        downloadInkResult = result;
    } else if ([task isEqualToString:@"delete"]) {
        [modelManager deleteDownloadedModel:model completion:^(NSError * _Nullable error) {
            if (error == NULL) {
                result(@"success");
            } else {
                result(@"error");
            }
        }];
    } else if ([task isEqualToString:@"check"]) {
        BOOL isModelDownloaded = [modelManager isModelDownloaded:model];
        result(@(isModelDownloaded));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) receiveTestNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:MLKModelDownloadDidSucceedNotification]) {
        downloadInkResult(@"success");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else if ([notification.name isEqualToString:MLKModelDownloadDidFailNotification]) {
        downloadInkResult(@"error");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

@end
