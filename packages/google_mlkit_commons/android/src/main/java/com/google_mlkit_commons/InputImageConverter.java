package com.google_mlkit_commons;

import android.content.Context;
import android.net.Uri;
import android.util.Log;

import com.google.mlkit.vision.common.InputImage;

import java.io.File;
import java.io.IOException;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class InputImageConverter {

    //Returns an [InputImage] from the image data received
    public static InputImage getInputImageFromData(Map<String, Object> imageData,
                                                   Context context,
                                                   MethodChannel.Result result) {
        //Differentiates whether the image data is a path for a image file or contains image data in form of bytes
        String model = (String) imageData.get("type");
        InputImage inputImage;
        if (model.equals("file")) {
            try {
                inputImage = InputImage.fromFilePath(context, Uri.fromFile(new File(((String) imageData.get("path")))));
                return inputImage;
            } catch (IOException e) {
                Log.e("ImageError", "Getting Image failed");
                e.printStackTrace();
                result.error("InputImageConverterError", e.toString(), null);
                return null;
            }
        } else if (model.equals("bytes")) {
            Map<String, Object> metaData = (Map<String, Object>) imageData.get("metadata");
            inputImage = InputImage.fromByteArray((byte[]) imageData.get("bytes"),
                    (int) (double) metaData.get("width"),
                    (int) (double) metaData.get("height"),
                    (int) metaData.get("rotation"),
                    InputImage.IMAGE_FORMAT_NV21);
            return inputImage;
        } else {
            result.error("InputImageConverterError", "Invalid Input Image", null);
            return null;
        }
    }

}
