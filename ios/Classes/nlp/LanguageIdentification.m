
#import "GoogleMlKitPlugin.h"
#import <MLKitLanguageID/MLKitLanguageID.h>

#define startLanguageIdentifier @"nlp#startLanguageIdentifier"
#define closeLanguageIdentifier @"nlp#closeLanguageIdentifier"

@implementation LanguageIdentifier {
    MLKLanguageIdentification *languageId;
}

- (NSArray *)getMethodsKeys {
    return @[startLanguageIdentifier];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startLanguageIdentifier]) {
        [self identifyLanguages:call result:result];
    } else if ([call.method isEqualToString:closeLanguageIdentifier]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)identifyLanguages:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *text = call.arguments[@"text"];
    NSNumber *confidence = call.arguments[@"confidence"];
    
    if(languageId == nil) {
        MLKLanguageIdentificationOptions *options = [[MLKLanguageIdentificationOptions alloc] initWithConfidenceThreshold:confidence.floatValue];
        languageId = [MLKLanguageIdentification languageIdentificationWithOptions:options];
    }

    // source: https://developers.google.com/ml-kit/language/identification/ios#swift
    [languageId identifyPossibleLanguagesForText:text
                                      completion:^(NSArray * _Nonnull identifiedLanguages,
                                                   NSError * _Nullable error) {
        if (error != nil) {
            result(getFlutterError(error));
            return;
        }
        if (identifiedLanguages.count == 1
            && [((MLKIdentifiedLanguage *) identifiedLanguages[0]).languageTag isEqualToString:@"und"] ) {
            return result(@{});
        }
        NSMutableArray *resultArray = [NSMutableArray array];
        for (MLKIdentifiedLanguage *language in identifiedLanguages) {
            NSDictionary *data = @{
                @"language" : language.languageTag,
                @"confidence" : [NSNumber numberWithFloat: language.confidence],
            };
            [resultArray addObject:data];
        }
        result(resultArray);
    }];
}
@end
