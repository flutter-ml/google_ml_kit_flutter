#import "GoogleMlKitTranslationPlugin.h"
#import <MLKitTranslate/MLKitTranslate.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_on_device_translator"
#define startLanguageTranslator @"nlp#startLanguageTranslator"
#define closeLanguageTranslator @"nlp#closeLanguageTranslator"
#define manageLanguageModelModels @"nlp#manageLanguageModelModels"

@implementation GoogleMlKitTranslationPlugin {
    MLKTranslator *translator;
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitTranslationPlugin* instance = [[GoogleMlKitTranslationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startLanguageTranslator]) {
        [self handleTranslation:call result:result];
    } if ([call.method isEqualToString:manageLanguageModelModels]) {
        [self manageModel:call result:result];
    } else if ([call.method isEqualToString:closeLanguageTranslator]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleTranslation:(FlutterMethodCall *)call result:(FlutterResult)result {
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    MLKTranslateRemoteModel *model = [MLKTranslateRemoteModel translateRemoteModelWithLanguage:modelTag];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
