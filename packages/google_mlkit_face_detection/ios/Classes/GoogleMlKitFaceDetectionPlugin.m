#import "GoogleMlKitFaceDetectionPlugin.h"
#import <MLKitFaceDetection/MLKitFaceDetection.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_face_detector"
#define startFaceDetector @"vision#startFaceDetector"
#define closeFaceDetector @"vision#closeFaceDetector"

@implementation GoogleMlKitFaceDetectionPlugin {
    NSMutableDictionary *instances;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitFaceDetectionPlugin* instance = [[GoogleMlKitFaceDetectionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startFaceDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeFaceDetector]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (MLKFaceDetector*)initialize:(FlutterMethodCall *)call {
    NSDictionary *dictionary = call.arguments[@"options"];
    
    MLKFaceDetectorOptions *options = [[MLKFaceDetectorOptions alloc] init];
    BOOL enableClassification = [[dictionary objectForKey:@"enableClassification"] boolValue];
    options.classificationMode = enableClassification ? MLKFaceDetectorClassificationModeAll : MLKFaceDetectorClassificationModeNone;
    
    BOOL enableLandmarks = [[dictionary objectForKey:@"enableLandmarks"] boolValue];
    options.landmarkMode = enableLandmarks ? MLKFaceDetectorLandmarkModeAll : MLKFaceDetectorLandmarkModeNone;
    
    BOOL enableContours = [[dictionary objectForKey:@"enableContours"] boolValue];
    options.contourMode = enableContours ? MLKFaceDetectorContourModeAll : MLKFaceDetectorContourModeNone;
    
    BOOL enableTracking = [[dictionary objectForKey:@"enableTracking"] boolValue];
    options.trackingEnabled = enableTracking;
    
    NSNumber *minFaceSize = dictionary[@"minFaceSize"];
    options.minFaceSize = minFaceSize.floatValue;
    
    NSString *mode = dictionary[@"mode"];
    options.performanceMode = [mode isEqualToString:@"accurate"] ? MLKFaceDetectorPerformanceModeAccurate : MLKFaceDetectorPerformanceModeFast;
    
    return [MLKFaceDetector faceDetectorWithOptions:options];
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    
    NSString *uid = call.arguments[@"id"];
    MLKFaceDetector *detector = [instances objectForKey:uid];
    if (detector == NULL) {
        detector = [self initialize:call];
        instances[uid] = detector;
    }
    
    [detector processImage:image
                completion:^(NSArray<MLKFace *> *_Nullable faces,
                             NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!faces) {
            result(@[]);
            return;
        }
        
        NSMutableArray *faceData = [NSMutableArray array];
        for (MLKFace *face in faces) {
            id smileProb = face.hasSmilingProbability ? @(face.smilingProbability) : [NSNull null];
            id leftProb =
            face.hasLeftEyeOpenProbability ? @(face.leftEyeOpenProbability) : [NSNull null];
            id rightProb =
            face.hasRightEyeOpenProbability ? @(face.rightEyeOpenProbability) : [NSNull null];
            
            NSDictionary *data = @{
                @"rect" : @{
                    @"left" : @(face.frame.origin.x),
                    @"top" : @(face.frame.origin.y),
                    @"right" : @(face.frame.origin.x + face.frame.size.width),
                    @"bottom" : @(face.frame.origin.y + face.frame.size.height)
                },
                @"headEulerAngleX" : face.hasHeadEulerAngleX ? @(face.headEulerAngleX)
                : [NSNull null],
                @"headEulerAngleY" : face.hasHeadEulerAngleY ? @(face.headEulerAngleY)
                : [NSNull null],
                @"headEulerAngleZ" : face.hasHeadEulerAngleZ ? @(face.headEulerAngleZ)
                : [NSNull null],
                @"smilingProbability" : smileProb,
                @"leftEyeOpenProbability" : leftProb,
                @"rightEyeOpenProbability" : rightProb,
                @"trackingId" : face.hasTrackingID ? @(face.trackingID) : [NSNull null],
                @"landmarks" : @{
                    @"bottomMouth" : [self getLandmarkPosition:face
                                                      landmark:MLKFaceLandmarkTypeMouthBottom],
                    @"rightMouth" : [self getLandmarkPosition:face
                                                     landmark:MLKFaceLandmarkTypeMouthRight],
                    @"leftMouth" : [self getLandmarkPosition:face
                                                    landmark:MLKFaceLandmarkTypeMouthLeft],
                    @"rightEye" : [self getLandmarkPosition:face
                                                   landmark:MLKFaceLandmarkTypeRightEye],
                    @"leftEye" : [self getLandmarkPosition:face
                                                  landmark:MLKFaceLandmarkTypeLeftEye],
                    @"rightEar" : [self getLandmarkPosition:face
                                                   landmark:MLKFaceLandmarkTypeRightEar],
                    @"leftEar" : [self getLandmarkPosition:face
                                                  landmark:MLKFaceLandmarkTypeLeftEar],
                    @"rightCheek" : [self getLandmarkPosition:face
                                                     landmark:MLKFaceLandmarkTypeRightCheek],
                    @"leftCheek" : [self getLandmarkPosition:face
                                                    landmark:MLKFaceLandmarkTypeLeftCheek],
                    @"noseBase" : [self getLandmarkPosition:face
                                                   landmark:MLKFaceLandmarkTypeNoseBase],
                },
                @"contours" : @{
                    @"face" : [self getContourPoints:face contour:MLKFaceContourTypeFace],
                    @"leftEyebrowTop" :
                        [self getContourPoints:face contour:MLKFaceContourTypeLeftEyebrowTop],
                    @"leftEyebrowBottom" :
                        [self getContourPoints:face
                                       contour:MLKFaceContourTypeLeftEyebrowBottom],
                    @"rightEyebrowTop" :
                        [self getContourPoints:face contour:MLKFaceContourTypeRightEyebrowTop],
                    @"rightEyebrowBottom" :
                        [self getContourPoints:face
                                       contour:MLKFaceContourTypeRightEyebrowBottom],
                    @"leftEye" : [self getContourPoints:face contour:MLKFaceContourTypeLeftEye],
                    @"rightEye" : [self getContourPoints:face
                                                 contour:MLKFaceContourTypeRightEye],
                    @"upperLipTop" : [self getContourPoints:face
                                                    contour:MLKFaceContourTypeUpperLipTop],
                    @"upperLipBottom" :
                        [self getContourPoints:face contour:MLKFaceContourTypeUpperLipBottom],
                    @"lowerLipTop" : [self getContourPoints:face
                                                    contour:MLKFaceContourTypeLowerLipTop],
                    @"lowerLipBottom" :
                        [self getContourPoints:face contour:MLKFaceContourTypeLowerLipBottom],
                    @"noseBridge" : [self getContourPoints:face
                                                   contour:MLKFaceContourTypeNoseBridge],
                    @"noseBottom" : [self getContourPoints:face
                                                   contour:MLKFaceContourTypeNoseBottom],
                    @"leftCheek" : [self getContourPoints:face
                                                  contour:MLKFaceContourTypeLeftCheek],
                    @"rightCheek" : [self getContourPoints:face
                                                   contour:MLKFaceContourTypeRightCheek],
                }
            };
            [faceData addObject:data];
        }
        
        result(faceData);
    }];
}

- (id)getLandmarkPosition:(MLKFace *)face landmark:(MLKFaceLandmarkType)landmarkType {
    MLKFaceLandmark *landmark = [face landmarkOfType:landmarkType];
    if (landmark) {
        return @[ @(landmark.position.x), @(landmark.position.y) ];
    }
    return [NSNull null];
}

- (id)getContourPoints:(MLKFace *)face contour:(MLKFaceContourType)contourType {
    MLKFaceContour *contour = [face contourOfType:contourType];
    if (contour) {
        NSArray<MLKVisionPoint *> *contourPoints = contour.points;
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[contourPoints count]];
        for (int i = 0; i < [contourPoints count]; i++) {
            MLKVisionPoint *point = [contourPoints objectAtIndex:i];
            [result insertObject:@[ @(point.x), @(point.y) ] atIndex:i];
        }
        return [result copy];
    }
    
    return [NSNull null];
}

@end
