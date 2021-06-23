import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RemoteModelView extends StatelessWidget {
  final _remoteModelManager = GoogleMlKit.vision.remoteModelManager();

  Future<void> downloadModel() async {
    var result = await _remoteModelManager.downloadModel('bird-classifier',
        isWifiRequired: false);
    print('Model downloaded: $result');
  }

  Future<void> deleteModel() async {
    var result = await _remoteModelManager.deleteModel('bird-classifier');
    print('Model deleted: $result');
  }

  Future<void> isModelDownloaded() async {
    var result = await _remoteModelManager.isModelDownloaded('bird-classifier');
    print('Model download: $result');
  }

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
                  onPressed: downloadModel, child: Text('Download Model')),
              ElevatedButton(
                  onPressed: deleteModel, child: Text('Delete Model')),
            ],
          ),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
                onPressed: isModelDownloaded, child: Text('Check download'))
          ])
        ],
      ),
    );
  }
}
