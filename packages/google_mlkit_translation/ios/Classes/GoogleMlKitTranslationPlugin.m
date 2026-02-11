#import "GoogleMlKitTranslationPlugin.h"
#import <MLKitTranslate/MLKitTranslate.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_on_device_translator"
#define startLanguageTranslator @"nlp#startLanguageTranslator"
#define closeLanguageTranslator @"nlp#closeLanguageTranslator"
#define manageLanguageModelModels @"nlp#manageLanguageModelModels"

@implementation GoogleMlKitTranslationPlugin {
    NSMutableDictionary *instances;
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitTranslationPlugin* instance = [[GoogleMlKitTranslationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startLanguageTranslator]) {
        [self handleTranslation:call result:result];
    } else if ([call.method isEqualToString:manageLanguageModelModels]) {
        [self manageModel:call result:result];
    } else if ([call.method isEqualToString:closeLanguageTranslator]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (MLKTranslator*)initialize:(FlutterMethodCall *)call {
    NSString *source = call.arguments[@"source"];
    NSString *target = call.arguments[@"target"];
    MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:source
                                                                          targetLanguage:target];
    return [MLKTranslator translatorWithOptions:options];
}

- (void)handleTranslation:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *text = call.arguments[@"text"];
    
    NSString *uid = call.arguments[@"id"];
    MLKTranslator *translator = [instances objectForKey:uid];
    if (translator == NULL) {
        translator = [self initialize:call];
        instances[uid] = translator;
    }
    
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
    NSString *modelTag = call.arguments[@"model"];
    MLKTranslateRemoteModel *model = [MLKTranslateRemoteModel translateRemoteModelWithLanguage:modelTag];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
