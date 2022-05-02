#import "GoogleMlKitSelfieSegmentationPlugin.h"
#import <MLKitSegmentationSelfie/MLKitSegmentationSelfie.h>
#import <MLKitSegmentationCommon/MLKitSegmentationCommon.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_selfie_segmenter"
#define startSelfieSegmenter @"vision#startSelfieSegmenter"
#define closeSelfieSegmenter @"vision#closeSelfieSegmenter"

@implementation GoogleMlKitSelfieSegmentationPlugin {
    NSMutableDictionary *instances;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitSelfieSegmentationPlugin* instance = [[GoogleMlKitSelfieSegmentationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startSelfieSegmenter]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeSelfieSegmenter]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (MLKSegmenter*)initialize:(FlutterMethodCall *)call {
    BOOL isStream = [[call.arguments objectForKey:@"isStream"] boolValue];
    BOOL enableRawSizeMask = [[call.arguments objectForKey:@"enableRawSizeMask"] boolValue];
    
    MLKSelfieSegmenterOptions *options = [[MLKSelfieSegmenterOptions alloc] init];
    options.segmenterMode = isStream ? MLKSegmenterModeStream : MLKSegmenterModeSingleImage;
    options.shouldEnableRawSizeMask = enableRawSizeMask;
    
    return [MLKSegmenter segmenterWithOptions:options];
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    
    NSString *uid = call.arguments[@"id"];
    MLKSegmenter *segmenter = [instances objectForKey:uid];
    if (segmenter == NULL) {
        segmenter = [self initialize:call];
        instances[uid] = segmenter;
    }
    
    [segmenter processImage:image
                 completion:^(MLKSegmentationMask * _Nullable mask,
                              NSError * _Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (mask == NULL) {
            result(NULL);
            return;
        }
        
        size_t width = CVPixelBufferGetWidth(mask.buffer);
        size_t height = CVPixelBufferGetHeight(mask.buffer);
        
        CVPixelBufferLockBaseAddress(mask.buffer, kCVPixelBufferLock_ReadOnly);
        size_t maskBytesPerRow = CVPixelBufferGetBytesPerRow(mask.buffer);
        float *maskAddress = (float *)CVPixelBufferGetBaseAddress(mask.buffer);
        
        NSMutableArray *confidences = [NSMutableArray array];
        for (int row = 0; row < height; ++row) {
            for (int col = 0; col < width; ++col) {
                // Gets the confidence of the pixel in the mask being in the foreground.
                float confidence = maskAddress[col];
                [confidences addObject:@(confidence)];
            }
            maskAddress += maskBytesPerRow / sizeof(float);
        }
        
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        dictionary[@"width"] = @(width);
        dictionary[@"height"] = @(height);
        dictionary[@"confidences"] = confidences;
        
        result(dictionary);
    }];
}

@end
