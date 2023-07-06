#import "GoogleMlKitFaceMeshDetectionPlugin.h"
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_face_mesh_detector"
#define startFaceMeshDetector @"vision#startFaceMeshDetector"
#define closeFaceMeshDetector @"vision#closeFaceMeshDetector"

@implementation GoogleMlKitFaceMeshDetectionPlugin {
    NSMutableDictionary *instances;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitFaceMeshDetectionPlugin* instance = [[GoogleMlKitFaceMeshDetectionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startFaceMeshDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeFaceMeshDetector]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    // TODO: waiting for Google to release Face Mesh api for iOS
    // https://developers.google.com/ml-kit/vision/face-mesh-detection
    result(FlutterMethodNotImplemented);
}

@end
