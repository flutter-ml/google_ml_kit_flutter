#import "GoogleMlKitCommonsPlugin.h"
#import <MLKitLinkFirebase/MLKitLinkFirebase.h>

#define channelName @"google_mlkit_commons"
#define manageRemoteModel @"vision#manageRemoteModel"

@implementation GoogleMlKitCommonsPlugin {
    GenericModelManager *genericModelManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitCommonsPlugin* instance = [[GoogleMlKitCommonsPlugin alloc] init];
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
