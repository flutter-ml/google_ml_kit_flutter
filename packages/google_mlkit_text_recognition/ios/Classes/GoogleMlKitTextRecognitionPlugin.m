#import "GoogleMlKitTextRecognitionPlugin.h"
#import <MLKitTextRecognition/MLKitTextRecognition.h>
#import <MLKitTextRecognitionCommon/MLKitTextRecognitionCommon.h>
#if __has_include(<MLKitTextRecognitionChinese/MLKitTextRecognitionChinese.h>)
#import <MLKitTextRecognitionChinese/MLKitTextRecognitionChinese.h>
#define _has_chinese 1
#endif
#if __has_include(<MLKitTextRecognitionDevanagari/MLKitTextRecognitionDevanagari.h>)
#import <MLKitTextRecognitionDevanagari/MLKitTextRecognitionDevanagari.h>
#define _has_devanagari 1
#endif
#if __has_include(<MLKitTextRecognitionJapanese/MLKitTextRecognitionJapanese.h>)
#import <MLKitTextRecognitionJapanese/MLKitTextRecognitionJapanese.h>
#define _has_japanese 1
#endif
#if __has_include(<MLKitTextRecognitionKorean/MLKitTextRecognitionKorean.h>)
#import <MLKitTextRecognitionKorean/MLKitTextRecognitionKorean.h>
#define _has_korean 1
#endif
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_text_recognizer"
#define startTextRecognizer @"vision#startTextRecognizer"
#define closeTextRecognizer @"vision#closeTextRecognizer"

@implementation GoogleMlKitTextRecognitionPlugin {
    NSMutableDictionary *instances;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitTextRecognitionPlugin* instance = [[GoogleMlKitTextRecognitionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    if (self)
        instances = [NSMutableDictionary dictionary];
    return  self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startTextRecognizer]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeTextRecognizer]) {
        NSString *uid = call.arguments[@"id"];
        [instances removeObjectForKey:uid];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (MLKTextRecognizer*)initialize:(FlutterMethodCall *)call {
    NSNumber *scriptValue = call.arguments[@"script"];
    switch(scriptValue.intValue) {
        default : {
            MLKTextRecognizerOptions *latinOptions = [[MLKTextRecognizerOptions alloc] init];
            return [MLKTextRecognizer textRecognizerWithOptions:latinOptions];
        }
#ifdef _has_chinese
        case 1 : {
            MLKChineseTextRecognizerOptions *chineseOptions = [[MLKChineseTextRecognizerOptions alloc] init];
            return [MLKTextRecognizer textRecognizerWithOptions:chineseOptions];
        }
#endif
#ifdef _has_devanagari
        case 2 : {
            MLKDevanagariTextRecognizerOptions *devanagariOptions = [[MLKDevanagariTextRecognizerOptions alloc] init];
            return [MLKTextRecognizer textRecognizerWithOptions:devanagariOptions];
        }
#endif
#ifdef _has_japanese
        case 3 : {
            MLKJapaneseTextRecognizerOptions *japaneseOptions = [[MLKJapaneseTextRecognizerOptions alloc] init];
            return [MLKTextRecognizer textRecognizerWithOptions:japaneseOptions];
        }
#endif
#ifdef _has_korean
        case 4 : {
            MLKKoreanTextRecognizerOptions *koreanOptions = [[MLKKoreanTextRecognizerOptions alloc] init];
            return [MLKTextRecognizer textRecognizerWithOptions:koreanOptions];
        }
#endif
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    
    NSString *uid = call.arguments[@"id"];
    MLKTextRecognizer *textRecognizer = [instances objectForKey:uid];
    if (textRecognizer == NULL) {
        textRecognizer = [self initialize:call];
        instances[uid] = textRecognizer;
    }
    
    [textRecognizer processImage:image
                      completion:^(MLKText *_Nullable visionText,
                                   NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!visionText) {
            result(@{@"text" : @"", @"blocks" : @[]});
            return;
        }
        
        NSMutableDictionary *textResult = [NSMutableDictionary dictionary];
        textResult[@"text"] = visionText.text;
        
        NSMutableArray *textBlocks = [NSMutableArray array];
        for (MLKTextBlock *block in visionText.blocks) {
            NSMutableDictionary *blockData = [NSMutableDictionary dictionary];
            
            [self addData:blockData
             cornerPoints:block.cornerPoints
                    frame:block.frame
                languages:block.recognizedLanguages
                     text:block.text
               confidence:[NSNull null]
                    angle:[NSNull null]];
            
            NSMutableArray *textLines = [NSMutableArray array];
            for (MLKTextLine *line in block.lines) {
                NSMutableDictionary *lineData = [NSMutableDictionary dictionary];
                
                [self addData:lineData
                 cornerPoints:line.cornerPoints
                        frame:line.frame
                    languages:line.recognizedLanguages
                         text:line.text
                   confidence:[NSNull null] // TODO: replace with actual value once it is supported by Google's native API
                        angle:[NSNull null]]; // TODO: replace with actual value once it is supported by Google's native API
                // API: https://developers.google.com/ml-kit/reference/ios/mlkittextrecognitioncommon/api/reference/Classes/MLKTextLine
                
                NSMutableArray *elementsData = [NSMutableArray array];
                for (MLKTextElement *element in line.elements) {
                    NSMutableDictionary *elementData = [NSMutableDictionary dictionary];
                    
                    [self addData:elementData
                     cornerPoints:element.cornerPoints
                            frame:element.frame
                        languages:element.recognizedLanguages
                             text:element.text
                       confidence:[NSNull null] // TODO: replace with actual value once it is supported by Google's native API
                            angle:[NSNull null]]; // TODO: replace with actual value once it is supported by Google's native API
                    // API: https://developers.google.com/ml-kit/reference/ios/mlkittextrecognitioncommon/api/reference/Classes/MLKTextElement
                    
                    // TODO: add when Google's native API supports it
                    elementData[@"symbols"] = @[];
                    [elementsData addObject:elementData];
                }
                
                lineData[@"elements"] = elementsData;
                [textLines addObject:lineData];
            }
            
            blockData[@"lines"] = textLines;
            [textBlocks addObject:blockData];
        }
        
        textResult[@"blocks"] = textBlocks;
        result(textResult);
    }];
}

- (void)addData:(NSMutableDictionary *)addTo
   cornerPoints:(NSArray<NSValue *> *)cornerPoints
          frame:(CGRect)frame
      languages:(NSArray<MLKTextRecognizedLanguage *> *)languages
           text:(NSString *)text
     confidence:(NSNumber *)confidence
          angle:(NSNumber *)angle {
    NSMutableArray *points = [NSMutableArray array];
    for (NSValue *point in cornerPoints) {
        [points addObject:@{ @"x" : @(point.CGPointValue.x),
                             @"y" : @(point.CGPointValue.y)}];
    }
    
    NSMutableArray *allLanguageData = [NSMutableArray array];
    for (MLKTextRecognizedLanguage *language in languages) {
        if (language.languageCode != NULL)
            [allLanguageData addObject: language.languageCode];
    }
    
    [addTo addEntriesFromDictionary:@{
        @"points" : points,
        @"rect" : @{
            @"left" : @(frame.origin.x),
            @"top" : @(frame.origin.y),
            @"right" : @(frame.origin.x + frame.size.width),
            @"bottom" : @(frame.origin.y + frame.size.height)
        },
        @"recognizedLanguages" : allLanguageData,
        @"text" : text,
        @"confidence" : confidence,
        @"angle" : angle,
    }];
}

@end
