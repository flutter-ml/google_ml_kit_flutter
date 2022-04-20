# Google's ML Kit Smart Reply for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_smart_reply)](https://pub.dev/packages/google_mlkit_smart_reply)

A Flutter plugin to use [Google's ML Kit Smart Reply API](https://developers.google.com/ml-kit/language/smart-reply).

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

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
