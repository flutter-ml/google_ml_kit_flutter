#import "GoogleMlKitPlugin.h"

@implementation GoogleMlKitPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"google_ml_kit"
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitPlugin* instance = [[GoogleMlKitPlugin alloc] init];
    
    // Add vision detectors
    NSMutableArray *handlers = [NSMutableArray new];
    [handlers addObject:[[BarcodeScanner alloc] init]];
    [handlers addObject:[[CustomRemoteModelManager alloc] init]];
    [handlers addObject:[[DigitalInkRecogniser alloc] init]];
    [handlers addObject:[[FaceDetector alloc] init]];
    [handlers addObject:[[ImageLabeler alloc] init]];
    [handlers addObject:[[PoseDetector alloc] init]];
    [handlers addObject:[[TextRecognizer alloc] init]];
    
    // Add nlp detectors
    [handlers addObject:[[LanguageIdentifier alloc] init]];
    
    instance.handlers = [NSMutableDictionary new];
    for (id<Handler> detector in handlers) {
        for (NSString *key in detector.getMethodsKeys) {
            instance.handlers[key] = detector;
        }
    }
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    id<Handler> handler = self.handlers[call.method];
    if (handler != NULL) {
        [handler handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
