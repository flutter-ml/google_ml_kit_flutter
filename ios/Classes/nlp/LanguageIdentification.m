
#import "GoogleMlKitPlugin.h"
#import <MLKitLanguageID/MLKitLanguageID.h>
#import <Flutter/Flutter.h>

#define startLanguageIdentifier @"nlp#startLanguageIdentifier"
#define closeLanguageIdentifier @"nlp#closeLanguageIdentifier"

// possible call arguments
#define kCallArgumentPossibleLanguages @"possibleLanguages"
#define kCallArgumentText @"text"
#define kCallArgumentConfidence @"confidence"

// possible call arguments values
#define kCallArgumentPossibleLanguagesYes @"yes"
#define kCallArgumentPossibleLanguagesNo @"no"

// possible call return arguments
#define kReturnArgumentLanguage @"language"
#define kReturnArgumentConfidence @"confidence"

#define kNoLanguageIdentified @"und"

// NOTE: changing this value means a breaking change for plugin API (on dart side)
#define kErrorCodeNoLanguageIdentified @"no language identified"

@implementation LanguageIdentifier {}

- (NSArray *)getMethodsKeys {
    return @[startLanguageIdentifier, closeLanguageIdentifier];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startLanguageIdentifier]) {
        // ensure all arguments are provided
        [self ensureCallArguments:call result:result];
        
        // handle method based on call argument
        NSString *possibleLanguages = call.arguments[kCallArgumentPossibleLanguages];
        if([possibleLanguages isEqualToString: kCallArgumentPossibleLanguagesYes]) {
            [self identifyLanguages:call result:result];
        } else if([possibleLanguages isEqualToString:kCallArgumentPossibleLanguagesNo]) {
            [self identifyLanguage:call result:result];
        } else {
            result([FlutterError errorWithCode:@"error in dart plugin" message:[NSString stringWithFormat:@"Value for %@ is unknown: %@", kCallArgumentPossibleLanguages, possibleLanguages] details:nil]);
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
    NSString *text = call.arguments[kCallArgumentText];
    NSNumber *confidence = call.arguments[kCallArgumentConfidence];
    
    MLKLanguageIdentification *languageId = [LanguageIdentifier getlanguageIdentifier:confidence.floatValue];

    [languageId identifyPossibleLanguagesForText:text
                                      completion:^(NSArray * _Nonnull identifiedLanguages,
                                                   NSError * _Nullable error) {
        if (error != nil) {
            result(getFlutterError(error));
            return;
        }
        
        // no language detected
        if (identifiedLanguages.count == 1
            && [((MLKIdentifiedLanguage *) identifiedLanguages[0]).languageTag isEqualToString:kNoLanguageIdentified] ) {
            result([FlutterError errorWithCode:kErrorCodeNoLanguageIdentified message:@"no languages detected" details:nil]);
            return;
        }
        
        NSMutableArray *resultArray = [NSMutableArray array];
        for (MLKIdentifiedLanguage *language in identifiedLanguages) {
            NSDictionary *data = @{
                kReturnArgumentLanguage : language.languageTag,
                kReturnArgumentConfidence : [NSNumber numberWithFloat: language.confidence],
            };
            [resultArray addObject:data];
        }
        result(resultArray);
    }];
}

// Identify the language for a given text.
// Read more here: https://developers.google.com/ml-kit/language/identification/ios
- (void)identifyLanguage:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSString *text = call.arguments[kCallArgumentText];
    NSNumber *confidence = call.arguments[kCallArgumentConfidence];
    
    MLKLanguageIdentification *languageId = [LanguageIdentifier getlanguageIdentifier:confidence.floatValue];

    [languageId identifyLanguageForText:text
                                      completion:^(NSString * _Nonnull languageTag,
                                                   NSError * _Nullable error) {
        if (error != nil) {
            result(getFlutterError(error));
            return;
        }
        // no language detected
        if([languageTag isEqualToString:kNoLanguageIdentified]) {
            result([FlutterError errorWithCode:kErrorCodeNoLanguageIdentified message:@"no language detected" details:nil]);
            return;
        }
        NSDictionary *data = @{
            kReturnArgumentLanguage : languageTag,
        };
        result(data);
    }];
}

// Perform some sanity checks on the call arguments
- (void)ensureCallArguments:(FlutterMethodCall *)call result:(FlutterResult)result {
    if(![call.arguments isKindOfClass:[NSDictionary class]]) {
        result([FlutterError errorWithCode:@"error in dart plugin" message:@"parameters not provided as dictionary" details:nil]);
    }

    // handle text argument
    if([((NSDictionary *)call.arguments) objectForKey:kCallArgumentText] == nil) {
        result([FlutterError errorWithCode:@"error in dart plugin" message:@"text parameter not provided" details:nil]);
    } else {
        if(![call.arguments[kCallArgumentText] isKindOfClass:[NSString class]]) {
            result([FlutterError errorWithCode:@"error in dart plugin" message:@"text parameter has wrong type" details:nil]);
        }
    }

    // handle confidence argument
    if([((NSDictionary *)call.arguments) objectForKey:kCallArgumentConfidence] == nil) {
        result([FlutterError errorWithCode:@"error in dart plugin" message:@"confidence parameter not provided" details:nil]);
    } else {
        if(![call.arguments[kCallArgumentConfidence] isKindOfClass:[NSNumber class]]) {
            result([FlutterError errorWithCode:@"error in dart plugin" message:@"confidence parameter has wrong type" details:nil]);
        }
    }

    // handle possibleLanguages argument
    if([((NSDictionary *)call.arguments) objectForKey:kCallArgumentPossibleLanguages] == nil) {
        result([FlutterError errorWithCode:@"error in dart plugin" message:@"possibleLanguages parameter not provided" details:nil]);
    } else {
        if(![call.arguments[kCallArgumentPossibleLanguages] isKindOfClass:[NSString class]]) {
            result([FlutterError errorWithCode:@"error in dart plugin" message:@"possibleLanguages parameter has wrong type" details:nil]);
        }
    }
}

+ (MLKLanguageIdentification*)getlanguageIdentifier:(float) confidence {
    MLKLanguageIdentificationOptions *options = [[MLKLanguageIdentificationOptions alloc] initWithConfidenceThreshold:confidence];
    MLKLanguageIdentification *languageId = [MLKLanguageIdentification languageIdentificationWithOptions:options];
    return languageId;
}

@end

