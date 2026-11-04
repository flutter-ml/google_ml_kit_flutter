import Flutter
import MLKitVision
import UIKit
import CoreGraphics
import CoreVideo

// MARK: - VisionImage from Flutter imageData
// CVPixelBuffer and CGImage from CVPixelBufferCreateWithBytes / createCGImage are Core Foundation
// types. In Swift they are memory-managed by ARC (CVPixelBufferRelease/CGImageRelease are
// explicitly unavailable). The Objective-C version's explicit releases are therefore not needed here.

extension VisionImage {
  /// Creates a VisionImage from method-channel imageData. Returns nil for invalid/missing data instead of crashing.
  @objc(visionImageFromData:)
  public static func visionImage(from imageData: [String: Any]) -> VisionImage? {
    guard let imageType = imageData["type"] as? String else {
      return nil
    }
    switch imageType {
    case "file":
      guard let path = imageData["path"] as? String else {
        return nil
      }
      return filePathToVisionImage(path)
    case "bytes":
      return bytesToVisionImage(imageData)
    case "bitmap":
      return bitmapToVisionImage(imageData)
    default:
      return nil
    }
  }

  private static func filePathToVisionImage(_ filePath: String) -> VisionImage? {
    guard let image = UIImage(contentsOfFile: filePath) else {
      return nil
    }
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation
    return visionImage
  }

  private static func bytesToVisionImage(_ imageData: [String: Any]) -> VisionImage? {
    guard let byteData = imageData["bytes"] as? FlutterStandardTypedData else {
      return nil
    }
    let imageBytes = byteData.data
    guard let metadata = imageData["metadata"] as? [String: Any],
          let width = metadata["width"] as? NSNumber,
          let height = metadata["height"] as? NSNumber,
          let rawFormat = metadata["image_format"] as? NSNumber,
          let bytesPerRow = metadata["bytes_per_row"] as? NSNumber else {
      return nil
    }
    let widthVal = Int(truncating: width)
    let heightVal = Int(truncating: height)
    let bytesPerRowVal = Int(truncating: bytesPerRow)
    let bufferSize = bytesPerRowVal * heightVal
    guard bufferSize > 0, imageBytes.count >= bufferSize else {
      return nil
    }
    let copy = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: 1)
    let copyBuffer = UnsafeMutableBufferPointer(start: copy.assumingMemoryBound(to: UInt8.self), count: bufferSize)
    imageBytes.copyBytes(to: copyBuffer)
    guard let pxBuffer = bytesToPixelBuffer(
      width: widthVal,
      height: heightVal,
      format: OSType(truncating: rawFormat),
      baseAddress: copy,
      bytesPerRow: bytesPerRowVal,
      releaseCallback: Self.releasePixelBufferBytes
    ) else {
      copy.deallocate()
      return nil
    }
    // pixelBufferToVisionImage creates a VisionImage from the buffer; on success we return it.
    // On nil, pxBuffer goes out of scope here and ARC releases the CVPixelBuffer, which
    // invokes releasePixelBufferBytes and deallocates copy—no leak.
    if let visionImage = pixelBufferToVisionImage(pxBuffer) {
      return visionImage
    }
    return nil
  }

  private static let releasePixelBufferBytes: CVPixelBufferReleaseBytesCallback = { _, baseAddress in
    guard let baseAddress = baseAddress else { return }
    UnsafeMutableRawPointer(mutating: baseAddress).deallocate()
  }

  private static func bytesToPixelBuffer(
    width: Int,
    height: Int,
    format: OSType,
    baseAddress: UnsafeMutableRawPointer,
    bytesPerRow: Int,
    releaseCallback: CVPixelBufferReleaseBytesCallback?
  ) -> CVPixelBuffer? {
    var pxBuffer: CVPixelBuffer?
    CVPixelBufferCreateWithBytes(
      kCFAllocatorDefault,
      width,
      height,
      format,
      baseAddress,
      bytesPerRow,
      releaseCallback,
      nil,
      nil,
      &pxBuffer
    )
    return pxBuffer
  }

  private static func pixelBufferToVisionImage(_ pixelBufferRef: CVPixelBuffer) -> VisionImage? {
    let ciImage = CIImage(cvPixelBuffer: pixelBufferRef)
    let context = CIContext(options: nil)
    let width = CVPixelBufferGetWidth(pixelBufferRef)
    let height = CVPixelBufferGetHeight(pixelBufferRef)
    guard let cgImage = context.createCGImage(
      ciImage,
      from: CGRect(x: 0, y: 0, width: width, height: height)
    ) else {
      return nil
    }
    // Swift ARC manages CGImage; UIImage(cgImage:) retains it.
    let uiImage = UIImage(cgImage: cgImage)
    return VisionImage(image: uiImage)
  }

  private static func bitmapToVisionImage(_ imageDict: [String: Any]) -> VisionImage? {
    guard let bitmapData = imageDict["bitmapData"] as? FlutterStandardTypedData else {
      return nil
    }

    if let metadata = imageDict["metadata"] as? [String: Any],
       let width = metadata["width"] as? NSNumber,
       let height = metadata["height"] as? NSNumber {
      var result: VisionImage?
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bytesPerPixel = 4
      let bytesPerRow = bytesPerPixel * width.intValue
      let bitsPerComponent = 8

      bitmapData.data.withUnsafeBytes { rawBuffer in
        guard let rawData = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          return
        }
        guard let context = CGContext(
          data: UnsafeMutableRawPointer(mutating: rawData),
          width: width.intValue,
          height: height.intValue,
          bitsPerComponent: bitsPerComponent,
          bytesPerRow: bytesPerRow,
          space: colorSpace,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
          return
        }
        guard let imageRef = context.makeImage() else {
          return
        }
        let image = UIImage(cgImage: imageRef)
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        result = visionImage
      }
      if let result = result {
        return result
      }
    }

    guard let image = UIImage(data: bitmapData.data) else {
      return nil
    }
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation
    return visionImage
  }
}
