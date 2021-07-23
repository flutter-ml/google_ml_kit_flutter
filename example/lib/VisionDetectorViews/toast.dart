import 'package:flutter/material.dart';

class Toast {
  void show(String message, Future<String> t, BuildContext context,
      State<StatefulWidget> state) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
    final verificationResult = await t;
    if (!state.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Result: ${verificationResult.toString()}'),
    ));
  }
}
