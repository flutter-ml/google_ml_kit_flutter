package com.b.biradar.google_ml_kit;

import android.util.Log;
import android.view.MotionEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.mlkit.common.MlKitException;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.common.model.RemoteModelManager;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.digitalink.DigitalInkRecognition;
import com.google.mlkit.vision.digitalink.DigitalInkRecognitionModel;
import com.google.mlkit.vision.digitalink.DigitalInkRecognitionModelIdentifier;
import com.google.mlkit.vision.digitalink.DigitalInkRecognizer;
import com.google.mlkit.vision.digitalink.DigitalInkRecognizerOptions;
import com.google.mlkit.vision.digitalink.Ink;
import com.google.mlkit.vision.digitalink.RecognitionResult;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.FutureTask;

import io.flutter.plugin.common.MethodChannel;

import static com.google.android.gms.tasks.Tasks.await;

//Detector to recognise the text written on screen.
//Creates an abstraction over DigitalInkRecognizer api provided by ml tool kit.
public class MlDigitalInkRecogniser  {

    private DigitalInkRecognizer recognizer;
    ModelDownloadManager modelDownloadManager;


    private MlDigitalInkRecogniser(DigitalInkRecognizer recognizer, ModelDownloadManager modelDownloadManager) {
        this.recognizer = recognizer;
        this.modelDownloadManager = modelDownloadManager;
    }

    //Static method to create an instance of MlDigitalInkRecogniser. Throws an error if failed to create instance.
    public static MlDigitalInkRecogniser Instance(String modelTag, MethodChannel.Result result) {
        assert (modelTag != null);
        DigitalInkRecognitionModelIdentifier modelIdentifier;
        try {
            modelIdentifier =
                    DigitalInkRecognitionModelIdentifier.fromLanguageTag(modelTag);
        } catch (MlKitException e) {
            Log.e("Model Identifier error", e.toString());
            return null;
        }
        if (modelIdentifier == null) {
            result.error("Model Identifier error", "Failed to create a model Identifier", null);
            return null;
        }

        //Check if model is model is downloaded then create else throw error.
        ModelDownloadManager modelDownloadManager = ModelDownloadManager.Instance(modelTag, result);
        if (modelDownloadManager.isModelDownloaded()) {
            DigitalInkRecognizer recognizer = DigitalInkRecognition.getClient(
                    DigitalInkRecognizerOptions.builder(modelDownloadManager.model).build());
            return new MlDigitalInkRecogniser(recognizer, modelDownloadManager);
        } else {
            result.error("Model Error", "Model has not been downloaded yet ", null);
            return null;
        }


    }


    //Detects the text written on screen and returns the result through MethodChannel.
    public void handleDetection(final MethodChannel.Result result, List<Map<String, Object>> points) {
        Ink.Builder inkBuilder = Ink.builder();
        Ink.Stroke.Builder strokeBuilder;
        strokeBuilder = Ink.Stroke.builder();

        for (final Map<String, Object> point : points) {
            Ink.Point inkPoint = new Ink.Point() {
                @Override
                public float getX() {
                    return (float) (double) point.get("x");
                }

                @Override
                public float getY() {
                    return (float) (double) point.get("y");
                }

                @Nullable
                @Override
                public Long getTimestamp() {
                    return null;
                }
            };
            strokeBuilder.addPoint(inkPoint);
        }
        inkBuilder.addStroke(strokeBuilder.build());
        Ink ink = inkBuilder.build();
        Task<RecognitionResult> taskResult = recognizer.recognize(ink).addOnSuccessListener(new OnSuccessListener<RecognitionResult>() {
            @Override
            public void onSuccess(RecognitionResult recognitionResult) {
                result.success(recognitionResult.getCandidates().get(0).getText());
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("Recognition error", e.toString());
                result.error("recognition Error", e.toString(), null);
            }
        });
    }

    //Closes instance of DigitalInkRecognizer.
    public void closeDetector() throws IOException {
        recognizer.close();
    }


}

//Class to manage the language models required by DigitalInkRecognizer to perform recognition task.
class ModelDownloadManager {
    RemoteModelManager remoteModelManager = RemoteModelManager.getInstance();
    final DigitalInkRecognitionModel model;
    final String modelTag;

    //To avoid downloading models in the main thread as they are around 20MB and may crash the app.
    ExecutorService executorService = Executors.newCachedThreadPool();

    ModelDownloadManager(DigitalInkRecognitionModel model, String modelTag) {
        this.model = model;
        this.modelTag = modelTag;
    }

    public static ModelDownloadManager Instance(String modelTag, MethodChannel.Result result) {
        DigitalInkRecognitionModelIdentifier modelIdentifier;
        try {
            modelIdentifier =
                    DigitalInkRecognitionModelIdentifier.fromLanguageTag(modelTag);
        } catch (MlKitException e) {
            Log.e("Model Identifier error", e.toString());
            result.error("Failed to create model identifier", e.toString(), null);
            return null;
        }
        if (modelIdentifier == null) {
            result.error("Model Identifier error", "Failed to create a model Identifier", null);
            return null;
        }
        DigitalInkRecognitionModel model = DigitalInkRecognitionModel.builder(modelIdentifier).build();
        Log.e("ModelDownloadManager", "Instance creation successfull");
        return new ModelDownloadManager(model, modelTag);
    }

    //To check if a model is already present
    public Boolean isModelDownloaded() {
        IsModelDownloaded myCallable = new IsModelDownloaded(remoteModelManager.isModelDownloaded(model));
        Future<Boolean> taskResult = executorService.submit(myCallable);
        try {
            Log.e("Future Task", "Getting Future task result");
            return taskResult.get();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
        return false;
    }

    //Downloads a model only if it's not previously downloaded.Throws an error on failing to download
    public String downloadModel() {

        if (isModelDownloaded()) {
            return "exists";
        }
        Future<String> futureTask = executorService.submit(new Runnable() {
            @Override
            public void run() {
                try {
                    Tasks.await(remoteModelManager.download(model, new DownloadConditions.Builder().build()));
                } catch (ExecutionException e) {
                    e.printStackTrace();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, "success");

        try {
            futureTask.get();
        } catch (ExecutionException e) {
            Log.e("Download Execution Fail", e.toString());
            return "fail";
        } catch (InterruptedException e) {
            Log.e("Download Interrupted", e.toString());
            return "fail";
        }

        return "success";

    }

    //Deletes a model if it is previously downloaded else returns the result as not exist.Throws an error if failed to delete the model.
    public String deleteModel() {
        if (!isModelDownloaded()) {
            return "not exist";
        }
        Future<String> futureTask = executorService.submit(new Runnable() {
            @Override
            public void run() {
                try {
                    Tasks.await(remoteModelManager.deleteDownloadedModel(model));
                } catch (ExecutionException e) {
                    e.printStackTrace();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, "success");

        try {
            futureTask.get();
        } catch (ExecutionException e) {
            Log.e("Deletion Failed", e.toString());
            return "fail";
        } catch (InterruptedException e) {
            Log.e("Deletion Interrupted", e.toString());
            return "fail";
        }

        return "success";
    }
}

//Callable to run the task that checks whether a model is present.
class IsModelDownloaded implements Callable<Boolean> {
    final Task<Boolean> booleanTask;

    IsModelDownloaded(Task<Boolean> booleanTask) {
        this.booleanTask = booleanTask;
    }

    @Override
    public Boolean call() throws Exception {
        return Tasks.await(booleanTask);
    }
}

