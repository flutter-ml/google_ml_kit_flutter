package com.google_mlkit_document_scanner;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentSender;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanner;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning;
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.ArrayList;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class GoogleMlkitDocumentScannerPlugin implements FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler,
        PluginRegistry.ActivityResultListener {
    private static final String channelName = "google_mlkit_document_scanner";
    private static final String START = "vision#startDocumentScanner";
    private static final String CLOSE = "vision#closeDocumentScanner";

    private MethodChannel channel;
    private Activity activity;
    private ActivityPluginBinding binding;
    private final Map<String, GmsDocumentScanner> instances = new HashMap<>();
    private MethodChannel.Result pendingResult = null;

    private static final String TAG = "DocumentScanner";
    final private int START_DOCUMENT_ACTIVITY = 0x362738;

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
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        addActivityResultListener(binding);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        addActivityResultListener(binding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;

        if (activity == null) {
            result.error(TAG, "Activity is null", null);
            return;
        }

        switch (method) {
            case START:
                handleScanner(call, result);
                break;
            case CLOSE:
                closeScanner(call);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent intent) {
        if (requestCode == START_DOCUMENT_ACTIVITY) {
            GmsDocumentScanningResult result = GmsDocumentScanningResult.fromActivityResultIntent(intent);

            if (resultCode == Activity.RESULT_OK && result != null) {
                handleScanningResult(result);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                pendingResult.success(new ArrayList<>());
            } else {
                pendingResult.error(TAG, "Unknown Error", null);
            }

            return true;
        }

        return false;
    }

    public void handleScanningResult(GmsDocumentScanningResult result) {
        GmsDocumentScanningResult.Pdf pdf = result.getPdf();
        List<GmsDocumentScanningResult.Page> pages = result.getPages();

        // Check if the result is a pdf and return the pdf uri
        if (pdf != null) {
            Uri pdfUri = pdf.getUri();

            List<String> pdfUris = new ArrayList<>();

            pdfUris.add(pdfUri.toString());
            pendingResult.success(pdfUris);

        }

        // Check if the result is a list of images and return the image uris
        if (pages.size() > 0) {
            List<String> imageUris = new ArrayList<>();

            for (GmsDocumentScanningResult.Page page : pages) {
                Uri imageUri = page.getImageUri();
                imageUris.add(imageUri.toString());
            }

            pendingResult.success(imageUris);
        }

    }

    private void handleScanner(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        GmsDocumentScanner scanner = instances.get(id);
        pendingResult = result;

        // Create a new scanner instance if it doesn't exist
        if (scanner == null) {
            Map<String, Object> options = call.argument("options");
            if (options == null) {
                pendingResult.error(TAG, "Invalid options", null);
                return;
            }

            GmsDocumentScannerOptions scannerOptions = parseOptions(options);
            scanner = GmsDocumentScanning.getClient(scannerOptions);
            instances.put(id, scanner);
        }

        scanner.getStartScanIntent(activity)
                .addOnSuccessListener(new OnSuccessListener<IntentSender>() {
                    @Override
                    public void onSuccess(IntentSender intentSender) {
                        try {
                            activity.startIntentSenderForResult(intentSender, START_DOCUMENT_ACTIVITY, null, 0, 0,
                                    0);
                        } catch (IntentSender.SendIntentException e) {
                            pendingResult.error(TAG, "Failed to start document scanner", null);
                        }
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        pendingResult.error(TAG, "Failed to start document scanner", null);
                    }
                });

    }

    private void addActivityResultListener(ActivityPluginBinding binding) {
        this.binding = binding;
        binding.addActivityResultListener(this);
    }

    // parse scanner options
    private GmsDocumentScannerOptions parseOptions(Map<String, Object> options) {

        boolean isGalleryImportAllowed = (boolean) options.get("isGalleryImport");

        int pageLimit = (int) options.get("pageLimit");

        int format;
        switch ((String) Objects.requireNonNull(options.get("format"))) {
            case "pdf":
                format = GmsDocumentScannerOptions.RESULT_FORMAT_PDF;
                break;
            case "jpeg":
                format = GmsDocumentScannerOptions.RESULT_FORMAT_JPEG;
                break;
            default:
                throw new IllegalArgumentException("Not a format:" + options.get("format"));
        }

        int mode;
        switch ((String) options.get("mode")) {
            case "base":
                mode = GmsDocumentScannerOptions.SCANNER_MODE_BASE;
                break;
            case "filter":
                mode = GmsDocumentScannerOptions.SCANNER_MODE_BASE_WITH_FILTER;
                break;
            case "full":
                mode = GmsDocumentScannerOptions.SCANNER_MODE_FULL;
                break;
            default:
                throw new IllegalArgumentException("Not a mode:" + options.get("mode"));
        }

        GmsDocumentScannerOptions.Builder builder = new GmsDocumentScannerOptions.Builder()
                .setGalleryImportAllowed(isGalleryImportAllowed)
                .setPageLimit(pageLimit)
                .setResultFormats(format)
                .setScannerMode(mode);
        return builder.build();
    }

    // close the scanner
    private void closeScanner(MethodCall call) {
        String id = call.argument("id");
        GmsDocumentScanner scanner = instances.get(id);
        if (scanner == null)
            return;
        binding.removeActivityResultListener(this);
        instances.remove(id);
    }
}
