#import "OnDeviceTranslatorApiImpl.h"
#import <MLKitTranslate/MLKitTranslate.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

@interface OnDeviceTranslatorApiImpl()
@property(nonatomic, strong) NSMutableDictionary<NSString *, MLKitTranslor *> *instances;
@property(nonatomic, strong) GenericModelManager *genericModelManager;
@end

@implementation OnDeviceTranslatorApiImpl

- (instancetype)init {
    self = [super init];
    if (self) {
        _instances = [NSMutableDictionary dictionary];
        _genericModelManager = [[GenericModelManager alloc] init];
    }
    return self;
}

- (void)translateTextRequest:(TranslateRequest *)request
                  completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
    NSString *uid = request.id;
    MLKTranslator *translator = self.instances[uid];
    
    if (translator == nil) {
        // Initialize new translator
        MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] 
            initWithSourceLanguage:request.sourceLanguage
            targetLanguage:request.targetLanguage];
        translator = [MLKTranslator translatorWithOptions:options];
        self.instances[uid] = translator;
    }
    
    NSString *text = request.text;

        [translator downloadModelIfNeededWithCompletion:^(NSError *_Nullable error) {
        if (error) {
            FlutterError *flutterError = [FlutterError errorWithCode:@"MODEL_DOWNLOAD_ERROR"
                                                             message:error.localizedDescription
                                                             details:nil];
            completion(nil, flutterError);
            return;
        }
        
        // Model downloaded successfully. Okay to start translating.
        [translator translateText:text
                       completion:^(NSString *_Nullable translatedText,
                                    NSError *_Nullable error) {
            if (error) {
                FlutterError *flutterError = [FlutterError errorWithCode:@"TRANSLATION_ERROR"
                                                                 message:error.localizedDescription
                                                                 details:nil];
                completion(nil, flutterError);
                return;
            }
            completion(translatedText, nil);
        }];
    }];
}

- (void)closeTranslatorRequest:(CloseTranslatorRequest *)request
                          error:(FlutterError *_Nullable *_Nonnull)error {
    NSString *uid = request.id;
    [self.instances removeObjectForKey:uid];
}

- (void)manageModelRequest:(ModelManagementRequest *)request
                completion:(void (^)(ModelManagementResponse *_Nullable, FlutterError *_Nullable))completion {
    NSString *modelTag = request.model;
    NSString *task = request.task;
    
    MLKTranslateRemoteModel *model = [MLKTranslateRemoteModel translateRemoteModelWithLanguage:modelTag];
    
    // 
    // 
  
}

@end