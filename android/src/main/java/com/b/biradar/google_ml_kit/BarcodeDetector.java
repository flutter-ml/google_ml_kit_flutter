package com.b.biradar.google_ml_kit;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.barcode.Barcode;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScannerOptions;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.common.InputImage;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

//Detector to scan the barcode's present in image.
//It's an abstraction over BarcodeScanner provided by ml tool kit.
public class BarcodeDetector implements ApiDetectorInterface {
    private final BarcodeScanner barcodeScanner;

    //Constructor for BarcodeDetector.
    //formatsList determines the barcode formats that the detector must scan from the image.
    public BarcodeDetector(List<Integer> formatList) {
        BarcodeScannerOptions barcodeScannerOptions;

        if (formatList.size() > 1) {
            int[] array = new int[formatList.size() - 1];
            for (int i = 0; i <= formatList.size(); i++) {
                array[i] = formatList.get(i);
            }
            barcodeScannerOptions = new BarcodeScannerOptions.Builder().setBarcodeFormats(formatList.get(0), array).build();
        } else {
            barcodeScannerOptions = new BarcodeScannerOptions.Builder().setBarcodeFormats(formatList.get(0)).build();
        }

        barcodeScanner = BarcodeScanning.getClient(barcodeScannerOptions);
    }

    //Process the image and return the barcode information.
    @Override
    public void handleDetection(InputImage inputImage, final MethodChannel.Result result) {
        if (inputImage != null) {
            Task<List<Barcode>> barcodeResult = barcodeScanner.process(inputImage)
                    .addOnSuccessListener(new OnSuccessListener<List<Barcode>>() {
                        @Override
                        public void onSuccess(List<Barcode> barcodes) {
                            List<Map<String, Object>> barcodeList = new ArrayList<>(barcodes.size());
                            for (Barcode barcode : barcodes) {

                                Map<String, Object> barcodeMap = new HashMap<>();
                                int valueType = barcode.getValueType();
                                barcodeMap.put("type", valueType);
                                barcodeMap.put("rawValue", barcode.getRawValue());
                                barcodeMap.put("displayValue", barcode.getDisplayValue());
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
                                            addressMap.put("addressLines", address.getAddressLines());
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
                                        barcodeMap.put("urlList", urls);
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
                            e.printStackTrace();
                            result.error("barcode scan error", e.toString(), null);
                        }
                    });
        }
    }

    @Override
    public void closeDetector() {
        barcodeScanner.close();
    }
}
