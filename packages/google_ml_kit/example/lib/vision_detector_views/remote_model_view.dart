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
    Toast().show('Checking if model is downloaded...', isModelDownloaded(),
        context, this);
  }

  Future<void> _deleteModel() async {
    Toast().show('Deleting model...', deleteModel(), context, this);
  }

  Future<void> _downloadModel() async {
    Toast().show('Downloading model...', downloadModel(), context, this);
  }

  Future<String> isModelDownloaded() async {
    final isModelDownloaded =
        await _remoteModelManager.isModelDownloaded(_modelName);
    return isModelDownloaded ? 'exists' : 'not exists';
  }

  Future<String> deleteModel() async {
    return (await _remoteModelManager.deleteModel(_modelName))
        ? 'success'
        : 'error';
  }

  Future<String> downloadModel() async {
    return (await _remoteModelManager.downloadModel(_modelName))
        ? 'success'
        : 'error';
  }
}
