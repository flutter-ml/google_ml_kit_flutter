package com.google_mlkit_commons;

import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.media.Image;
import android.media.ImageWriter;
import android.net.Uri;
import android.util.Log;
import android.view.Surface;

import com.google.mlkit.vision.common.InputImage;

import java.io.File;
import java.io.IOException;
import java.lang.AutoCloseable;
import java.nio.ByteBuffer;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.MethodChannel;

public class InputImageConverter implements AutoCloseable {

    ImageWriter writer;

    //Returns an [InputImage] from the image data received
    public InputImage getInputImageFromData(Map<String, Object> imageData,
            Context context,
            MethodChannel.Result result) {
        //Differentiates whether the image data is a path for a image file, contains image data in form of bytes, or a bitmap
        String model = (String) imageData.get("type");
        InputImage inputImage;
        if (model != null && model.equals("bitmap")) {
            try {
                byte[] bitmapData = (byte[]) imageData.get("bitmapData");
                if (bitmapData == null) {
                    result.error("InputImageConverterError", "Bitmap data is null", null);
                    return null;
                }
                
                // Extract the rotation
                int rotation = 0;
                Object rotationObj = imageData.get("rotation");
                if (rotationObj != null) {
                    rotation = (int) rotationObj;
                }
                
                try {
                    // Get metadata from the InputImage object if available
                    Map<String, Object> metadataMap = (Map<String, Object>) imageData.get("metadata");
                    if (metadataMap != null) {
                        int width = Double.valueOf(Objects.requireNonNull(metadataMap.get("width")).toString()).intValue();
                        int height = Double.valueOf(Objects.requireNonNull(metadataMap.get("height")).toString()).intValue();
                        
                        // Create bitmap from the Flutter UI raw RGBA bytes
                        android.graphics.Bitmap bitmap = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888);
                        java.nio.IntBuffer intBuffer = java.nio.IntBuffer.allocate(bitmapData.length / 4);
                        
                        // Convert RGBA bytes to int pixels
                        for (int i = 0; i < bitmapData.length; i += 4) {
                            int r = bitmapData[i] & 0xFF;
                            int g = bitmapData[i + 1] & 0xFF;
                            int b = bitmapData[i + 2] & 0xFF;
                            int a = bitmapData[i + 3] & 0xFF;
                            intBuffer.put((a << 24) | (r << 16) | (g << 8) | b);
                        }
                        intBuffer.rewind();
                        
                        // Copy pixel data to bitmap
                        bitmap.copyPixelsFromBuffer(intBuffer);
                        return InputImage.fromBitmap(bitmap, rotation);
                    }
                } catch (Exception e) {
                    Log.e("ImageError", "Error creating bitmap from raw data", e);
                }
                
                // Fallback: Try to decode as standard image format (JPEG, PNG)
                try {
                    android.graphics.Bitmap bitmap = android.graphics.BitmapFactory.decodeByteArray(bitmapData, 0, bitmapData.length);
                    if (bitmap == null) {
                        result.error("InputImageConverterError", "Failed to decode bitmap from the provided data", null);
                        return null;
                    }
                    return InputImage.fromBitmap(bitmap, rotation);
                } catch (Exception e) {
                    Log.e("ImageError", "Getting Bitmap failed", e);
                    result.error("InputImageConverterError", e.toString(), e);
                    return null;
                }
            } catch (Exception e) {
                Log.e("ImageError", "Getting Bitmap failed");
                Log.e("ImageError", e.toString());
                result.error("InputImageConverterError", e.toString(), e);
                return null;
            }
        } else if (model != null && model.equals("file")) {
            try {
                inputImage = InputImage.fromFilePath(context, Uri.fromFile(new File(((String) imageData.get("path")))));
                return inputImage;
            } catch (IOException e) {
                Log.e("ImageError", "Getting Image failed");
                Log.e("ImageError", e.toString());
                result.error("InputImageConverterError", e.toString(), e);
                return null;
            }
        } else {
            if (model != null && model.equals("bytes")) {
                try {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> metaData = (Map<String, Object>) imageData.get("metadata");

                    assert metaData != null;
                    byte[] data = (byte[]) Objects.requireNonNull(imageData.get("bytes"));
                    int imageFormat = Integer.parseInt(Objects.requireNonNull(metaData.get("image_format")).toString());
                    int rotationDegrees = Integer.parseInt(Objects.requireNonNull(metaData.get("rotation")).toString());
                    int width = Double.valueOf(Objects.requireNonNull(metaData.get("width")).toString()).intValue();
                    int height = Double.valueOf(Objects.requireNonNull(metaData.get("height")).toString()).intValue();
                    if (imageFormat == ImageFormat.NV21 || imageFormat == ImageFormat.YV12) {
                        return InputImage.fromByteArray(
                                data,
                                width,
                                height,
                                rotationDegrees,
                                imageFormat);
                    }
                    if (imageFormat == ImageFormat.YUV_420_888) {
                        // This image format is only supported in InputImage.fromMediaImage, which requires to transform the data to the right java type.
                        // TODO: Consider reusing the same Surface across multiple calls to save on allocations.
                        writer = new ImageWriter.Builder(new Surface(new SurfaceTexture(true)))
                                .setWidthAndHeight(width, height)
                                .setImageFormat(imageFormat)
                                .build();
                        Image image = writer.dequeueInputImage();
                        if (image == null) {
                            result.error("InputImageConverterError", "failed to allocate space for input image", null);
                            return null;
                        }
                        // Deconstruct individual planes again from flattened array. 
                        Image.Plane[] planes = image.getPlanes();
                        // Y plane
                        ByteBuffer yBuffer = planes[0].getBuffer();
                        yBuffer.put(data, 0, width * height);

                        // U plane
                        ByteBuffer uBuffer = planes[1].getBuffer();
                        int uOffset = width * height;
                        uBuffer.put(data, uOffset, (width * height) / 4);

                        // V plane
                        ByteBuffer vBuffer = planes[2].getBuffer();
                        int vOffset = uOffset + (width * height) / 4;
                        vBuffer.put(data, vOffset, (width * height) / 4);
                        return InputImage.fromMediaImage(image, rotationDegrees);
                    }
                    result.error("InputImageConverterError", "ImageFormat is not supported.", null);
                    return null;
                } catch (Exception e) {
                    Log.e("ImageError", "Getting Image failed");
                    Log.e("ImageError", e.toString());
                    result.error("InputImageConverterError", e.toString(), e);
                    return null;
                }
            } else {
                result.error("InputImageConverterError", "Invalid Input Image", null);
                return null;
            }
        }
    }

    @Override
    public void close() {
        if (writer != null) {
            writer.close();
        }
    }

}
