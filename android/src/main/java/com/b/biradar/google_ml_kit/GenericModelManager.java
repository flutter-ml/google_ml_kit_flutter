package com.b.biradar.google_ml_kit;

import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.common.model.RemoteModel;
import com.google.mlkit.common.model.RemoteModelManager;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import io.flutter.plugin.common.MethodChannel;


public class GenericModelManager {
    RemoteModelManager remoteModelManager = RemoteModelManager.getInstance();

    public void downloadModel(RemoteModel remoteModel, DownloadConditions downloadConditions, final MethodChannel.Result result) {

        remoteModelManager.download(remoteModel, downloadConditions).addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(@NonNull Void aVoid) {
                result.success("success");
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("error", e.toString());
                result.error("error", e.toString(), null);
            }
        });
    }

    public void deleteModel(RemoteModel remoteModel, final MethodChannel.Result result) {

        remoteModelManager.deleteDownloadedModel(remoteModel).addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(@NonNull Void aVoid) {
                result.success("success");
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("Error deleting model", e.toString(), null);
                result.error("error", e.toString(), null);
            }
        });
    }

    public Boolean isModelDownloaded(RemoteModel model) {
        ExecutorService executorService = Executors.newCachedThreadPool();
        IsModelDownloaded myCallable = new IsModelDownloaded(remoteModelManager.isModelDownloaded(model));
        Future<Boolean> taskResult = executorService.submit(myCallable);
        try {
            return taskResult.get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return null;
        }
    }
}
