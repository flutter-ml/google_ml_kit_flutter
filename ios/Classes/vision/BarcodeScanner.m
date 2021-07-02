#import "GoogleMlKitPlugin.h"
#import <MLKitBarcodeScanning/MLKitBarcodeScanning.h>

#define startBarcodeScanner @"vision#startBarcodeScanner"
#define closeBarcodeScanner @"vision#closeBarcodeScanner"

@implementation BarcodeScanner {
    MLKBarcodeScanner *barcodeScanner;
}

- (NSArray *)getMethodsKeys {
    return @[startBarcodeScanner,
             closeBarcodeScanner];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startBarcodeScanner]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeBarcodeScanner]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    NSArray *array = call.arguments[@"formats"];
    
    NSInteger formats = 0;
    for (NSNumber *num in array) {
        formats += [num intValue];
    }
    
    MLKBarcodeScannerOptions *options = [[MLKBarcodeScannerOptions alloc] initWithFormats: formats];
    barcodeScanner = [MLKBarcodeScanner barcodeScannerWithOptions:options];
    
    [barcodeScanner processImage:image
                      completion:^(NSArray<MLKBarcode *> *barcodes, NSError *error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!barcodes) {
            result(@[]);
            return;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        for (MLKBarcode *barcode in barcodes) {
            [array addObject:[self barcodeToDictionary:barcode]];
        }
        result(array);
    }];
}

- (NSDictionary *)barcodeToDictionary:(MLKBarcode *)barcode {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary addEntriesFromDictionary:@{
        @"type" : @(barcode.valueType) ?: [NSNull null],
        @"format" : @(barcode.format) ?: [NSNull null],
        @"rawValue" : barcode.rawValue ?: [NSNull null],
        @"rawBytes" : barcode.rawData ?: [NSNull null],
        @"displayValue" : barcode.displayValue ?: [NSNull null],
        @"boundingBoxLeft" : @(barcode.frame.origin.x),
        @"boundingBoxTop" : @(barcode.frame.origin.y),
        @"boundingBoxBottom" : @(barcode.frame.origin.y + barcode.frame.size.height),
        @"boundingBoxRight" : @(barcode.frame.origin.x + barcode.frame.size.width)
    }];
    
    switch (barcode.valueType) {
        case MLKBarcodeValueTypeUnknown:
        case MLKBarcodeValueTypeISBN:
        case MLKBarcodeValueTypeProduct:
        case MLKBarcodeValueTypeText:
            break;
        case MLKBarcodeValueTypeWiFi:
            [dictionary addEntriesFromDictionary:[self wifiToDictionary:barcode.wifi]];
            break;
        case MLKBarcodeValueTypeURL:
            [dictionary addEntriesFromDictionary:[self urlToDictionary:barcode.URL]];
            break;
        case MLKBarcodeValueTypeEmail:
            [dictionary addEntriesFromDictionary:[self emailToDictionary:barcode.email]];
            break;
        case MLKBarcodeValueTypePhone:
            [dictionary addEntriesFromDictionary:[self phoneToDictionary:barcode.phone]];
            break;
        case MLKBarcodeValueTypeSMS:
            [dictionary addEntriesFromDictionary:[self smsToDictionary:barcode.sms]];
            break;
        case MLKBarcodeValueTypeGeographicCoordinates:
            [dictionary addEntriesFromDictionary:[self geoPointToDictionary:barcode.geoPoint]];
            break;
        case MLKBarcodeValueTypeDriversLicense:
            [dictionary addEntriesFromDictionary:[self driverLicenseToDictionary:barcode.driverLicense]];
            break;
        case MLKBarcodeValueTypeContactInfo:
            [dictionary addEntriesFromDictionary:[self contactInfoToDictionary:barcode.contactInfo]];
            break;
        case MLKBarcodeValueTypeCalendarEvent:
            [dictionary addEntriesFromDictionary:[self calendarEventToDictionary:barcode.calendarEvent]];
            break;
    }
    
    return dictionary;
}

- (NSDictionary *)wifiToDictionary:(MLKBarcodeWiFi *)wifi {
    return @{
        @"ssid" : wifi.ssid ?: [NSNull null],
        @"password" : wifi.password ?: [NSNull null],
        @"encryption" : @(wifi.type)
    };
}

- (NSDictionary *)urlToDictionary:(MLKBarcodeURLBookmark *)url {
    return @{
        @"title" : url.title ?: [NSNull null],
        @"url" : url.url ?: [NSNull null]
    };
}

- (NSDictionary *)emailToDictionary:(MLKBarcodeEmail *)email {
    return @{
        @"address" : email.address ?: [NSNull null],
        @"body" : email.body ?: [NSNull null],
        @"subject" : email.subject ?: [NSNull null],
        @"emailType" : @(email.type)
    };
}

- (NSDictionary *)phoneToDictionary:(MLKBarcodePhone *)phone {
    return @{
        @"number" : phone.number ?: [NSNull null],
        @"phoneType" : @(phone.type)
    };
}

- (NSDictionary *)smsToDictionary:(MLKBarcodeSMS *)sms {
    return @{
        @"number" : sms.phoneNumber ?: [NSNull null],
        @"message" : sms.message ?: [NSNull null]
    };
}

- (NSDictionary *)geoPointToDictionary:(MLKBarcodeGeoPoint *)geo {
    return @{
        @"longitude" : @(geo.longitude),
        @"latitude" : @(geo.latitude)
    };
}

- (NSDictionary *)driverLicenseToDictionary:(MLKBarcodeDriverLicense *)license {
    return @{
        @"firstName" : license.firstName ?: [NSNull null],
        @"middleName" : license.middleName ?: [NSNull null],
        @"lastName" : license.lastName ?: [NSNull null],
        @"gender" : license.gender ?: [NSNull null],
        @"addressCity" : license.addressCity ?: [NSNull null],
        @"addressStreet" : license.addressStreet ?: [NSNull null],
        @"addressState" : license.addressState ?: [NSNull null],
        @"addressZip" : license.addressZip ?: [NSNull null],
        @"birthDate" : license.birthDate ?: [NSNull null],
        @"documentType" : license.documentType ?: [NSNull null],
        @"licenseNumber" : license.licenseNumber ?: [NSNull null],
        @"expiryDate" : license.expiryDate ?: [NSNull null],
        @"issueDate" : license.issuingDate ?: [NSNull null],
        @"country" : license.issuingCountry ?: [NSNull null]
    };
}

- (NSDictionary *)contactInfoToDictionary:(MLKBarcodeContactInfo *)contact {
    NSMutableArray<NSDictionary *> *addresses = [NSMutableArray array];
    [contact.addresses enumerateObjectsUsingBlock:^(MLKBarcodeAddress *_Nonnull address,
                                                    NSUInteger idx, BOOL *_Nonnull stop) {
        NSMutableArray<NSString *> *addressLines = [NSMutableArray array];
        [address.addressLines enumerateObjectsUsingBlock:^(NSString *_Nonnull addressLine,
                                                           NSUInteger idx, BOOL *_Nonnull stop) {
            [addressLines addObject:addressLine];
        }];
        [addresses addObject:@{@"addressLines" : addressLines, @"addressType" : @(address.type)}];
    }];
    
    NSMutableArray<NSDictionary *> *emails = [NSMutableArray array];
    [contact.emails enumerateObjectsUsingBlock:^(MLKBarcodeEmail *_Nonnull email,
                                                 NSUInteger idx, BOOL *_Nonnull stop) {
        [emails addObject:@{
            @"address" : email.address ?: [NSNull null],
            @"body" : email.body ?: [NSNull null],
            @"subject" : email.subject ?: [NSNull null],
            @"emailType" : @(email.type)
        }];
    }];
    
    NSMutableArray<NSDictionary *> *phones = [NSMutableArray array];
    [contact.phones enumerateObjectsUsingBlock:^(MLKBarcodePhone *_Nonnull phone,
                                                 NSUInteger idx, BOOL *_Nonnull stop) {
        [phones addObject:@{@"number" : phone.number ?: [NSNull null], @"phoneType" : @(phone.type)}];
    }];
    
    NSMutableArray<NSString *> *urls = [NSMutableArray array];
    [contact.urls
     enumerateObjectsUsingBlock:^(NSString *_Nonnull url, NSUInteger idx, BOOL *_Nonnull stop) {
        [urls addObject:url];
    }];
    return @{
        @"addresses" : addresses,
        @"emails" : emails,
        @"phones" : phones,
        @"urls" : urls,
        @"formattedName" : contact.name.formattedName ?: [NSNull null],
        @"firstName" : contact.name.first ?: [NSNull null],
        @"lastName" : contact.name.last ?: [NSNull null],
        @"middleName" : contact.name.middle ?: [NSNull null],
        @"prefix" : contact.name.prefix ?: [NSNull null],
        @"pronunciation" : contact.name.pronunciation ?: [NSNull null],
        @"suffix" : contact.name.suffix ?: [NSNull null],
        @"jobTitle" : contact.jobTitle ?: [NSNull null],
        @"organization" : contact.organization ?: [NSNull null]
    };
}

- (NSDictionary *)calendarEventToDictionary:(MLKBarcodeCalendarEvent *)calendar {
    return @{
        @"description" : calendar.eventDescription ?: [NSNull null],
        @"location" : calendar.location ?: [NSNull null],
        @"organizer" : calendar.organizer ?: [NSNull null],
        @"status" : calendar.status ?: [NSNull null],
        @"summary" : calendar.summary ?: [NSNull null],
        @"start" : @(calendar.start.timeIntervalSince1970),
        @"end" : @(calendar.end.timeIntervalSince1970)
    };
}

@end
