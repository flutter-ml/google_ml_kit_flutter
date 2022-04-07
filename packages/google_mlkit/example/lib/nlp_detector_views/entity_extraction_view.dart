import 'package:flutter/material.dart';
import 'package:google_mlkit/google_mlkit.dart';

import '../vision_detector_views/toast.dart';

class EntityExtractionView extends StatefulWidget {
  @override
  _EntityExtractionViewState createState() => _EntityExtractionViewState();
}

class _EntityExtractionViewState extends State<EntityExtractionView> {
  final _controller = TextEditingController();

  final _languageModelManager = GoogleMlKit.nlp.entityModelManager();

  final _entityExtractor =
      GoogleMlKit.nlp.entityExtractor(EntityExtractorLanguage.english);

  var _entities = <EntityAnnotation>[];

  final _language = EntityExtractorLanguage.english;

  @override
  void dispose() {
    _entityExtractor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entity Extractor'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Center(child: Text('Enter text (English)')),
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                    onPressed: _extractEntities,
                    child: Text('Extract Entities'))
              ]),
              const SizedBox(height: 20),
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
              ]),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text('Result', style: TextStyle(fontSize: 20)),
              ),
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: _entities.length,
                itemBuilder: (context, index) => ExpansionTile(
                    title: Text(_entities[index].text),
                    children: _entities[index]
                        .entities
                        .map((e) => Text(e.toString()))
                        .toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadModel() async {
    Toast().show(
        'Downloading model...',
        _languageModelManager
            .downloadModel(_language, isWifiRequired: false)
            .then((value) => value ? 'success' : 'error'),
        context,
        this);
  }

  Future<void> _deleteModel() async {
    Toast().show(
        'Deleting model...',
        _languageModelManager
            .deleteModel(_language)
            .then((value) => value ? 'success' : 'error'),
        context,
        this);
  }

  Future<void> _isModelDownloaded() async {
    Toast().show(
        'Checking if model is downloaded...',
        _languageModelManager
            .isModelDownloaded(_language)
            .then((value) => value ? 'exists' : 'not exists'),
        context,
        this);
  }

  Future<void> _extractEntities() async {
    FocusScope.of(context).unfocus();
    final result = await _entityExtractor.extractEntities(_controller.text);
    setState(() {
      _entities = result;
    });
  }
}
