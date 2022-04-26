#import "GoogleMlKitTranslationPlugin.h"
#import <MLKitTranslate/MLKitTranslate.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_on_device_translator"
#define startLanguageTranslator @"nlp#startLanguageTranslator"
#define closeLanguageTranslator @"nlp#closeLanguageTranslator"
#define manageLanguageModelModels @"nlp#manageLanguageModelModels"

@implementation GoogleMlKitTranslationPlugin {
    MLKTranslator *onDeviceTranslator;
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
    } else if ([call.method isEqualToString:manageLanguageModelModels]) {
        [self manageModel:call result:result];
    } else if ([call.method isEqualToString:closeLanguageTranslator]) {
        onDeviceTranslator = NULL;
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleTranslation:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *text = call.arguments[@"text"];
    
    if (onDeviceTranslator == NULL) {
        NSString *source = call.arguments[@"source"];
        NSString *target = call.arguments[@"target"];
        MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:source
                                                                              targetLanguage:target];
        onDeviceTranslator = [MLKTranslator translatorWithOptions:options];
    }
    
    MLKTranslator *translator = onDeviceTranslator;
    [translator downloadModelIfNeededWithCompletion:^(NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        }
        // Model downloaded successfully. Okay to start translating.
        
        [translator translateText:text
                       completion:^(NSString *_Nullable translatedText,
                                    NSError *_Nullable error) {
            if (error) {
                result(getFlutterError(error));
                return;
            }
            result(translatedText);
        }];
    }];
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *task = call.arguments[@"task"];
    if ([task isEqualToString:@"download"]) {
        result(@"error");
        return;
    }
    
    NSString *modelTag = call.arguments[@"model"];
    MLKTranslateRemoteModel *model = [MLKTranslateRemoteModel translateRemoteModelWithLanguage:modelTag];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
