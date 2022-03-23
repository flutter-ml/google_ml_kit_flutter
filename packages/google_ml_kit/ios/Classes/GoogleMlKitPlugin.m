#import "GoogleMlKitPlugin.h"

@implementation GoogleMlKitPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"google_ml_kit"
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitPlugin* instance = [[GoogleMlKitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(FlutterMethodNotImplemented);
}

@end
