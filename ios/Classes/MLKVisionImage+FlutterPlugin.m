#import "GoogleMlKitPlugin.h"

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
    
    if (image.imageOrientation != UIImageOrientationUp) {
        CGImageRef imgRef = image.CGImage;
        CGRect bounds = CGRectMake(0, 0, CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
        UIGraphicsBeginImageContext(bounds.size);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), bounds, imgRef);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        image = newImage;
    }
    
    return [[MLKVisionImage alloc] initWithImage:image];
}

+ (MLKVisionImage *)bytesToVisionImage:(NSDictionary *)imageData {
    FlutterStandardTypedData *byteData = imageData[@"bytes"];
    NSData *imageBytes = byteData.data;
    
    NSDictionary *metadata = imageData[@"metadata"];
    NSArray *planeData = metadata[@"planeData"];
    size_t planeCount = planeData.count;
    
    NSNumber *width = metadata[@"width"];
    NSNumber *height = metadata[@"height"];
    
    NSNumber *rawFormat = metadata[@"imageFormat"];
    FourCharCode format = FOUR_CHAR_CODE(rawFormat.unsignedIntValue);
    
    CVPixelBufferRef pxBuffer = NULL;
    if (planeCount == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Can't create image buffer with 0 planes."
                                     userInfo:nil];
    } else if (planeCount == 1) {
        NSDictionary *plane = planeData[0];
        NSNumber *bytesPerRow = plane[@"bytesPerRow"];
        
        pxBuffer = [self bytesToPixelBuffer:width.unsignedLongValue
                                     height:height.unsignedLongValue
                                     format:format
                                baseAddress:(void *)imageBytes.bytes
                                bytesPerRow:bytesPerRow.unsignedLongValue];
    } else {
        pxBuffer = [self planarBytesToPixelBuffer:width.unsignedLongValue
                                           height:height.unsignedLongValue
                                           format:format
                                      baseAddress:(void *)imageBytes.bytes
                                         dataSize:imageBytes.length
                                       planeCount:planeCount
                                        planeData:planeData];
    }
    
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

+ (CVPixelBufferRef)planarBytesToPixelBuffer:(size_t)width
                                      height:(size_t)height
                                      format:(FourCharCode)format
                                 baseAddress:(void *)baseAddress
                                    dataSize:(size_t)dataSize
                                  planeCount:(size_t)planeCount
                                   planeData:(NSArray *)planeData {
    size_t widths[planeCount];
    size_t heights[planeCount];
    size_t bytesPerRows[planeCount];
    
    void *baseAddresses[planeCount];
    baseAddresses[0] = baseAddress;
    
    size_t lastAddressIndex = 0;  // Used to get base address for each plane
    for (int i = 0; i < planeCount; i++) {
        NSDictionary *plane = planeData[i];
        
        NSNumber *width = plane[@"width"];
        NSNumber *height = plane[@"height"];
        NSNumber *bytesPerRow = plane[@"bytesPerRow"];
        
        widths[i] = width.unsignedLongValue;
        heights[i] = height.unsignedLongValue;
        bytesPerRows[i] = bytesPerRow.unsignedLongValue;
        
        if (i > 0) {
            size_t addressIndex = lastAddressIndex + heights[i - 1] * bytesPerRows[i - 1];
            baseAddresses[i] = baseAddress + addressIndex;
            lastAddressIndex = addressIndex;
        }
    }
    
    CVPixelBufferRef pxBuffer = NULL;
    CVPixelBufferCreateWithPlanarBytes(kCFAllocatorDefault, width, height, format, NULL, dataSize,
                                       planeCount, baseAddresses, widths, heights, bytesPerRows, NULL,
                                       NULL, NULL, &pxBuffer);
    
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
