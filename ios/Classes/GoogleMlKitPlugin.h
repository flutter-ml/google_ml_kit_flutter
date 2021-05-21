#import <Flutter/Flutter.h>

#import <MLKitVision/MLKitVision.h>

@interface GoogleMlKitPlugin : NSObject<FlutterPlugin>
@property(nonatomic, readwrite) NSMutableDictionary *handlers;
@end

@interface MLKVisionImage(FlutterPlugin)
+ (MLKVisionImage *)visionImageFromData:(NSDictionary *)imageData;
@end

@protocol Handler
@required
- (NSArray*)getMethodsKeys;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
@optional
@end

@interface FaceProcessor : NSObject <Handler>
@end

@interface ImageLabeler : NSObject <Handler>
@end

static FlutterError *getFlutterError(NSError *error) {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                               message:error.domain
                               details:error.localizedDescription];
}
