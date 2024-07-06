package com.google_mlkit_commons;

import android.content.Context;
import android.net.Uri;
import android.util.Log;

import com.google.mlkit.vision.common.InputImage;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.MethodChannel;

public class InputImageConverter {

    //Returns an [InputImage] from the image data received
    public static InputImage getInputImageFromData(Map<String, Object> imageData,
                                                   Context context,
                                                   MethodChannel.Result result) {
        //Differentiates whether the image data is a path for a image file or contains image data in form of bytes
        String model = (String) imageData.get("type");
        InputImage inputImage;
        if (model != null && model.equals("file")) {
            try {
                inputImage = InputImage.fromFilePath(context, Uri.fromFile(new File(((String) imageData.get("path")))));
                return inputImage;
            } catch (IOException e) {
                Log.e("ImageError", "Getting Image failed");
                Log.e("ImageError", e.toString());
                result.error("InputImageConverterError", e.toString(), null);
                return null;
            }
        } else {
            if (model != null && model.equals("bytes")) {
                try {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> metaData = (Map<String, Object>) imageData.get("metadata");

                    assert metaData != null;
                    inputImage = InputImage.fromByteArray((byte[]) Objects.requireNonNull(imageData.get("bytes")),
                            Double.valueOf(Objects.requireNonNull(metaData.get("width")).toString()).intValue(),
                            Double.valueOf(Objects.requireNonNull(metaData.get("height")).toString()).intValue(),
                            Integer.parseInt(Objects.requireNonNull(metaData.get("rotation")).toString()),
                            Integer.parseInt(Objects.requireNonNull(metaData.get("image_format")).toString()));
                    return inputImage;
                } catch (Exception e) {
                    Log.e("ImageError", "Getting Image failed");
                    Log.e("ImageError", e.toString());
                    result.error("InputImageConverterError", e.toString(), null);
                    return null;
                }
            } else {
                result.error("InputImageConverterError", "Invalid Input Image", null);
                return null;
            }
        }
    }

}
