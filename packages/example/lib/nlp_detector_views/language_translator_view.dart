import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../activity_indicator/activity_indicator.dart';

class LanguageTranslatorView extends StatefulWidget {
  @override
  State<LanguageTranslatorView> createState() => _LanguageTranslatorViewState();
}

class _LanguageTranslatorViewState extends State<LanguageTranslatorView> {
  String? _translatedText;
  final _controller = TextEditingController();
  final _modelManager = OnDeviceTranslatorModelManager();
  var _sourceLanguage = TranslateLanguage.english;
  var _targetLanguage = TranslateLanguage.spanish;
  var _onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.spanish);

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
              Center(
                  child: Text('Enter text (source: ${_sourceLanguage.name})')),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
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
                    )),
                    SizedBox(width: 20),
                    _buildDropdown(false),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Center(
                  child: Text(
                      'Translated Text (target: ${_targetLanguage.name})')),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width / 1.3,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 2,
                          )),
                          child: Text(_translatedText ?? '')),
                    ),
                    SizedBox(width: 20),
                    _buildDropdown(true),
                  ],
                ),
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
                      onPressed: _downloadSourceModel,
                      child: Text('Download Source Model')),
                  ElevatedButton(
                      onPressed: _downloadTargetModel,
                      child: Text('Download Target Model')),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: _deleteSourceModel,
                      child: Text('Delete Source Model')),
                  ElevatedButton(
                      onPressed: _deleteTargetModel,
                      child: Text('Delete Target Model')),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: _isSourceModelDownloaded,
                      child: Text('Source Downloaded?')),
                  ElevatedButton(
                      onPressed: _isTargetModelDownloaded,
                      child: Text('Target Downloaded?')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isTarget) => DropdownButton<String>(
        value: (isTarget ? _targetLanguage : _sourceLanguage).bcpCode,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (String? code) {
          if (code != null) {
            final lang = BCP47Code.fromRawValue(code);
            if (lang != null) {
              setState(() {
                isTarget ? _targetLanguage = lang : _sourceLanguage = lang;
                _onDeviceTranslator = OnDeviceTranslator(
                    sourceLanguage: _sourceLanguage,
                    targetLanguage: _targetLanguage);
              });
            }
          }
        },
        items: TranslateLanguage.values.map<DropdownMenuItem<String>>((lang) {
          return DropdownMenuItem<String>(
            value: lang.bcpCode,
            child: Text(lang.name),
          );
        }).toList(),
      );

  Future<void> _downloadSourceModel() async {
    Toast().show(
        'Downloading model (${_sourceLanguage.name})...',
        _modelManager
            .downloadModel(_sourceLanguage.bcpCode)
            .then((value) => value ? 'success' : 'failed'),
        context,
        this);
  }

  Future<void> _downloadTargetModel() async {
    Toast().show(
        'Downloading model (${_targetLanguage.name})...',
        _modelManager
            .downloadModel(_targetLanguage.bcpCode)
            .then((value) => value ? 'success' : 'failed'),
        context,
        this);
  }

  Future<void> _deleteSourceModel() async {
    Toast().show(
        'Deleting model (${_sourceLanguage.name})...',
        _modelManager
            .deleteModel(_sourceLanguage.bcpCode)
            .then((value) => value ? 'success' : 'failed'),
        context,
        this);
  }

  Future<void> _deleteTargetModel() async {
    Toast().show(
        'Deleting model (${_targetLanguage.name})...',
        _modelManager
            .deleteModel(_targetLanguage.bcpCode)
            .then((value) => value ? 'success' : 'failed'),
        context,
        this);
  }

  Future<void> _isSourceModelDownloaded() async {
    Toast().show(
        'Checking if model (${_sourceLanguage.name}) is downloaded...',
        _modelManager
            .isModelDownloaded(_sourceLanguage.bcpCode)
            .then((value) => value ? 'downloaded' : 'not downloaded'),
        context,
        this);
  }

  Future<void> _isTargetModelDownloaded() async {
    Toast().show(
        'Checking if model (${_targetLanguage.name}) is downloaded...',
        _modelManager
            .isModelDownloaded(_targetLanguage.bcpCode)
            .then((value) => value ? 'downloaded' : 'not downloaded'),
        context,
        this);
  }

  Future<void> _translateText() async {
    FocusScope.of(context).unfocus();
    Toast().show(
        'Translating...',
        _onDeviceTranslator.translateText(_controller.text).then((result) {
          setState(() {
            _translatedText = result;
          });
          return 'done!';
        }),
        context,
        this);
  }
}
