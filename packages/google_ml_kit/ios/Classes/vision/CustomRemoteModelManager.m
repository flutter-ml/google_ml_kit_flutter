#import "GoogleMlKitPlugin.h"
#import "GenericModelManager.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitLinkFirebase/MLKitLinkFirebase.h>

#define manageRemoteModel @"vision#manageRemoteModel"

@implementation CustomRemoteModelManager {
    GenericModelManager *genericModelManager;
}

- (NSArray *)getMethodsKeys {
    return @[manageRemoteModel];
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
