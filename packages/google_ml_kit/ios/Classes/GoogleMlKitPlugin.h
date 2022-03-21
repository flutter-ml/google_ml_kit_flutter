#import <Flutter/Flutter.h>

@interface GoogleMlKitPlugin : NSObject<FlutterPlugin>
@property(nonatomic, readwrite) NSMutableDictionary *handlers;
@end

@protocol Handler
@required
- (NSArray*)getMethodsKeys;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
@optional
@end

@interface CustomRemoteModelManager : NSObject <Handler>
@end

@interface DigitalInkRecogniser : NSObject <Handler>
@end

@interface ImageLabeler : NSObject <Handler>
@end

@interface TextRecognizer : NSObject <Handler>
@end

@interface LanguageIdentifier : NSObject <Handler>
@end
