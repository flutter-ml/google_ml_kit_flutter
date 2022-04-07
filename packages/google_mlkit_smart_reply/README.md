# Google's ML Kit Smart Reply for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

A Flutter plugin to use [Google's ML Kit Smart Reply API](https://developers.google.com/ml-kit/language/smart-reply).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin).

## Translating Text

#### 1. Create an instance of Smart Reply

```dart
final onDeviceTranslator = SmartReply();
```

#### 2. Add conversation texts

```dart
// For local user.
final String response = await smartReply.addConversationForLocalUser(text);

// For remote user. 
final String response = await smartReply.addConversationForRemoteUser(_remoteUserController.text, uid);
    }
```
#### 3. Generate replies.
```dart
/// Get status of suggestions by `reponse['status']`.
/// 0 =  STATUS_SUCCESS.
/// 1 =  STATUS_NOT_SUPPORTED_LANGUAGE.
/// 2 =  STATUS_NO_REPLY. 
final Map<String, dynamic> response= await smartReply.suggestReplies();
```
#### 4. Release resources with `close()`

```dart
smartReply.close();
```

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
