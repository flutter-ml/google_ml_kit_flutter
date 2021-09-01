
#import "GoogleMlKitPlugin.h"
#import <MLKitLanguageID/MLKitLanguageID.h>

#define startLanguageIdentifier @"nlp#startLanguageIdentifier"
#define closeLanguageIdentifier @"nlp#closeLanguageIdentifier"

@implementation LanguageIdentifier {}

- (NSArray *)getMethodsKeys {
    return @[startLanguageIdentifier];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startLanguageIdentifier]) {
        // handle method based on call argument
        NSString *possibleLanguages = call.arguments[@"possibleLanguages"];
        if([possibleLanguages isEqualToString: @"yes"]) {
            [self identifyLanguages:call result:result];
        } else if([possibleLanguages isEqualToString:@"no"]) {
            [self identifyLanguage:call result:result];
        } else {
            result([FlutterError errorWithCode:@"error in dart plugin" message:[NSString stringWithFormat:@"Value is unknown: %@", possibleLanguages] details:nil]);
        }
    } else if ([call.method isEqualToString:closeLanguageIdentifier]) {
        // nothing to do here
        // NOTE: the MLKLanguageIdentification class is not cached in between identifyLanguages and identifyLanguage
        // because the confidence might be different for each call
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// Identifies the possible languages for a given text.
// For each identified langauge a confidence value is returned as well.
// Read more here: https://developers.google.com/ml-kit/language/identification/ios
- (void)identifyLanguages:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *text = call.arguments[@"text"];
    NSNumber *confidence = call.arguments[@"confidence"];
    
    MLKLanguageIdentificationOptions *options = [[MLKLanguageIdentificationOptions alloc] initWithConfidenceThreshold:confidence.floatValue];
    MLKLanguageIdentification *languageId = [MLKLanguageIdentification languageIdentificationWithOptions:options];

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

// Identify the language for a given text.
// Read more here: https://developers.google.com/ml-kit/language/identification/ios
- (void)identifyLanguage:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSString *text = call.arguments[@"text"];
    NSNumber *confidence = call.arguments[@"confidence"];
    
    // source: https://developers.google.com/ml-kit/language/identification/ios#swift
    MLKLanguageIdentificationOptions *options = [[MLKLanguageIdentificationOptions alloc] initWithConfidenceThreshold:confidence.floatValue];
    MLKLanguageIdentification *languageId = [MLKLanguageIdentification languageIdentificationWithOptions:options];

    [languageId identifyLanguageForText:text
                                      completion:^(NSString * _Nonnull languageTag,
                                                   NSError * _Nullable error) {
        if (error != nil) {
            result(getFlutterError(error));
            return;
        }
        if([languageTag isEqualToString:@"und"]) {
            return result(@{});
        }
        NSDictionary *data = @{
            @"language" : languageTag,
        };
        result(data);
    }];
}

@end
