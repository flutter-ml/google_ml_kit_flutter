#import "GoogleMlKitPlugin.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitImageLabeling/MLKitImageLabeling.h>
#import <MLKitImageLabelingCommon/MLKitImageLabelingCommon.h>
#import <MLKitImageLabelingCustom/MLKitImageLabelingCustom.h>

#define startImageLabelDetector @"vision#startImageLabelDetector"
#define closeImageLabelDetector @"vision#closeImageLabelDetector"

@implementation ImageLabeler {
    MLKImageLabeler *labeler;
}

- (NSArray *)getMethodsKeys {
    return @[startImageLabelDetector,
             closeImageLabelDetector];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startImageLabelDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeImageLabelDetector]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    NSDictionary *dictionary = call.arguments[@"options"];
    NSString *type = dictionary[@"labelerType"];
    
    if ([@"default" isEqualToString:type]) {
        MLKImageLabelerOptions *options = [self getImageLabelerOptions:dictionary];
        labeler = [MLKImageLabeler imageLabelerWithOptions:options];
    } else if ([@"custom" isEqualToString:type]) {
        MLKCustomImageLabelerOptions *options = [self getCustomLabelerOptions:dictionary];
        labeler = [MLKImageLabeler imageLabelerWithOptions:options];
    } else {
        NSString *reason =
        [NSString stringWithFormat:@"Invalid model type: %@", type];
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:reason
                                        userInfo:nil];
    }
    
    [labeler processImage:image
               completion:^(NSArray<MLKImageLabel *> *_Nullable labels, NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!labels) {
            result(@[]);
        }
        
        NSMutableArray *labelData = [NSMutableArray array];
        for (MLKImageLabel *label in labels) {
            NSDictionary *data = @{
                @"confidence" : @(label.confidence),
                @"index" : @(label.index),
                @"text" : label.text,
            };
            [labelData addObject:data];
        }
        
        result(labelData);
    }];
}

- (MLKImageLabelerOptions *)getImageLabelerOptions:(NSDictionary *)optionsData {
    NSNumber *conf = optionsData[@"confidenceThreshold"];
    
    MLKImageLabelerOptions *options = [MLKImageLabelerOptions new];
    options.confidenceThreshold = conf;
    
    return options;
}

- (MLKCustomImageLabelerOptions *)getCustomLabelerOptions:(NSDictionary *)optionsData {
    NSString *modelType = optionsData[@"customModel"];
    NSString *path = optionsData[@"path"];
    NSNumber *conf = optionsData[@"confidenceThreshold"];
    
    MLKLocalModel *localModel = [[MLKLocalModel alloc] initWithPath:path];
    
    MLKCustomImageLabelerOptions *options = [[MLKCustomImageLabelerOptions alloc] initWithLocalModel:localModel];
    options.confidenceThreshold = conf;
    
    return options;
}

@end
