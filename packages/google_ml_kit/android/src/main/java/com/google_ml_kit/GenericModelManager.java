package com.google_ml_kit;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.common.model.RemoteModel;
import com.google.mlkit.common.model.RemoteModelManager;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import io.flutter.plugin.common.MethodChannel;

public class GenericModelManager {
    public RemoteModelManager remoteModelManager = RemoteModelManager.getInstance();

    //To avoid downloading models in the main thread as they are around 20MB and may crash the app.
    ExecutorService executorService = Executors.newCachedThreadPool();

    public void downloadModel(RemoteModel remoteModel, DownloadConditions downloadConditions, final MethodChannel.Result result) {
        if (isModelDownloaded(remoteModel)) {
            result.success("success");
            return;
        }
        remoteModelManager.download(remoteModel, downloadConditions).addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(@NonNull Void aVoid) {
                result.success("success");
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                result.error("error", e.toString(), null);
            }
        });
    }

    public void deleteModel(RemoteModel remoteModel, final MethodChannel.Result result) {
        if (!isModelDownloaded(remoteModel)) {
            result.success("success");
            return;
        }
        remoteModelManager.deleteDownloadedModel(remoteModel).addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(@NonNull Void aVoid) {
                result.success("success");
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                result.error("error", e.toString(), null);
            }
        });
    }

    public Boolean isModelDownloaded(RemoteModel model) {
        IsModelDownloaded myCallable = new IsModelDownloaded(remoteModelManager.isModelDownloaded(model));
        Future<Boolean> taskResult = executorService.submit(myCallable);
        try {
            return taskResult.get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
        return null;
    }
}

class IsModelDownloaded implements Callable<Boolean> {
    final Task<Boolean> booleanTask;

    public IsModelDownloaded(Task<Boolean> booleanTask) {
        this.booleanTask = booleanTask;
    }

    @Override
    public Boolean call() throws Exception {
        return Tasks.await(booleanTask);
    }
}
