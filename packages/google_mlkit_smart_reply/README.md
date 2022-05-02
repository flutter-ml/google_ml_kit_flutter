# Google's ML Kit Smart Reply for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_smart_reply)](https://pub.dev/packages/google_mlkit_smart_reply)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Smart Reply API](https://developers.google.com/ml-kit/language/smart-reply) to automatically generate relevant replies to messages.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Smart Reply

#### Create an instance of `SmartReply`

```dart
final smartReply = SmartReply();
```

#### Add messages to the conversation

```dart
// For local user.
smartReply.addMessageToConversationFromLocalUser(message, timestamp);

// For remote user. 
smartReply.addMessageToConversationFromRemoteUser(message, timestamp, userId);
```
#### Generate replies

```dart
final response = await smartReply.suggestReplies();

for (final suggestion in response.suggestions) {
  print('suggestion: $suggestion');
}
```

#### Release resources with `close()`

```dart
smartReply.close();
```

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
