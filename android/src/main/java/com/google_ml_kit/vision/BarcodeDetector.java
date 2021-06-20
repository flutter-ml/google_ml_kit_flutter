package com.google_ml_kit.vision;

import android.content.Context;
import android.graphics.Rect;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.barcode.Barcode;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScannerOptions;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.common.InputImage;
import com.google_ml_kit.ApiDetectorInterface;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

//Detector to scan the barcode present in image.
//It's an abstraction over BarcodeScanner provided by ml tool kit.
public class BarcodeDetector implements ApiDetectorInterface {
    private static final String START = "vision#startBarcodeScanner";
    private static final String CLOSE = "vision#closeBarcodeScanner";

    private final Context context;
    private BarcodeScanner barcodeScanner;

    public BarcodeDetector(Context context) {
        this.context = context;
    }

    @Override
    public List<String> getMethodsKeys() {
        return new ArrayList<>(
                Arrays.asList(START,
                        CLOSE));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (method.equals(START)) {
            handleDetection(call, result);
        } else if (method.equals(CLOSE)) {
            closeDetector();
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void handleDetection(MethodCall call, final MethodChannel.Result result) {
        Map<String, Object> imageData = (Map<String, Object>) call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;

        List<Integer> formatList = (List<Integer>) call.argument("formats");
        if (formatList == null)  {
            result.error("BarcodeDetectorError", "Invalid barcode formats", null);
            return;
        }

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

        barcodeScanner = BarcodeScanning.getClient(barcodeScannerOptions);
        barcodeScanner.process(inputImage)
                .addOnSuccessListener(new OnSuccessListener<List<Barcode>>() {
                    @Override
                    public void onSuccess(List<Barcode> barcodes) {
                        List<Map<String, Object>> barcodeList = new ArrayList<>(barcodes.size());
                        for (Barcode barcode : barcodes) {

                            Map<String, Object> barcodeMap = new HashMap<>();
                            int valueType = barcode.getValueType();
                            barcodeMap.put("type", valueType);
                            barcodeMap.put("format", barcode.getFormat());
                            barcodeMap.put("rawValue", barcode.getRawValue());
                            barcodeMap.put("rawBytes", barcode.getRawBytes());
                            barcodeMap.put("displayValue", barcode.getDisplayValue());
                            Rect bb = barcode.getBoundingBox();
                            if (bb != null) {
                                barcodeMap.put("boundingBoxBottom", bb.bottom);
                                barcodeMap.put("boundingBoxLeft", bb.left);
                                barcodeMap.put("boundingBoxRight", bb.right);
                                barcodeMap.put("boundingBoxTop", bb.top);
                            }
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
                                    barcodeMap.put("organisation", barcode.getContactInfo().getOrganization());
                                    List<Map<String, Object>> queries = new ArrayList<>();
                                    for (Barcode.Address address : barcode.getContactInfo().getAddresses()) {
                                        Map<String, Object> addressMap = new HashMap<>();
                                        addressMap.put("addressType", address.getType());

                                        List<String> addressLines = new ArrayList<>();
                                        for(String addressLine : address.getAddressLines()){
                                            addressLines.add(addressLine);
                                        }
                                        addressMap.put("addressLines",addressLines);

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
                                    barcodeMap.put("contactNumbers", queries);
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
                                    barcodeMap.put("organiser", barcode.getCalendarEvent().getOrganizer());
                                    barcodeMap.put("startRawValue", barcode.getCalendarEvent().getStart().getRawValue());
                                    if (barcode.getCalendarEvent().getStart() != null) {
                                        barcodeMap.put("startDate", barcode.getCalendarEvent().getStart().getDay());
                                        barcodeMap.put("startHour", barcode.getCalendarEvent().getStart().getHours());
                                    }
                                    barcodeMap.put("endRawValue", barcode.getCalendarEvent().getEnd().getRawValue());
                                    if (barcode.getCalendarEvent().getStart() != null) {
                                        barcodeMap.put("endDate", barcode.getCalendarEvent().getEnd().getDay());
                                        barcodeMap.put("endHour", barcode.getCalendarEvent().getEnd().getHours());
                                    }
                                    break;
                            }
                            barcodeList.add(barcodeMap);
                        }
                        result.success(barcodeList);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        result.error("BarcodeDetectorError", e.toString(), null);
                    }
                });
    }


    private void closeDetector() {
        barcodeScanner.close();
    }
}
