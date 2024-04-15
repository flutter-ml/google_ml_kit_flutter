#import "GoogleMlKitCommonsPlugin.h"
#import <MLKitVision/MLKitVision.h>

@implementation MLKVisionImage(FlutterPlugin)

+ (MLKVisionImage *)visionImageFromData:(NSDictionary *)imageData {
    NSString *imageType = imageData[@"type"];
    if ([@"file" isEqualToString:imageType]) {
        return [self filePathToVisionImage:imageData[@"path"]];
    } else if ([@"bytes" isEqualToString:imageType]) {
        return [self bytesToVisionImage:imageData];
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
    int rotation = [metadata[@"rotation"] intValue];
    int cameraLensDirection = [metadata[@"camera_lens_direction"] intValue];
    UIImageOrientation imageOrientation = [self imageOrientationFromRotation:rotation cameraLensDirection:cameraLensDirection];
    CVPixelBufferRef pxBuffer = [self bytesToPixelBuffer:width.unsignedLongValue
                                                  height:height.unsignedLongValue
                                                  format:FOUR_CHAR_CODE(rawFormat.unsignedIntValue)
                                             baseAddress:(void *)imageBytes.bytes
                                             bytesPerRow:bytesPerRow.unsignedLongValue];
    MLKVisionImage *image = [self pixelBufferToVisionImage:pxBuffer];
    image.orientation = imageOrientation;
    return image;
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

+ (UIImageOrientation)imageOrientationFromRotation:(int)rotation cameraLensDirection:(int)cameraLensDirection {
    switch (rotation) {
        case 90:
            return cameraLensDirection == 0 ? UIImageOrientationRight  // Rotates the image 270 degrees to the left
                                            : UIImageOrientationRightMirrored;  // Rotates the image 270 degrees to the left (image is mirrored)
        case 180:
            return cameraLensDirection == 0 ? UIImageOrientationDown  // Rotates the image 180 degrees to the left
                                            : UIImageOrientationDownMirrored;  // Rotates the image 180 degrees to the left (image is mirrored)
        case 270:
            return cameraLensDirection == 0 ? UIImageOrientationLeft  // Rotates the image 90 degrees to the left
                                            : UIImageOrientationLeftMirrored;  // Rotates the image 90 degrees to the left (image is mirrored)
        default:
            return cameraLensDirection == 0 ? UIImageOrientationUp // Rotates 0 degreees
                                            : UIImageOrientationUpMirrored;  // Rotates the image 0 degrees (image is mirrored)
    }
}

@end
