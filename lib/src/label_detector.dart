part of 'google_ml_kit.dart';

class ImageLabeler {
  ImageLabeler._(dynamic options)
      : assert(options != null),
        _labelerOptions = options;

  final dynamic _labelerOptions;

  bool _isOpened = false;
  bool _isClosed = false;

  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    assert(inputImage != null);
    _isOpened = true;
    print(_getImageOptions(_labelerOptions));
    final result = await GoogleMlKit.channel
        .invokeMethod('startImageLabelDetector', <String, dynamic>{
      'options': _getImageOptions(_labelerOptions),
      'imageData': inputImage._getImageData()
    });
    var imageLabels = <ImageLabel>[];
    for (dynamic data in result) {
      imageLabels.add(ImageLabel(data));
    }

    return imageLabels;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await GoogleMlKit.channel.invokeMethod('closeImageLabelDetector');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

class ImageLabelerOptions {
  final double confidenceThreshold;
  final String labelerType = 'default';

  ImageLabelerOptions({this.confidenceThreshold = 0.5});
}

class CustomImageLabelerOptions {
  final double confidenceThreshold;
  final CustomTrainedModel customModel;
  final String customModelPath;
  final String labelerType = 'custom';

  CustomImageLabelerOptions(
      {this.confidenceThreshold = 0.5,
      @required this.customModel,
      @required this.customModelPath})
      : assert(customModelPath != null),
        assert(customModel != null);
}

class AutoMlImageLabelerOptions extends CustomImageLabelerOptions {
  @override
  final String labelerType = 'autoMl';

  AutoMlImageLabelerOptions(
      CustomTrainedModel customTrainedModel, String customModelPath)
      : super(
            customModel: customTrainedModel, customModelPath: customModelPath);
}

class ImageLabel {
  ImageLabel(dynamic data)
      : confidence = data['confidence'],
        label = data['text'],
        index = data['index'];

  final double confidence;
  final String label;
  final int index;
}

Map<String, dynamic> _getImageOptions(dynamic _labelerOptions) {
  if (_labelerOptions.runtimeType == ImageLabelerOptions) {
    return <String, dynamic>{
      'labelerType': _labelerOptions.labelerType,
      'confidenceThreshold': _labelerOptions.confidenceThreshold
    };
  } else {
    return <String, dynamic>{
      'labelerType': _labelerOptions.labelerType,
      'confidenceThreshold': _labelerOptions.confidenceThreshold,
      'customModel': _labelerOptions.customModel == CustomTrainedModel.asset
          ? 'asset'
          : 'file',
      'path': _labelerOptions.customModelPath
    };
  }
}
