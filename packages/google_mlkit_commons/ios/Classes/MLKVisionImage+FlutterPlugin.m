#import "GoogleMlKitCommonsPlugin.h"
#import <MLKitVision/MLKitVision.h>

@implementation MLKVisionImage(FlutterPlugin)

+ (MLKVisionImage *)visionImageFromData:(NSDictionary *)imageData {
    NSString *imageType = imageData[@"type"];
    if ([@"file" isEqualToString:imageType]) {
        return [self filePathToVisionImage:imageData[@"path"]];
    } else if ([@"bytes" isEqualToString:imageType]) {
        return [self bytesToVisionImage:imageData];
    } else if ([@"bitmap" isEqualToString:imageType]) {
        return [self bitmapToVisionImage:imageData];
    } else {
        NSString *errorReason = [NSString stringWithFormat:@"No image type for: %@", imageType];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:errorReason
                                     userInfo:nil];
    }
}

+ (MLKVisionImage *)filePathToVisionImage:(NSString *)filePath {
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;
    return visionImage;
}

+ (MLKVisionImage *)bytesToVisionImage:(NSDictionary *)imageData {
    FlutterStandardTypedData *byteData = imageData[@"bytes"];
    NSData *imageBytes = byteData.data;
    NSDictionary *metadata = imageData[@"metadata"];
    NSNumber *width = metadata[@"width"];
    NSNumber *height = metadata[@"height"];
    NSNumber *rawFormat = metadata[@"image_format"];
    NSNumber *bytesPerRow = metadata[@"bytes_per_row"];
    CVPixelBufferRef pxBuffer = [self bytesToPixelBuffer:width.unsignedLongValue
                                                  height:height.unsignedLongValue
                                                  format:FOUR_CHAR_CODE(rawFormat.unsignedIntValue)
                                             baseAddress:(void *)imageBytes.bytes
                                             bytesPerRow:bytesPerRow.unsignedLongValue];
    return [self pixelBufferToVisionImage:pxBuffer];
}

+ (CVPixelBufferRef)bytesToPixelBuffer:(size_t)width
                                height:(size_t)height
                                format:(FourCharCode)format
                           baseAddress:(void *)baseAddress
                           bytesPerRow:(size_t)bytesPerRow {
    CVPixelBufferRef pxBuffer = NULL;
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, format, baseAddress, bytesPerRow,
                                 NULL, NULL, NULL, &pxBuffer);
    return pxBuffer;
}

+ (MLKVisionImage *)pixelBufferToVisionImage:(CVPixelBufferRef)pixelBufferRef {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBufferRef];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage =
    [temporaryContext createCGImage:ciImage
                           fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBufferRef),
                                               CVPixelBufferGetHeight(pixelBufferRef))];
    
    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CVPixelBufferRelease(pixelBufferRef);
    CGImageRelease(videoImage);
    return [[MLKVisionImage alloc] initWithImage:uiImage];
}

+ (MLKVisionImage *)bitmapToVisionImage:(NSDictionary *)imageDict {
    // Get the bitmap data
    FlutterStandardTypedData *bitmapData = imageDict[@"bitmapData"];
    
    if (bitmapData == nil) {
        NSString *errorReason = @"Bitmap data is nil";
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:errorReason
                                     userInfo:nil];
    }
    
    // Try to get metadata if available
    NSDictionary *metadata = imageDict[@"metadata"];
    if (metadata != nil) {
        NSNumber *width = metadata[@"width"];
        NSNumber *height = metadata[@"height"];
        
        if (width != nil && height != nil) {
            // Create bitmap context from raw RGBA data
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            uint8_t *rawData = (uint8_t*)[bitmapData.data bytes];
            size_t bytesPerPixel = 4;
            size_t bytesPerRow = bytesPerPixel * width.intValue;
            size_t bitsPerComponent = 8;
            
            CGContextRef context = CGBitmapContextCreate(rawData, width.intValue, height.intValue,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            
            if (context) {
                CGImageRef imageRef = CGBitmapContextCreateImage(context);
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                
                CGImageRelease(imageRef);
                CGContextRelease(context);
                CGColorSpaceRelease(colorSpace);
                
                if (image) {
                    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
                    visionImage.orientation = image.imageOrientation;
                    return visionImage;
                }
            }
            
            CGColorSpaceRelease(colorSpace);
        }
    }
    
    // Fallback: try to create UIImage directly from data
    UIImage *image = [UIImage imageWithData:bitmapData.data];
    
    if (image == nil) {
        NSString *errorReason = @"Failed to create UIImage from bitmap data";
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:errorReason
                                     userInfo:nil];
    }
    
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;
    return visionImage;
}

@end
