#import "GoogleMlKitTextRecognitionPlugin.h"
#import <MLKitTextRecognition/MLKitTextRecognition.h>
#import <MLKitTextRecognitionCommon/MLKitTextRecognitionCommon.h>
#import <MLKitTextRecognitionChinese/MLKitTextRecognitionChinese.h>
#import <MLKitTextRecognitionDevanagari/MLKitTextRecognitionDevanagari.h>
#import <MLKitTextRecognitionJapanese/MLKitTextRecognitionJapanese.h>
#import <MLKitTextRecognitionKorean/MLKitTextRecognitionKorean.h>
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#define channelName @"google_mlkit_text_recognizer"
#define startTextRecognizer @"vision#startTextRecognizer"
#define closeTextRecognizer @"vision#closeTextRecognizer"

@implementation GoogleMlKitTextRecognitionPlugin {
    MLKTextRecognizer *textRecognizer;
    int script;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:channelName
                                     binaryMessenger:[registrar messenger]];
    GoogleMlKitTextRecognitionPlugin* instance = [[GoogleMlKitTextRecognitionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startTextRecognizer]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeTextRecognizer]) {
        textRecognizer = NULL;
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    
    NSNumber *scriptValue = call.arguments[@"script"];
    if (textRecognizer == NULL || script != scriptValue.intValue) {
        [self initiateDetector:scriptValue.intValue];
    }
    
    [textRecognizer processImage:image
                      completion:^(MLKText *_Nullable visionText, NSError *_Nullable error) {
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
                     text:block.text];
            
            NSMutableArray *textLines = [NSMutableArray array];
            for (MLKTextLine *line in block.lines) {
                NSMutableDictionary *lineData = [NSMutableDictionary dictionary];
                
                [self addData:lineData
                 cornerPoints:line.cornerPoints
                        frame:line.frame
                    languages:line.recognizedLanguages
                         text:line.text];
                
                NSMutableArray *elementsData = [NSMutableArray array];
                for (MLKTextElement *element in line.elements) {
                    NSMutableDictionary *elementData = [NSMutableDictionary dictionary];
                    
                    [self addData:elementData
                     cornerPoints:element.cornerPoints
                            frame:element.frame
                        languages:NULL
                             text:element.text];
                    
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
           text:(NSString *)text {
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
    }];
}

- (void)initiateDetector:(int) value {
    script = value;
    switch(script) {
        case 0 : {
            MLKTextRecognizerOptions *latinOptions = [[MLKTextRecognizerOptions alloc] init];
            textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:latinOptions];
        }
            return;
        case 1 : {
            MLKChineseTextRecognizerOptions *chineseOptions = [[MLKChineseTextRecognizerOptions alloc] init];
            textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:chineseOptions];
        }
            return;
        case 2 : {
            MLKDevanagariTextRecognizerOptions *devanagariOptions = [[MLKDevanagariTextRecognizerOptions alloc] init];
            textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:devanagariOptions];
        }
            return;
        case 3 : {
            MLKJapaneseTextRecognizerOptions *japaneseOptions = [[MLKJapaneseTextRecognizerOptions alloc] init];
            textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:japaneseOptions];
        }
            return;
        case 4 : {
            MLKKoreanTextRecognizerOptions *koreanOptions = [[MLKKoreanTextRecognizerOptions alloc] init];
            textRecognizer = [MLKTextRecognizer textRecognizerWithOptions:koreanOptions];
        }
            return;
    }
}

@end
