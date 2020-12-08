part of 'google_ml_kit.dart';

//Class to process the text that is being written on screen
class DigitalInkRecogniser {
  DigitalInkRecogniser._();

  bool _isOpened = false;
  bool _isClosed = false;

  ///Function that invokes the method to read the text written on screen
  ///It takes modelTag that refers to language that is being processed
  ///Note that modelTag should follow [BCP 47] guidelines of identifying
  ///language visit this site [https://tools.ietf.org/html/bcp47] to know
  ///It takes [List<Offset>] which refers to the points being written on screen.
  Future<String> readText(List<Offset> points,String modelTag) async {
    assert(points != null);
    _isOpened = true;
    List<Map<String, dynamic>> pointsList = <Map<String, dynamic>>[];
    for (Offset point in points) {
      if(point!=null){
        pointsList.add(<String, dynamic>{'x': point.dx, 'y': point.dy});
      }
    }
    String result = await GoogleMlKit.channel.invokeMethod(
        'startMlDigitalInkRecognizer',
        <String, dynamic>{'points': pointsList, 'modelTag': modelTag});
    _isClosed = false;
    return result;
  }

  //Call this method to close
  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await GoogleMlKit.channel.invokeMethod('closeMlDigitalInkRecognizer');
      _isOpened = false;
      _isClosed = true;
    }
  }
}

class LanguageModelManager {
  LanguageModelManager._();

  Future<String> isModelDownloaded(String modelTag) async {
    assert(modelTag != null);
    final result = await GoogleMlKit.channel.invokeMethod('manageInkModels',
        <String, dynamic>{'task': 'check', 'modelTag': modelTag});

    return result.toString();
  }

  Future<String> downloadModel(String modelTag) async {
    assert(modelTag != null);

    final result = await GoogleMlKit.channel.invokeMethod('manageInkModels',
        <String, dynamic>{'task': 'download', 'modelTag': modelTag});

    return result.toString();
  }

  Future<String> deleteModel(String modelTag) async {
    assert(modelTag != null);

    final result = await GoogleMlKit.channel.invokeMethod('manageInkModels',
        <String, dynamic>{'task': 'delete', 'modelTag': modelTag});

    return result.toString();
  }
}
