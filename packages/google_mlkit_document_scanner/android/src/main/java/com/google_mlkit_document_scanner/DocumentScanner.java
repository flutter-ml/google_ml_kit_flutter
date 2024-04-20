package com.google_mlkit_document_scanner;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentSender;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanner;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning;
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class DocumentScanner implements MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {
    private static final String START = "vision#startDocumentScanner";
    private static final String CLOSE = "vision#closeDocumentScanner";
    private static final String TAG = "DocumentScanner";
    private final Map<String, GmsDocumentScanner> instances = new HashMap<>();
    private final ActivityPluginBinding binding;
    private MethodChannel.Result pendingResult = null;
    final private int START_DOCUMENT_ACTIVITY = 0x362738;

    public DocumentScanner(ActivityPluginBinding binding) {
        this.binding = binding;
        binding.addActivityResultListener(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case START:
                handleScanner(call, result);
                break;
            case CLOSE:
                closeScanner(call);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void handleScanner(MethodCall call, final MethodChannel.Result result) {
        String id = call.argument("id");
        GmsDocumentScanner scanner = instances.get(id);
        pendingResult = result;

        // Create a new scanner instance if it doesn't exist
        if (scanner == null) {
            Map<String, Object> options = call.argument("options");
            if (options == null) {
                result.error(TAG, "Invalid options", null);
                return;
            }
            GmsDocumentScannerOptions scannerOptions = parseOptions(options);
            scanner = GmsDocumentScanning.getClient(scannerOptions);
            instances.put(id, scanner);
        }

        Activity activity = binding.getActivity();
        scanner.getStartScanIntent(activity).addOnSuccessListener(new OnSuccessListener<IntentSender>() {
            @Override
            public void onSuccess(IntentSender intentSender) {
                try {
                    activity.startIntentSenderForResult(intentSender, START_DOCUMENT_ACTIVITY, null, 0, 0, 0);
                } catch (IntentSender.SendIntentException e) {
                    result.error(TAG, "Failed to start document scanner", null);
                }
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                result.error(TAG, "Failed to start document scanner", null);
            }
        });
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
        GmsDocumentScannerOptions.Builder builder = new GmsDocumentScannerOptions.Builder().setGalleryImportAllowed(isGalleryImportAllowed).setPageLimit(pageLimit).setResultFormats(format).setScannerMode(mode);
        return builder.build();
    }

    private void closeScanner(MethodCall call) {
        String id = call.argument("id");
        GmsDocumentScanner scanner = instances.get(id);
        if (scanner == null) return;
        instances.remove(id);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent intent) {
        if (requestCode == START_DOCUMENT_ACTIVITY) {
            if (resultCode == Activity.RESULT_OK) {
                GmsDocumentScanningResult result = GmsDocumentScanningResult.fromActivityResultIntent(intent);
                if (result != null) {
                    handleScanningResult(result);
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                pendingResult.error(TAG, "Operation cancelled", null);
            } else {
                pendingResult.error(TAG, "Unknown Error", null);
            }
            return true;
        }
        return false;
    }

    private void handleScanningResult(GmsDocumentScanningResult result) {
        Map<String, Object> resultMap = new HashMap<>();

        // Check if the result has a pdf
        GmsDocumentScanningResult.Pdf pdf = result.getPdf();
        if (pdf != null) {
            Map<String, Object> pdfMap = new HashMap<>();
            pdfMap.put("pageCount", pdf.getPageCount());
            pdfMap.put("uri", pdf.getUri().getPath());
            resultMap.put("pdf", pdfMap);
        } else {
            resultMap.put("pdf", null);
        }

        // Check if the result has a list of pages
        List<GmsDocumentScanningResult.Page> pages = result.getPages();
        if (pages != null && !pages.isEmpty()) {
            List<String> imageUris = new ArrayList<>();
            for (GmsDocumentScanningResult.Page page : pages) {
                imageUris.add(page.getImageUri().getPath());
            }
            resultMap.put("images", imageUris);
        } else {
            resultMap.put("images", null);
        }

        pendingResult.success(resultMap);
    }
}
