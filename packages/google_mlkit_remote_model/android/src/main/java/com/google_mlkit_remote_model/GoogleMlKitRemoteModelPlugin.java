package com.google_mlkit_remote_model;

import androidx.annotation.NonNull;

import com.google.mlkit.common.model.CustomRemoteModel;
import com.google.mlkit.linkfirebase.FirebaseModelSource;
import com.google_mlkit_commons.GenericModelManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class GoogleMlKitRemoteModelPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private MethodChannel channel;
    private static final String channelName = "google_mlkit_remote_model_manager";
    private static final String MANAGE = "vision#manageRemoteModel";

    private final GenericModelManager genericModelManager = new GenericModelManager();

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channelName);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String method = call.method;
        switch (method) {
            case MANAGE:
                manageModel(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void manageModel(MethodCall call, final MethodChannel.Result result) {
        CustomRemoteModel model = new CustomRemoteModel.Builder(
                new FirebaseModelSource.Builder(call.argument("model")).build()
        ).build();
        genericModelManager.manageModel(model, call, result);
    }
}
