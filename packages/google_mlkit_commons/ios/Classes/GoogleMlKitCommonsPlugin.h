#import <Flutter/Flutter.h>
#import <MLKitVision/MLKitVision.h>
#import "GenericModelManager.h"

@interface GoogleMlKitCommonsPlugin : NSObject<FlutterPlugin>
@end

@interface MLKVisionImage(FlutterPlugin)
+ (MLKVisionImage *)visionImageFromData:(NSDictionary *)imageData;
@end

static FlutterError *getFlutterError(NSError *error) {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                               message:error.domain
                               details:error.localizedDescription];
}
