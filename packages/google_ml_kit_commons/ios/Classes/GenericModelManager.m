#import "GenericModelManager.h"

@implementation GenericModelManager {
    FlutterResult downloadInkResult;
}

- (void)manageModel:(MLKRemoteModel*)model call:(FlutterMethodCall*)call result:(FlutterResult)result {
    MLKModelManager *modelManager = [MLKModelManager modelManager];
    NSString *task = call.arguments[@"task"];
    if ([task isEqualToString:@"download"]) {
        MLKModelDownloadConditions *downloadConditions = [[MLKModelDownloadConditions alloc]
                                                          initWithAllowsCellularAccess:YES
                                                          allowsBackgroundDownloading:YES];
        [modelManager downloadModel:model conditions:downloadConditions];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTestNotification:)
                                                     name:MLKModelDownloadDidSucceedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTestNotification:)
                                                     name:MLKModelDownloadDidFailNotification
                                                   object:nil];
        downloadInkResult = result;
    } else if ([task isEqualToString:@"delete"]) {
        [modelManager deleteDownloadedModel:model completion:^(NSError * _Nullable error) {
            if (error == NULL) {
                result(@"success");
            } else {
                result(@"error");
            }
        }];
    } else if ([task isEqualToString:@"check"]) {
        BOOL isModelDownloaded = [modelManager isModelDownloaded:model];
        result(@(isModelDownloaded));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) receiveTestNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:MLKModelDownloadDidSucceedNotification]) {
        downloadInkResult(@"success");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else if ([notification.name isEqualToString:MLKModelDownloadDidFailNotification]) {
        downloadInkResult(@"error");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

@end
