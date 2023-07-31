package com.google_mlkit_barcode_scanning;

import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.mlkit.vision.barcode.common.Barcode;
import com.google.mlkit.vision.barcode.BarcodeScannerOptions;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.common.InputImage;
import com.google_mlkit_commons.InputImageConverter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BarcodeScanner implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startBarcodeScanner";
    private static final String CLOSE = "vision#closeBarcodeScanner";

    private final Context context;
    private final Map<String, com.google.mlkit.vision.barcode.BarcodeScanner> instances = new HashMap<>();

    public BarcodeScanner(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case START:
                handleDetection(call, result);
                break;
            case CLOSE:
                closeDetector(call);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private com.google.mlkit.vision.barcode.BarcodeScanner initialize(MethodCall call) {
        List<Integer> formatList = call.argument("formats");
        BarcodeScannerOptions barcodeScannerOptions;
        if (formatList.size() > 1) {
            int[] array = new int[formatList.size()];
            for (int i = 1; i < formatList.size(); i++) {
                array[i] = formatList.get(i);
            }
            barcodeScannerOptions = new BarcodeScannerOptions.Builder().setBarcodeFormats(formatList.get(0), array).build();
        } else {
            barcodeScannerOptions = new BarcodeScannerOptions.Builder().setBarcodeFormats(formatList.get(0)).build();
        }
        return BarcodeScanning.getClient(barcodeScannerOptions);
    }

    private void handleDetection(MethodCall call, final MethodChannel.Result result) {
        Map<String, Object> imageData = call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;

        String id = call.argument("id");
        com.google.mlkit.vision.barcode.BarcodeScanner barcodeScanner = instances.get(id);
        if (barcodeScanner == null) {
            barcodeScanner = initialize(call);
            instances.put(id, barcodeScanner);
        }

        barcodeScanner.process(inputImage)
                .addOnSuccessListener(barcodes -> {
                    List<Map<String, Object>> barcodeList = new ArrayList<>(barcodes.size());
                    for (Barcode barcode : barcodes) {

                        Map<String, Object> barcodeMap = new HashMap<>();
                        int valueType = barcode.getValueType();
                        barcodeMap.put("type", valueType);
                        barcodeMap.put("format", barcode.getFormat());
                        barcodeMap.put("rawValue", barcode.getRawValue());
                        barcodeMap.put("rawBytes", barcode.getRawBytes());
                        barcodeMap.put("displayValue", barcode.getDisplayValue());
                        barcodeMap.put("rect", getBoundingPoints(barcode.getBoundingBox()));
                        Point[] cornerPoints = barcode.getCornerPoints();
                        List<Map<String, Integer>> points = new ArrayList<>();
                        addPoints(cornerPoints, points);
                        barcodeMap.put("points", points);
                        switch (valueType) {
                            case Barcode.TYPE_UNKNOWN:
                            case Barcode.TYPE_ISBN:
                            case Barcode.TYPE_PRODUCT:
                            case Barcode.TYPE_TEXT:
                                break;
                            case Barcode.TYPE_WIFI:
                                barcodeMap.put("ssid", barcode.getWifi().getSsid());
                                barcodeMap.put("password", barcode.getWifi().getPassword());
                                barcodeMap.put("encryption", barcode.getWifi().getEncryptionType());
                                break;
                            case Barcode.TYPE_URL:
                                barcodeMap.put("title", barcode.getUrl().getTitle());
                                barcodeMap.put("url", barcode.getUrl().getUrl());
                                break;
                            case Barcode.TYPE_EMAIL:
                                barcodeMap.put("address", barcode.getEmail().getAddress());
                                barcodeMap.put("body", barcode.getEmail().getBody());
                                barcodeMap.put("subject", barcode.getEmail().getSubject());
                                barcodeMap.put("emailType", barcode.getEmail().getType());
                                break;
                            case Barcode.TYPE_PHONE:
                                barcodeMap.put("number", barcode.getPhone().getNumber());
                                barcodeMap.put("phoneType", barcode.getPhone().getType());
                                break;
                            case Barcode.TYPE_SMS:
                                barcodeMap.put("message", barcode.getSms().getMessage());
                                barcodeMap.put("number", barcode.getSms().getPhoneNumber());
                                break;
                            case Barcode.TYPE_GEO:
                                barcodeMap.put("latitude", barcode.getGeoPoint().getLat());
                                barcodeMap.put("longitude", barcode.getGeoPoint().getLng());
                                break;
                            case Barcode.TYPE_DRIVER_LICENSE:
                                barcodeMap.put("addressCity", barcode.getDriverLicense().getAddressCity());
                                barcodeMap.put("addressState", barcode.getDriverLicense().getAddressState());
                                barcodeMap.put("addressZip", barcode.getDriverLicense().getAddressZip());
                                barcodeMap.put("addressStreet", barcode.getDriverLicense().getAddressStreet());
                                barcodeMap.put("issueDate", barcode.getDriverLicense().getIssueDate());
                                barcodeMap.put("birthDate", barcode.getDriverLicense().getBirthDate());
                                barcodeMap.put("expiryDate", barcode.getDriverLicense().getExpiryDate());
                                barcodeMap.put("gender", barcode.getDriverLicense().getGender());
                                barcodeMap.put("licenseNumber", barcode.getDriverLicense().getLicenseNumber());
                                barcodeMap.put("firstName", barcode.getDriverLicense().getFirstName());
                                barcodeMap.put("lastName", barcode.getDriverLicense().getLastName());
                                barcodeMap.put("country", barcode.getDriverLicense().getIssuingCountry());
                                break;
                            case Barcode.TYPE_CONTACT_INFO:
                                barcodeMap.put("firstName", barcode.getContactInfo().getName().getFirst());
                                barcodeMap.put("lastName", barcode.getContactInfo().getName().getLast());
                                barcodeMap.put("formattedName", barcode.getContactInfo().getName().getFormattedName());
                                barcodeMap.put("organization", barcode.getContactInfo().getOrganization());
                                List<Map<String, Object>> queries = new ArrayList<>();
                                for (Barcode.Address address : barcode.getContactInfo().getAddresses()) {
                                    Map<String, Object> addressMap = new HashMap<>();
                                    addressMap.put("addressType", address.getType());
                                    List<String> addressLines = new ArrayList<>();
                                    Collections.addAll(addressLines, address.getAddressLines());
                                    addressMap.put("addressLines", addressLines);
                                    queries.add(addressMap);
                                }
                                barcodeMap.put("addresses", queries);
                                queries = new ArrayList<>();
                                for (Barcode.Phone phone : barcode.getContactInfo().getPhones()) {
                                    Map<String, Object> phoneMap = new HashMap<>();
                                    phoneMap.put("number", phone.getNumber());
                                    phoneMap.put("phoneType", phone.getType());
                                    queries.add(phoneMap);
                                }
                                barcodeMap.put("phones", queries);
                                queries = new ArrayList<>();
                                for (Barcode.Email email : barcode.getContactInfo().getEmails()) {
                                    Map<String, Object> emailMap = new HashMap<>();
                                    emailMap.put("address", email.getAddress());
                                    emailMap.put("body", email.getBody());
                                    emailMap.put("subject", email.getSubject());
                                    emailMap.put("emailType", email.getType());
                                    queries.add(emailMap);
                                }
                                barcodeMap.put("emails", queries);
                                List<String> urls = new ArrayList<>(barcode.getContactInfo().getUrls());
                                barcodeMap.put("urls", urls);
                                break;
                            case Barcode.TYPE_CALENDAR_EVENT:
                                barcodeMap.put("description", barcode.getCalendarEvent().getDescription());
                                barcodeMap.put("location", barcode.getCalendarEvent().getLocation());
                                barcodeMap.put("status", barcode.getCalendarEvent().getStatus());
                                barcodeMap.put("summary", barcode.getCalendarEvent().getSummary());
                                barcodeMap.put("organizer", barcode.getCalendarEvent().getOrganizer());
                                barcodeMap.put("start", barcode.getCalendarEvent().getStart().getRawValue());
                                barcodeMap.put("end", barcode.getCalendarEvent().getEnd().getRawValue());
                                break;
                        }
                        barcodeList.add(barcodeMap);
                    }
                    result.success(barcodeList);
                })
                .addOnFailureListener(e -> result.error("BarcodeDetectorError", e.toString(), null));
    }

    private void addPoints(Point[] cornerPoints, List<Map<String, Integer>> points) {
        for (Point point : cornerPoints) {
            Map<String, Integer> p = new HashMap<>();
            p.put("x", point.x);
            p.put("y", point.y);
            points.add(p);
        }
    }

    private Map<String, Integer> getBoundingPoints(@Nullable Rect rect) {
        Map<String, Integer> frame = new HashMap<>();
        if (rect == null) return frame;
        frame.put("left", rect.left);
        frame.put("right", rect.right);
        frame.put("top", rect.top);
        frame.put("bottom", rect.bottom);
        return frame;
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.vision.barcode.BarcodeScanner barcodeScanner = instances.get(id);
        if (barcodeScanner == null) return;
        barcodeScanner.close();
        instances.remove(id);
    }
}
