#import "GoogleMlKitCommonsPlugin.h"

@implementation GoogleMlKitCommonsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"google_ml_kit_commons"
            binaryMessenger:[registrar messenger]];
  GoogleMlKitCommonsPlugin* instance = [[GoogleMlKitCommonsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end
