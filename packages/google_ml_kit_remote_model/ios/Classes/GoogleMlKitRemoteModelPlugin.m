#import "GoogleMlKitRemoteModelPlugin.h"
#import <MLKitLinkFirebase/MLKitLinkFirebase.h>
#import <google_ml_kit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_ml_kit_remote_model_manager"
#define manageRemoteModel @"vision#manageRemoteModel"

@implementation GoogleMlKitRemoteModelPlugin {
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitRemoteModelPlugin* instance = [[GoogleMlKitRemoteModelPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:manageRemoteModel]) {
        [self manageModel:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)manageModel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelTag = call.arguments[@"model"];
    MLKFirebaseModelSource *firebaseModelSource = [[MLKFirebaseModelSource alloc] initWithName:modelTag];
    MLKCustomRemoteModel *model = [[MLKCustomRemoteModel alloc] initWithRemoteModelSource:firebaseModelSource];
    genericModelManager = [[GenericModelManager alloc] init];
    [genericModelManager manageModel:model call:call result:result];
}

@end
