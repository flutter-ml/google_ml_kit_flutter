import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class SmartReplyView extends StatefulWidget {
  @override
  _SmartReplyViewState createState() => _SmartReplyViewState();
}

class _SmartReplyViewState extends State<SmartReplyView> {
  var _localUserController = TextEditingController();
  var _remoteUserController = TextEditingController();
  var _suggestions = <SmartReplySuggestion>[];

  final SmartReply _smartReply = GoogleMlKit.nlp.smartReply();

  @override
  void dispose() {
    _smartReply.close();
    super.dispose();
  }

  Future<void> _addConversation(bool localUser) async {
    if (localUser)
      _smartReply.addConversationForLocalUser(_localUserController.text);
    else
      _smartReply.addConversationForRemoteUser(
          _remoteUserController.text, 'userZ');
  }

  Future<void> _suggestReplies() async {
    final result = await _smartReply.suggestReplies();

    setState(() {
      _suggestions = result['suggestions'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Entity Extractor"),
        ),
        body: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Center(
                child: const Text('Enter conversation for Local User')),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 2,
                )),
                child: TextField(
                  controller: _localUserController,
                  decoration: InputDecoration(border: InputBorder.none),
                  maxLines: null,
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    if (_localUserController.text.isNotEmpty) {
                      _addConversation(true);
                      _localUserController.text = '';
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Can't be empty")));
                    }
                  },
                  child: Text('Add conversation')),
            ),
            SizedBox(height: 30),
            const Center(
                child: const Text('Enter conversation for remote user')),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 2,
                )),
                child: TextField(
                  controller: _remoteUserController,
                  decoration: InputDecoration(border: InputBorder.none),
                  maxLines: null,
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    if (_remoteUserController.text.isNotEmpty) {
                      _addConversation(false);
                      _remoteUserController.text = '';
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Can't be empty")));
                    }
                  },
                  child: Text('Add conversation')),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: _suggestReplies, child: Text('Suggest Replies')),
            ),
            _suggestions.length > 0
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_suggestions[index].getText()),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
