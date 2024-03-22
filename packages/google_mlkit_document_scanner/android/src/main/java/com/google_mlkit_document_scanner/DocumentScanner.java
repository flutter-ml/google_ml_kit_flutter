package com.google_mlkit_document_scanner;

import androidx.annotation.NonNull;
import android.app.Activity;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.activity.result.contract.ActivityResultContracts.StartIntentSenderForResult;
import androidx.activity.result.IntentSenderRequest;

import android.content.Context;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.google.mlkit.common.MlKitException;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning;
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult;

public class DocumentScanner implements MethodChannel.MethodCallHandler {
  private static final String START = "vision#startDocumentScanner";
  private static final String CLOSE = "vision#closeDocumentScanner";

  private final Context context;
  private final Map<String, com.google.mlkit.vision.documentscanner.GmsDocumentScanner> instances = new HashMap<>();

  public DocumentScanner(Context context) {
    this.context = context;
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
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleScanner(MethodCall call, final MethodChannel.Result result) {
    String id = call.argument("id");
    com.google.mlkit.vision.documentscanner.GmsDocumentScanner scanner = instances.get(id);
    if (scanner == null) {
      Map<String, Object> options = call.argument("options");
      if (options == null) {
        result.error("DocumentScannerError", "Invalid options", null);
        return;
      }

      GmsDocumentScannerOptions scannerOptions = parseOptions(options);
      scanner = GmsDocumentScanning.getClient(scannerOptions);
      instances.put(id, scanner);
    }

    // scanner.getStartScanIntent(activity).addOnSuccessListener(
    // result.error("DocumentScannerError", "Error", null)).addOnFailureListener(
    // e -> result.error("DocumentScannerError", e.toString(), null));
    result.error("DocumentScannerError", "Through", null);
  }

  // parse scanner options
  private GmsDocumentScannerOptions parseOptions(Map<String, Object> options) {

    boolean isGalleryImportAllowed = (boolean) options.get("isGalleryImport");

    int pageLimit = (int) options.get("pageLimit");

    int format;
    switch ((String) options.get("format")) {
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
    com.google.mlkit.vision.documentscanner.GmsDocumentScanner scanner = instances.get(id);
    if (scanner == null)
      return;
    // scanner.close();
    instances.remove(id);
  }

}
