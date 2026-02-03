#import <Foundation/Foundation.h>
#import "GoogleMlKitGenaiSummarizationPlugin.h"

#define channelName @"google_mlkit_genai_summarization"
#define checkFeatureStatus @"genai#checkFeatureStatus"
#define downloadFeature @"genai#downloadFeature"
#define runInference @"genai#runInference"
#define runInferenceStreaming @"genai#runInferenceStreaming"
#define closeSummarizer @"genai#closeSummarizer"

@implementation GoogleMlKitGenaiSummarizationPlugin {
    NSMutableDictionary *instances;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitGenaiSummarizationPlugin* instance = [[GoogleMlKitGenaiSummarizationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:checkFeatureStatus]) {
        // iOS implementation would go here
        // Note: GenAI APIs are currently Android-only
        result([FlutterError errorWithCode:@"UNIMPLEMENTED"
                                   message:@"GenAI APIs are currently only available on Android"
                                   details:nil]);
    } else if ([call.method isEqualToString:downloadFeature]) {
        result([FlutterError errorWithCode:@"UNIMPLEMENTED"
                                   message:@"GenAI APIs are currently only available on Android"
                                   details:nil]);
    } else if ([call.method isEqualToString:runInference]) {
        result([FlutterError errorWithCode:@"UNIMPLEMENTED"
                                   message:@"GenAI APIs are currently only available on Android"
                                   details:nil]);
    } else if ([call.method isEqualToString:runInferenceStreaming]) {
        result([FlutterError errorWithCode:@"UNIMPLEMENTED"
                                   message:@"GenAI APIs are currently only available on Android"
                                   details:nil]);
    } else if ([call.method isEqualToString:closeSummarizer]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
