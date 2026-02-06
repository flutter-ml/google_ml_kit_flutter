#import <Foundation/Foundation.h>
#import "GoogleMlKitGenaiSpeechRecognitionPlugin.h"

#define channelName @"google_mlkit_genai_speech_recognition"
#define checkStatus @"genai#checkStatus"
#define startRecognition @"genai#startRecognition"
#define stopRecognition @"genai#stopRecognition"
#define closeSpeechRecognizer @"genai#closeSpeechRecognizer"

@implementation GoogleMlKitGenaiSpeechRecognitionPlugin {
    NSMutableDictionary *instances;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitGenaiSpeechRecognitionPlugin* instance = [[GoogleMlKitGenaiSpeechRecognitionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:checkStatus]) {
        // iOS implementation would go here
        // Note: GenAI APIs are currently Android-only
        result([FlutterError errorWithCode:@"UNIMPLEMENTED"
                                   message:@"GenAI APIs are currently only available on Android"
                                   details:nil]);
    } else if ([call.method isEqualToString:startRecognition]) {
        result([FlutterError errorWithCode:@"UNIMPLEMENTED"
                                   message:@"GenAI APIs are currently only available on Android"
                                   details:nil]);
    } else if ([call.method isEqualToString:stopRecognition]) {
        result([FlutterError errorWithCode:@"UNIMPLEMENTED"
                                   message:@"GenAI APIs are currently only available on Android"
                                   details:nil]);
    } else if ([call.method isEqualToString:closeSpeechRecognizer]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
