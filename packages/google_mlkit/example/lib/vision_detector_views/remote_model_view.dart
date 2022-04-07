import 'package:flutter/material.dart';
import 'package:google_mlkit/google_mlkit.dart';

import 'toast.dart';

class RemoteModelView extends StatefulWidget {
  @override
  _RemoteModelViewState createState() => _RemoteModelViewState();
}

class _RemoteModelViewState extends State<RemoteModelView> {
  final _modelManager = RemoteModelManager();
  final _modelName = 'bird-classifier';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Remote Model Manager')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
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
                onPressed: _isModelDownloaded, child: Text('Check download'))
          ])
        ],
      ),
    );
  }

  Future<void> _isModelDownloaded() async {
    Toast().show(
        'Checking if model is downloaded...',
        _modelManager
            .isModelDownloaded(_modelName)
            .then((value) => value ? 'exists' : 'not exists'),
        context,
        this);
  }

  Future<void> _deleteModel() async {
    Toast().show(
        'Deleting model...',
        _modelManager
            .deleteModel(_modelName)
            .then((value) => value ? 'success' : 'error'),
        context,
        this);
  }

  Future<void> _downloadModel() async {
    Toast().show(
        'Downloading model...',
        _modelManager
            .downloadModel(_modelName)
            .then((value) => value ? 'success' : 'error'),
        context,
        this);
  }
}
