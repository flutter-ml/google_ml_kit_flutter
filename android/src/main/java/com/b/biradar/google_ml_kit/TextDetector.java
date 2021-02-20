package com.b.biradar.google_ml_kit;

import android.graphics.Point;
import android.graphics.Rect;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.common.InputImage;
import  com.google.mlkit.vision.text.TextRecognition;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class TextDetector implements ApiDetectorInterface {
    private  final TextRecognizer textRecognizer;

    public TextDetector() {
        this.textRecognizer = TextRecognition.getClient();
    }

    @Override
    public void handleDetection(InputImage inputImage, final MethodChannel.Result result) {
        if(inputImage==null) {result.error("Input Image error",null,null); return;}

        textRecognizer.process(inputImage).addOnSuccessListener(new OnSuccessListener<Text>() {
            @Override
            public void onSuccess(Text text) {
                Map<String,Object> textResult = new HashMap<>();
                textResult.put("result",text.getText());

                List<Map<String,Object>> textBlocks = new ArrayList<>(text.getTextBlocks().size());
                for (Text.TextBlock block : text.getTextBlocks()) {
                    Map<String, Object> blockData = new HashMap<>();
                    List<Map<String,Integer>> points = new ArrayList<>();

                    blockData.put("blockText",block.getText());
                    if(block.getCornerPoints()!=null){
                        addPoints(block.getCornerPoints(),points);
                    }
                    blockData.put("points",points);

                    if(block.getBoundingBox()!=null)
                        blockData.put("rect",getBoundingPoints(block.getBoundingBox()));


                    List<Map<String,Object>> textLines = new ArrayList<>();
                    for (Text.Line line : block.getLines()) {
                        Map<String, Object> textLine = new HashMap<>();
                        List<Map<String,Integer>> linePoints = new ArrayList<>();
                        List<Map<String,Object>> textElements = new ArrayList<>();

                        if(line.getCornerPoints()!=null) addPoints(line.getCornerPoints(),linePoints);
                        if(line.getBoundingBox()!=null){
                            textLine.put("rect",getBoundingPoints(line.getBoundingBox()));
                        }

                        for (Text.Element element : line.getElements()) {
                            Map<String,Object> temp = new HashMap<>();
                            List<Map<String,Integer>> elementPoints = new ArrayList<>();
                            if(element.getCornerPoints()!=null) addPoints(element.getCornerPoints(),elementPoints);
                            if(element.getBoundingBox()!=null) temp.put("elementFrame",getBoundingPoints(element.getBoundingBox()));

                            temp.put("elementText",element.getText());
                            temp.put("elementPoints",elementPoints);
                            textElements.add(temp);
                        }
                        textLine.put("lineText",line.getText());
                        textLine.put("textElements",textElements);
                        textLines.add(textLine);
                    }
                    blockData.put("textLines",textLines);
                    textBlocks.add(blockData);
            }
                textResult.put("block",textBlocks);
                result.success(textResult);
        }}).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("Text Recognition Error",e.toString());
                result.error("Text Recognition Error",e.toString(),null);
            }
        });
    }

    @Override
    public void closeDetector() throws IOException {
        textRecognizer.close();
    }

    private  void addPoints(Point[] pointList,List<Map<String,Integer>> points){
        for(Point point : pointList){
            Map<String, Integer> p = new HashMap<>();
            p.put("x",point.x);
            p.put("y",point.y);
            points.add(p);
        }
    }

    private  Map<String,Integer> getBoundingPoints(Rect rect){
        Map<String, Integer> frame = new HashMap<>();
        frame.put("left",rect.left);
        frame.put("right",rect.right);
        frame.put("top",rect.top);
        frame.put("bottom",rect.bottom);
        return  frame;
    }
}
