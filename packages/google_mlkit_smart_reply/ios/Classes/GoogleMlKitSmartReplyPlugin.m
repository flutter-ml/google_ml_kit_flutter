#import "GoogleMlKitSmartReplyPlugin.h"
#import <MLKitSmartReply/MLKitSmartReply.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_smart_reply"
#define startSmartReply @"nlp#startSmartReply"
#define addSmartReply @"nlp#addSmartReply"
#define closeSmartReply @"nlp#closeSmartReply"

@implementation GoogleMlKitSmartReplyPlugin {
    MLKSmartReply *smartReply;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitSmartReplyPlugin* instance = [[GoogleMlKitSmartReplyPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startSmartReply]) {
        [self handleStartSmartReply:call result:result];
    } if ([call.method isEqualToString:addSmartReply]) {
        [self handleAddSmartReply:call result:result];
    } else if ([call.method isEqualToString:closeSmartReply]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleStartSmartReply:(FlutterMethodCall *)call result:(FlutterResult)result {
}

- (void)handleAddSmartReply:(FlutterMethodCall *)call result:(FlutterResult)result {
}

@end
