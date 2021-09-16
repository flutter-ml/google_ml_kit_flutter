import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'toast.dart';

class RemoteModelView extends StatefulWidget {
  @override
  _RemoteModelViewState createState() => _RemoteModelViewState();
}

class _RemoteModelViewState extends State<RemoteModelView> {
  final _remoteModelManager = GoogleMlKit.vision.remoteModelManager();
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
    Future<String> Function() function = () async {
      final isModelDownloaded =
          await _remoteModelManager.isModelDownloaded(_modelName);
      return isModelDownloaded ? 'exists' : 'not exists';
    };
    Toast()
        .show('Checking if model is downloaded...', function(), context, this);
  }

  Future<void> _deleteModel() async {
    Toast().show('Deleting model...',
        _remoteModelManager.deleteModel(_modelName), context, this);
  }

  Future<void> _downloadModel() async {
    Toast().show('Downloading model...',
        _remoteModelManager.downloadModel(_modelName), context, this);
  }
}
