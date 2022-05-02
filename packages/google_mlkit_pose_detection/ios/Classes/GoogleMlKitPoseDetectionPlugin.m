#import "GoogleMlKitPoseDetectionPlugin.h"
#import <MLKitPoseDetection/MLKitPoseDetection.h>
#import <MLKitPoseDetectionCommon/MLKitPoseDetectionCommon.h>
#import <MLKitPoseDetectionAccurate/MLKitPoseDetectionAccurate.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_pose_detector"
#define startPoseDetector @"vision#startPoseDetector"
#define closePoseDetector @"vision#closePoseDetector"

@implementation GoogleMlKitPoseDetectionPlugin {
    NSMutableDictionary *instances;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitPoseDetectionPlugin* instance = [[GoogleMlKitPoseDetectionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startPoseDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closePoseDetector]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (MLKPoseDetector*)initialize:(FlutterMethodCall *)call {
    NSDictionary *options = call.arguments[@"options"];
    NSString *mode = options[@"mode"];
    MLKPoseDetectorMode detectorMode = MLKPoseDetectorModeStream;
    if ([mode isEqualToString:@"single"]) {
        detectorMode = MLKPoseDetectorModeSingleImage;
    }
    
    NSString *model = options[@"model"];
    if ([model isEqualToString:@"base"]) {
        MLKPoseDetectorOptions *options = [[MLKPoseDetectorOptions alloc] init];
        options.detectorMode = detectorMode;
        return [MLKPoseDetector poseDetectorWithOptions:options];
    } else {
        MLKAccuratePoseDetectorOptions *options =
        [[MLKAccuratePoseDetectorOptions alloc] init];
        options.detectorMode = detectorMode;
        return [MLKPoseDetector poseDetectorWithOptions:options];
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    
    NSString *uid = call.arguments[@"id"];
    MLKPoseDetector *detector = [instances objectForKey:uid];
    if (detector == NULL) {
        detector = [self initialize:call];
        instances[uid] = detector;
    }
    
    [detector processImage:image
                completion:^(NSArray * _Nullable poses,
                             NSError * _Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!poses || poses.count == 0) {
            result(@[]);
            return;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        for (MLKPose *pose in poses) {
            NSMutableArray *landmarks = [NSMutableArray array];
            for (MLKPoseLandmark *landmark in pose.landmarks) {
                NSMutableDictionary *dictionary = [NSMutableDictionary new];
                dictionary[@"type"] = [self poseLandmarkTypeToNumber:landmark.type];
                dictionary[@"x"] = @(landmark.position.x);
                dictionary[@"y"] = @(landmark.position.y);
                dictionary[@"z"] = @(landmark.position.z);
                dictionary[@"likelihood"] = @(landmark.inFrameLikelihood);
                [landmarks addObject:dictionary];
            }
            [array addObject:landmarks];
        }
        result(array);
    }];
}

- (NSNumber*)poseLandmarkTypeToNumber:(MLKPoseLandmarkType)landmarkType {
    NSMutableDictionary *types = [NSMutableDictionary new];
    types[MLKPoseLandmarkTypeNose] = @0;
    types[MLKPoseLandmarkTypeLeftEyeInner] = @1;
    types[MLKPoseLandmarkTypeLeftEye] = @2;
    types[MLKPoseLandmarkTypeLeftEyeOuter] = @3;
    types[MLKPoseLandmarkTypeRightEyeInner] = @4;
    types[MLKPoseLandmarkTypeRightEye] = @5;
    types[MLKPoseLandmarkTypeRightEyeOuter] = @6;
    types[MLKPoseLandmarkTypeLeftEar] = @7;
    types[MLKPoseLandmarkTypeRightEar] = @8;
    types[MLKPoseLandmarkTypeMouthLeft] = @9;
    types[MLKPoseLandmarkTypeMouthRight] = @10;
    types[MLKPoseLandmarkTypeLeftShoulder] = @11;
    types[MLKPoseLandmarkTypeRightShoulder] = @12;
    types[MLKPoseLandmarkTypeLeftElbow] = @13;
    types[MLKPoseLandmarkTypeRightElbow] = @14;
    types[MLKPoseLandmarkTypeLeftWrist] = @15;
    types[MLKPoseLandmarkTypeRightWrist] = @16;
    types[MLKPoseLandmarkTypeLeftPinkyFinger] = @17;
    types[MLKPoseLandmarkTypeRightPinkyFinger] = @18;
    types[MLKPoseLandmarkTypeLeftIndexFinger] = @19;
    types[MLKPoseLandmarkTypeRightIndexFinger] = @20;
    types[MLKPoseLandmarkTypeLeftThumb] = @21;
    types[MLKPoseLandmarkTypeRightThumb] = @22;
    types[MLKPoseLandmarkTypeLeftHip] = @23;
    types[MLKPoseLandmarkTypeRightHip] = @24;
    types[MLKPoseLandmarkTypeLeftKnee] = @25;
    types[MLKPoseLandmarkTypeRightKnee] = @26;
    types[MLKPoseLandmarkTypeLeftAnkle] = @27;
    types[MLKPoseLandmarkTypeRightAnkle] = @28;
    types[MLKPoseLandmarkTypeLeftHeel] = @29;
    types[MLKPoseLandmarkTypeRightHeel] = @30;
    types[MLKPoseLandmarkTypeLeftToe] = @31;
    types[MLKPoseLandmarkTypeRightToe] = @32;
    return types[landmarkType];
}

@end
