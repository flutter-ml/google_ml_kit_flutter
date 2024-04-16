#import "GoogleMlKitDocumentScannerPlugin.h"

@implementation GoogleMlKitDocumentScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"google_mlkit_document_scanner"
            binaryMessenger:[registrar messenger]];
  GoogleMlKitDocumentScannerPlugin* instance = [[GoogleMlKitDocumentScannerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
