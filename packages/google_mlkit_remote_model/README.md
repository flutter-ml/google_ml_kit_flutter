# google_mlkit_remote_model

[![Pub Version](https://img.shields.io/pub/v/google_mlkit)](https://pub.dev/packages/google_mlkit)

A Flutter plugin using with [google_mlkit](https://github.com/bharat-biradar/Google-Ml-Kit-plugin) to download [Custom Models with ML Kit](https://developers.google.com/ml-kit/custom-models).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin).

## Usage

```dart
final modelName = '';
final remoteModelManager = RemoteModelManager();

final isModelDownloaded = await remoteModelManager.isModelDownloaded(modelName);

final success = await remoteModelManager.deleteModel(modelName);

final success = await remoteModelManager.downloadModel(modelName);
```

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
