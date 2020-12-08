# Digital Ink Recognizer

## Usage
**Create an Instance of `DigitalInkRecogniser`**
```
 DigitalInkRecogniser _digitalInkRecogniser =
      GoogleMlKit.instance.digitalInkRecogniser();
```
**Call `readText(List<Offset> pointList,String modelTag)` to read.It returns a String result**

*Note before calling readText() make sure to download your language model. Read **Managing model** section to know about this*

```
final text = await _digitalInkRecogniser.readText(_points,'en-US');

//_points is a list containing offsets and 'en-US' is a BCP-47 language tag
```
see [all the languages supported by google's base model](https://developers.google.com/ml-kit/vision/digital-ink-recognition/base-models)

**To know more about [BCP-47 guidelines](https://tools.ietf.org/html/bcp47)**
****
## Managing Models

**First create an instance of `LanguageModelManager`**

```
DigitalInkRecogniser _digitalInkRecogniser =
      GoogleMlKit.instance.digitalInkRecogniser();
```
**To check whether model is downloaded**
```
final verificationResult =
        await _languageModelManager.isModelDownloaded(modelTag);
```
This results in three possibilities
- exists -> implies model is already downloaded
- not exists -> implies model is not downloaded
- error -> Failed to verify

**To download a language model**
```
final downloadResult =
        await _languageModelManager.downloadModel(modeltag);
```
This results in three possibilities
- exists -> implies model is already downloaded
- success -> implies model downloaded successfuly
- error -> Failed to download model

**To delete a language model**
```
final deleteResult =
        await _languageModelManager.downloadModel(modeltag);
```
This results in three possibilities
- not exists -> implies model is not downloaded
- success -> implies model deleted successfuly
- error -> Failed to delete model

### To improve text recognition accuracy read -> [this](https://developers.google.com/ml-kit/vision/digital-ink-recognition/android#tips-to-improve-text-recognition-accuracy)

#### A basic [example](example/lib/DetectorViews/pose_detector_view.dart) implementing the api


## License
[MIT](https://choosealicense.com/licenses/mit/)