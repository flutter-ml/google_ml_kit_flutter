import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../vision_detector_views/toast.dart';

class LanguageTranslatorView extends StatefulWidget {
  @override
  _LanguageTranslatorViewState createState() => _LanguageTranslatorViewState();
}

class _LanguageTranslatorViewState extends State<LanguageTranslatorView> {
  String? _translatedText;
  final _controller = TextEditingController();
  final _modelManager = OnDeviceTranslatorModelManager();
  static final _sourceLanguage = TranslateLanguage.english;
  static final _targetLanguage = TranslateLanguage.spanish;
  final _onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage, targetLanguage: _targetLanguage);

  @override
  void dispose() {
    _onDeviceTranslator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('On-device Translation'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              SizedBox(height: 30),
              Center(child: Text('Enter text (${_sourceLanguage.name})')),
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
              Center(child: Text('Translated Text (${_targetLanguage.name})')),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        border: Border.all(
                      width: 2,
                    )),
                    child: Text(_translatedText ?? '')),
              ),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                    onPressed: _translateText, child: Text('Translate'))
              ]),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: _downloadModel, child: Text('Download Model')),
                  ElevatedButton(
                      onPressed: _deleteModel, child: Text('Delete Model')),
                ],
              ),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                ElevatedButton(
                    onPressed: _isModelDownloaded,
                    child: Text('Check download'))
              ])
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadModel() async {
    // download model will always return false,
    // model is downloaded if needed when translating
    Toast().show(
        'Downloading model (${_targetLanguage.name})...',
        _modelManager.downloadModel(_targetLanguage.bcpCode).then((value) =>
            value ? 'success' : 'error, model is downloaded when translating.'),
        context,
        this);
  }

  Future<void> _deleteModel() async {
    Toast().show(
        'Deleting model (${_targetLanguage.name})...',
        _modelManager
            .deleteModel(_targetLanguage.bcpCode)
            .then((value) => value ? 'success' : 'error'),
        context,
        this);
  }

  Future<void> _isModelDownloaded() async {
    Toast().show(
        'Checking if model (${_targetLanguage.name}) is downloaded...',
        _modelManager
            .isModelDownloaded(_targetLanguage.bcpCode)
            .then((value) => value ? 'exists' : 'not exists'),
        context,
        this);
  }

  Future<void> _translateText() async {
    FocusScope.of(context).unfocus();
    final result = await _onDeviceTranslator.translateText(_controller.text);
    setState(() {
      _translatedText = result;
    });
  }
}
