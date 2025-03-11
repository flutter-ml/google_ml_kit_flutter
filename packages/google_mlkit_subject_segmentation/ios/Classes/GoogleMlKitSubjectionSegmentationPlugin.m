#import "GoogleMlKitSubjectSegmentationPlugin.h"

@implementation GoogleMlKitSubjectSegmentationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"google_mlkit_subject_segmentation"
            binaryMessenger:[registrar messenger]];
  GoogleMlKitSubjectSegmentationPlugin* instance = [[GoogleMlKitSubjectSegmentationPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(FlutterMethodNotImplemented);
}

@end
