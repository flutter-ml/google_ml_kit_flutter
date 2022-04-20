package com.google_mlkit_commons;

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

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class GenericModelManager {
    private static final String DOWNLOAD = "download";
    private static final String DELETE = "delete";
    private static final String CHECK = "check";

    public RemoteModelManager remoteModelManager = RemoteModelManager.getInstance();

    //To avoid downloading models in the main thread as they are around 20MB and may crash the app.
    private final ExecutorService executorService = Executors.newCachedThreadPool();

    public void manageModel(final RemoteModel model, final MethodCall call, final MethodChannel.Result result) {
        String task = call.argument("task");
        switch (task) {
            case DOWNLOAD:
                boolean isWifiReqRequired = call.argument("wifi");
                DownloadConditions downloadConditions;
                if (isWifiReqRequired)
                    downloadConditions = new DownloadConditions.Builder().requireWifi().build();
                else
                    downloadConditions = new DownloadConditions.Builder().build();
                downloadModel(model, downloadConditions, result);
                break;
            case DELETE:
                deleteModel(model, result);
                break;
            case CHECK:
                Boolean downloaded = isModelDownloaded(model);
                if (downloaded != null) result.success(downloaded);
                else result.error("error", null, null);
                break;
            default:
                result.notImplemented();
        }
    }

    public void downloadModel(RemoteModel remoteModel, DownloadConditions downloadConditions, final MethodChannel.Result result) {
        if (isModelDownloaded(remoteModel)) {
            result.success("success");
            return;
        }
        remoteModelManager.download(remoteModel, downloadConditions).addOnSuccessListener(aVoid -> result.success("success")).addOnFailureListener(e -> result.error("error", e.toString(), null));
    }

    public void deleteModel(RemoteModel remoteModel, final MethodChannel.Result result) {
        if (!isModelDownloaded(remoteModel)) {
            result.success("success");
            return;
        }
        remoteModelManager.deleteDownloadedModel(remoteModel).addOnSuccessListener(aVoid -> result.success("success")).addOnFailureListener(e -> result.error("error", e.toString(), null));
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
