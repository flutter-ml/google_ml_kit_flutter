import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LanguageTranslatorView extends StatefulWidget {
  @override
  _LanguageTranslatorViewState createState() => _LanguageTranslatorViewState();
}

class _LanguageTranslatorViewState extends State<LanguageTranslatorView> {
  var _translatedText = '';
  var _controller = TextEditingController();

  TranslateLanguageModelManager _languageModelManager =
      GoogleMlKit.nlp.translateLanguageModelManager();

  Future<void> downloadModel() async {
    var result =
        await _languageModelManager.downloadModel('it', isWifiRequired: false);
    print(result);
    await _languageModelManager.downloadModel('ja', isWifiRequired: false);
  }

  Future<void> deleteModel() async {
    var result = await _languageModelManager.deleteModel('es');
    print(result);
    result = await _languageModelManager.deleteModel('en');
    print(result);
  }

  Future<void> getAvailableModels() async {
    var result = await _languageModelManager.getAvailableModels();
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Language Translator"),
        ),
        body: Column(
          children: [
            const Text('Enter text'),
            TextField(
              controller: _controller,
              maxLines: null,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(_translatedText),
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
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  onPressed: getAvailableModels,
                  child: Text('Get Available models'))
            ])
          ],
        ),
      ),
    );
  }
}
