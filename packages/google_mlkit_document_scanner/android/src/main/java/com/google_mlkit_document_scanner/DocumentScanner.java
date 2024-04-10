package com.google_mlkit_document_scanner;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentSender;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class DocumentScanner implements MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private static final String START = "vision#startDocumentScanner";
  private static final String CLOSE = "vision#closeDocumentScanner";

  private Activity activity;

  private ActivityPluginBinding binding;

  private static final String TAG = "MyActivity";

  private final Map<String, com.google.mlkit.vision.documentscanner.GmsDocumentScanner> instances = new HashMap<>();

  final private int START_DOCUMENT_ACTIVITY = 0x362738;

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

  @Override 
  public void onAttachedToActivity( ActivityPluginBinding pluginBinding){
    Log.w(TAG, "Attached To Activity");
    activity = pluginBinding.getActivity();
    binding = pluginBinding;
    binding.addActivityResultListener(this);
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent intent) {
    if(requestCode == START_DOCUMENT_ACTIVITY){
      GmsDocumentScanningResult result =
              GmsDocumentScanningResult.fromActivityResultIntent(intent);
      if(resultCode == Activity.RESULT_OK && result != null){
        if(result.getPdf() !=null){
          GmsDocumentScanningResult.Pdf pdf = result.getPdf();
          Uri pdfUri = pdf.getUri();
          int pageCount = pdf.getPageCount();
          Log.i(TAG, "Success: PdfUri " + pdfUri.toString());
        }
        if(result.getPages() != null){
          List<GmsDocumentScanningResult.Page> pages = result.getPages();
          for(GmsDocumentScanningResult.Page page : pages){
            Uri imageUri = page.getImageUri();
            Log.i(TAG, "Success: ImageUri " + imageUri.toString());
          }
        }
      }else if(resultCode == Activity.RESULT_CANCELED){
        Log.i(TAG, "Canceled");
      }else{
        Log.i(TAG, "Unknown Error");
      }

    }
    return false;
  }

  private void handleScanner(MethodCall call, final MethodChannel.Result result) {
    Log.w(TAG, "Here second");
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

    // Ensure activity is available before proceeding
    if (activity == null) {
      Log.w(TAG, "Activity is null 1, cannot start scanning");
      result.error("DocumentScannerError", "Activity is not available", null);
      return;
    }
    scanner.getStartScanIntent(activity).addOnSuccessListener(new OnSuccessListener<IntentSender>() {
      @Override
      public void onSuccess(IntentSender intentSender) {
          try{
            if(activity == null){
              Log.w(TAG, "Activity is null 2, cannot start scanning");
              result.error("DocumentScannerError", "Activity is not available", null);
            }else{
              activity.startIntentSenderForResult(intentSender, START_DOCUMENT_ACTIVITY, null, 0, 0, 0);

            }
          }catch(IntentSender.SendIntentException e){
            Log.i(TAG, "Error: Failed to start document scanner " + e);
          }
      }
    })
      .addOnFailureListener(new OnFailureListener() {
        @Override
        public void onFailure(@NonNull Exception e) {
          Log.i(TAG, "Error: Failed to start document scanner " + e);
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
    binding.removeActivityResultListener(this);
    instances.remove(id);
  }


  @Override 
  public void onDetachedFromActivityForConfigChanges(){
    Log.w(TAG, "onDetachedFromActivityForConfigChanges");

  }

  @Override 
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding){
    Log.w(TAG, "onReattachedToActivityForConfigChanges");
    binding.addActivityResultListener(this);
  }
  @Override 
  public void onDetachedFromActivity(){
    Log.w(TAG, "onDetachedFromActivity");
    binding.removeActivityResultListener(this);
  }

}
