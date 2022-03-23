#import "GoogleMlKitObjectDetectionPlugin.h"
#import <MLKitObjectDetection/MLKitObjectDetection.h>
#import <MLKitObjectDetectionCommon/MLKitObjectDetectionCommon.h>
#import <google_ml_kit_commons/GoogleMlKitCommonsPlugin.h>

#define startObjectDetector @"vision#startObjectDetector"
#define closeObjectDetector @"vision#closeObjectDetector"

@implementation GoogleMlKitObjectDetectionPlugin {
    MLKObjectDetector *objectDetector;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"google_ml_kit_object_detector"
            binaryMessenger:[registrar messenger]];
  GoogleMlKitObjectDetectionPlugin* instance = [[GoogleMlKitObjectDetectionPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startObjectDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeObjectDetector]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
}

@end
