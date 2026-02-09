#import "GoogleMlKitTranslationPlugin.h"
#import "Pigeon.h"
#import "OnDeviceTranslatorApiImpl.h"

@implementation GoogleMlKitTranslationPlugin 

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OnDeviceTranslatorApiImpl *api = [[OnDeviceTranslatorApiImpl alloc] init];
    OnDeviceTranslatorApiSetup(registrar.messenger, api);
}

@end