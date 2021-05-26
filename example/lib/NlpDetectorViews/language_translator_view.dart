import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LanguageTranslatorView extends StatefulWidget {
  @override
  _LanguageTranslatorViewState createState() => _LanguageTranslatorViewState();
}

class _LanguageTranslatorViewState extends State<LanguageTranslatorView> {
  var _translatedText = '';
  var _controller = TextEditingController();

  final _languageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();

  final _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
      sourceLanguage: TranslateLanguage.ENGLISH,
      targetLanguage: TranslateLanguage.SPANISH);

  @override
  void dispose() {
    _onDeviceTranslator.close();
    super.dispose();
  }

  Future<void> downloadModel() async {
    var result = await _languageModelManager.downloadModel('en');
    print('Model downloaded: $result');
    result = await _languageModelManager.downloadModel('es');
    print('Model downloaded: $result');
  }

  Future<void> deleteModel() async {
    var result = await _languageModelManager.deleteModel('en');
    print('Model deleted: $result');
    result = await _languageModelManager.deleteModel('es');
    print('Model deleted: $result');
  }

  Future<void> getAvailableModels() async {
    var result = await _languageModelManager.getAvailableModels();
    print('Available models: $result');
  }

  Future<void> isModelDownloaded() async {
    var result = await _languageModelManager.isModelDownloaded('es');
    print('Is model downloaded: $result');
    result = await _languageModelManager.isModelDownloaded('es');
    print('Is model downloaded: $result');
  }

  Future<void> translateText() async {
    var result = await _onDeviceTranslator.translateText(_controller.text);
    setState(() {
      _translatedText = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Language Translator"),
        ),
        body: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Center(child: const Text('Enter text (English)')),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 2,
                )),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(border: InputBorder.none),
                  maxLines: null,
                ),
              ),
            ),
            const Center(child: const Text('Translated Text (Spanish)')),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.3,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border: Border.all(
                    width: 2,
                  )),
                  child: Text(_translatedText)),
            ),
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(onPressed: translateText, child: Text('Translate'))
            ]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: downloadModel, child: Text('Download Model')),
                ElevatedButton(
                    onPressed: deleteModel, child: Text('Delete Model')),
              ],
            ),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton(
                  onPressed: getAvailableModels,
                  child: Text('Get Available models')),
              ElevatedButton(
                  onPressed: isModelDownloaded, child: Text('Check download'))
            ])
          ],
        ),
      ),
    );
  }
}
