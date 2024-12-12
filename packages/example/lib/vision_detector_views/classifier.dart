import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  late Interpreter _interpreter;

  // 모델 로드
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('food_resnet50.tflite');
  }

  // 이미지를 모델에 맞게 전처리하고 예측하는 메소드
  Future<String> predict(img.Image image) async {
    // 이미지를 224x224 크기로 리사이즈
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // 이미지를 전처리 (0~1 범위로 정규화)
    List<List<List<double>>> inputImage = _prepareImageForPrediction(resizedImage);

    // 예측을 위한 출력 텐서
    var output = List.filled(1, List.filled(1, 0.0));

    // 모델 실행
    _interpreter.run(inputImage, output);

    // 예측된 값이 0.5 이상이면 "Eating", 그렇지 않으면 "Not Eating"
    double prediction = output[0][0];
    return prediction > 0.5 ? 'Eating' : 'Not Eating';
  }


  // 이미지 전처리 함수: 이미지를 0~1 범위로 정규화하고 모델에 맞는 형식으로 변환
  List<List<List<double>>> _prepareImageForPrediction(img.Image image) {
    List<List<List<double>>> imageArray = List.generate(224, (i) {
      return List.generate(224, (j) {
        int pixel = image.getPixel(j, i) as int; // 픽셀 색상 얻기

        // 비트 연산을 사용하여 RGB 값을 추출
        double r = ((pixel >> 16) & 0xFF) / 255.0;  // 빨간색 채널
        double g = ((pixel >> 8) & 0xFF) / 255.0;   // 초록색 채널
        double b = (pixel & 0xFF) / 255.0;          // 파란색 채널

        return [r, g, b];
      });
    });
    return imageArray;
  }


}
