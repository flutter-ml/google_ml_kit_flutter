#import "GoogleMlKitCommonsPlugin.h"
#import <MLKitVision/MLKitVision.h>

@implementation MLKVisionImage(FlutterPlugin)

+ (MLKVisionImage *)visionImageFromData:(NSDictionary *)imageData {
    NSString *imageType = imageData[@"type"];
    if ([@"file" isEqualToString:imageType]) {
        int rotation = [imageData[@"metadata"][@"rotation"] intValue];
        UIImageOrientation imageOrientation = [self imageOrientationFromRotation:rotation];
        MLKVisionImage *image = [self filePathToVisionImage:imageData[@"path"]];
        image.orientation = imageOrientation;
        return image;
    } else if ([@"bytes" isEqualToString:imageType]) {
        int rotation = [imageData[@"metadata"][@"rotation"] intValue];
        UIImageOrientation imageOrientation = [self imageOrientationFromRotation:rotation];
        MLKVisionImage *image = [self bytesToVisionImage:imageData];
        image.orientation = imageOrientation;
        return image;
    } else {
        NSString *errorReason = [NSString stringWithFormat:@"No image type for: %@", imageType];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:errorReason
                                     userInfo:nil];
    }
}

+ (UIImageOrientation)imageOrientationFromRotation:(int)rotation {
    switch (rotation) {
        case 90:
            return UIImageOrientationRight;  // Rotates the image 90 degrees to the right
        case 180:
            return UIImageOrientationDown;  // Rotates the image 180 degrees
        case 270:
            return UIImageOrientationLeft;  // Rotates the image 90 degrees to the left
        default:
            return UIImageOrientationUp;  // Default orientation (no rotation)
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

@end
