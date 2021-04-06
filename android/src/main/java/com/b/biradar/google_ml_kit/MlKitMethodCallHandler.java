package com.b.biradar.google_ml_kit;

import android.content.Context;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

//Class to handle the method calls
public class MlKitMethodCallHandler implements MethodChannel.MethodCallHandler {
    private final Context applicationContext;
    //To store detector instances that receive [InputImage] as input.
    Map<String, ApiDetectorInterface> detectorMap = new HashMap<String, ApiDetectorInterface>();
    //To store detector instances that work on other parameters (offset list in digital ink recogniser)
    Map<String, Object> exceptionDetectors = new HashMap<String, Object>();
    //To store nlp detectors
    Map<String, Object> nlpDetectors = new HashMap<String, Object>();


    public MlKitMethodCallHandler(Context applicationContext) {
        this.applicationContext = applicationContext;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String[] calls = call.method.split("#");
        Log.e("Method call name", calls[1]);
        if (calls[0].equals("vision")) handleVisionDetection(call, result, calls[1]);
        else handleNlpDetection(call, result, calls[1]);

    }

    private void handleVisionDetection(MethodCall call, MethodChannel.Result result, String invokeMethod) {
        switch (invokeMethod) {
            case "startBarcodeScanner":
            case "startPoseDetector":
            case "startImageLabelDetector":
            case "startMlDigitalInkRecognizer":
            case "manageInkModels":
            case "startTextDetector":
                handleVisionDetection(call, result);
                break;
            case "closeBarcodeScanner":
            case "closePoseDetector":
            case "closeImageLabelDetector":
            case "closeMlDigitalInkRecognizer":
            case "closeTextDetector":
                closeVisionDetectors(call, result);
                break;
            default:
                result.notImplemented();
        }
    }


    private void handleNlpDetection(MethodCall call, MethodChannel.Result result, String invokeMethod) {
        switch (invokeMethod) {
            case "startLanguageIdentifier":
                handleNlpDetection(call, result);

        }
    }

    private void handleNlpDetection(MethodCall call, MethodChannel.Result result) {
        String invokeMethod = call.method.split("#")[1];
        Object detector;
        switch (invokeMethod) {
            case "startLanguageIdentifier":
                if (nlpDetectors.containsKey(invokeMethod.substring(5))) {
                    detector = nlpDetectors.get(invokeMethod.substring(5));
                } else {
                    detector = new LanguageDetector((double) call.argument("confidence"));
                    nlpDetectors.put(invokeMethod.substring(5), detector);
                }
                Log.e("Nlp handling", "calling language identifier methods");
                if (call.argument("possibleLanguages").equals("no")) {
                    ((LanguageDetector) detector).identifyLanguage((String) call.argument("text"), result);
                } else {
                    ((LanguageDetector) detector).identifyPossibleLanguages((String) call.argument("text"), result);
                }
                break;
            case "closeLanguageIdentifier":
                detector = nlpDetectors.get(invokeMethod.substring(5));
                ((LanguageDetector) detector).close();
        }
    }

    //Function to deal with method calls requesting to process an image or other information
    //Checks the method call request and then directs to perform the specific task and returns the result through method channel.
    //Throws an error if failed to create an instance of detector or to complete the detection task.
    private void handleVisionDetection(MethodCall call, MethodChannel.Result result) {
        //Get the parameters passed along with method call.
        String invokeMethod = call.method.split("#")[1];
        Map<String, Object> options = call.argument("options");

        //If method call is to manage the language models.
        if (invokeMethod.equals("manageInkModels")) {
            manageLanguageModel(call, result);
            return;
        } else if (invokeMethod.equals("startMlDigitalInkRecognizer")) {
            startDigitalInkRecogniser(call, result);
            return;
        }
        InputImage inputImage;
        try {
            inputImage = getInputImage((Map<String, Object>) call.argument("imageData"), result);
        } catch (Exception e) {
            Log.e("ImageError", "Getting Image failed");
            e.printStackTrace();
            result.error("imageInputError", e.toString(), null);
            return;
        }

        ApiDetectorInterface detector = detectorMap.get(invokeMethod.substring(5));

        if (detector == null) {
            switch (invokeMethod) {
                case "startBarcodeScanner":
                    detector = new BarcodeDetector((List<Integer>) call.argument("formats"));
                    break;
                case "startPoseDetector":
                    detector = new MlPoseDetector((Map<String, Object>) call.argument("options"));
                    break;
                case "startImageLabelDetector":
                    detector = new ImageLabelDetector(options);
                    break;
                case "startTextDetector":
                    detector = new TextDetector();
                    break;
            }

            detectorMap.put(invokeMethod.substring(5), detector);
        }


        assert detector != null;
        detector.handleDetection(inputImage, result);

    }

    //Closes the detector instances if already present else throws error.
    private void closeVisionDetectors(MethodCall call, MethodChannel.Result result) {
        String invokeMethod = call.method.split("#")[1];
        final ApiDetectorInterface detector = detectorMap.get(invokeMethod.substring(5));
        String error = String.format(invokeMethod.substring(5), "Has been closed or not been created yet");
        Log.e("Closed Detector", detectorMap.toString());
        if (invokeMethod.equals("closeMlDigitalInkRecognizer")) {
            final MlDigitalInkRecogniser recogniser = (MlDigitalInkRecogniser) exceptionDetectors.get(invokeMethod.substring(5));
            if (recogniser == null) {
                throw new IllegalArgumentException(error);
            }
            try {
                recogniser.closeDetector();
                result.success(null);
                exceptionDetectors.remove(invokeMethod.substring(5));
                return;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        if (detector == null) {
            throw new IllegalArgumentException(error);
        }

        try {
            detector.closeDetector();
            result.success(null);
        } catch (IOException e) {
            result.error("Could not close", e.getMessage(), null);
        } finally {
            detectorMap.remove(invokeMethod.substring(5));
        }
    }

    //Returns an [InputImage] from the image data received
    private InputImage getInputImage(Map<String, Object> imageData, MethodChannel.Result result) {
        //Differentiates whether the image data is a path for a image file or contains image data in form of bytes
        String model = (String) imageData.get("type");
        InputImage inputImage;
        if (model.equals("file")) {
            try {
                inputImage = InputImage.fromFilePath(applicationContext, Uri.fromFile(new File(((String) imageData.get("path")))));
                return inputImage;
            } catch (IOException e) {
                Log.e("ImageError", "Getting Image failed");
                e.printStackTrace();
                result.error("imageInputError", e.toString(), null);
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
            result.error("Invalid Input Image", null, null);
            return null;
        }
    }

    //Function to download and delete language models required for digital ink recognition api
    //Also checks if a model is already downloaded or not.
    private void manageLanguageModel(MethodCall call, MethodChannel.Result result) {
        String task = call.argument("task");
        ModelDownloadManager modelDownloadManager = ModelDownloadManager.Instance((String) call.argument("modelTag"), result);
        if (modelDownloadManager != null) {
            assert task != null;
            switch (task) {
                case "check":
                    if (modelDownloadManager.isModelDownloaded()) {
                        result.success("exists");
                    }
                    if (!modelDownloadManager.isModelDownloaded()) {
                        Log.e("Model Download Details", "Model is not Dowwnloaded");
                        result.success("not exists");
                    }
                    if (modelDownloadManager.isModelDownloaded() == null) {
                        Log.e("verification Failed ", "Error in running the is DownLoad method");
                        result.error("Verify Failed", "Error in running the is DownLoad method", null);
                    }
                    break;
                case "download":
                    String downloadResult = modelDownloadManager.downloadModel();
                    if (downloadResult.equals("fail")) {
                        result.error("Download Failed", null, null);
                    } else {
                        result.success(downloadResult);
                    }
                    break;
                case "delete":
                    String deleteResult = modelDownloadManager.deleteModel();
                    if (deleteResult.equals("fail")) {
                        result.error("Download Failed", null, null);
                    } else {
                        result.success(deleteResult);
                    }
                    break;
            }
        }
    }

    private void startDigitalInkRecogniser(MethodCall call, MethodChannel.Result result) {
        String invokeMethod = call.method.split("#")[1];

        //Retrieve the instance if already created.
        MlDigitalInkRecogniser recogniser = (MlDigitalInkRecogniser) exceptionDetectors.get(invokeMethod.substring(5));
        if (recogniser == null) {
            //Create an instance if not present in the hashMap.
            recogniser = MlDigitalInkRecogniser.Instance((String) call.argument("modelTag"), result);
        }
        if (recogniser != null) {
            recogniser.handleDetection(result, (List<Map<String, Object>>) call.argument("points"));
        } else {
            result.error("Failed to create model identifier", null, null);
        }
    }
}
