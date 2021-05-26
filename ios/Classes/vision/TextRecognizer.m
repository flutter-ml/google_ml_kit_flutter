
#import "GoogleMlKitPlugin.h"
#import <MLKitTextRecognition/MLKitTextRecognition.h>

#define startTextDetector @"vision#startTextDetector"
#define closeTextDetector @"vision#closeTextDetector"

@implementation TextRecognizer {
    MLKTextRecognizer *textRecognizer;
}

- (NSArray *)getMethodsKeys {
    return @[startTextDetector,
             closeTextDetector];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startTextDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeTextDetector]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    textRecognizer = [MLKTextRecognizer textRecognizer];
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
                @"bottom" : @(frame.origin.y + frame.size.height) },
        @"recognizedLanguages" : allLanguageData,
        @"text" : text,
    }];
}

@end
