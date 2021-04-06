import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

class LanguageIdentifierView extends StatefulWidget {
  @override
  _LanguageIdentifierViewState createState() => _LanguageIdentifierViewState();
}

class _LanguageIdentifierViewState extends State<LanguageIdentifierView> {
  List<IdentifiedLanguage> _identifiedLanguages = <IdentifiedLanguage>[];
  late TextEditingController _controller;
  final _languageIdentifier = GoogleMlKit.nlp.languageIdentifier(confidenceThreshold: 0.34);
  var _identifiedLanguage = '';

  Future<void> _identifyLanguage() async {
    if (_controller.text == '') return;
    final language =
        await _languageIdentifier.identifyLanguange(_controller.text);

    setState(() {
      _identifiedLanguage = language;
    });
  }

  Future<void> _identifyPossibleLanguages() async {
    if (_controller.text == '') return;
    final possibleLanguages =
        await _languageIdentifier.identifyPossibleLanguages(_controller.text);
   
    setState(() {
      _identifiedLanguages = possibleLanguages;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: _controller,
          ),
        ),
        SizedBox(height: 15),
        _identifiedLanguage == ''
            ? Container()
            : Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Text(
                  'Identified Language: $_identifiedLanguage',
                  style: TextStyle(fontSize: 20),
                )),
        ElevatedButton(
            onPressed: _identifyLanguage,
            child: const Text('Identify Language')),
        SizedBox(height: 15),
        ElevatedButton(
          child: const Text('Identify possible languages'),
          onPressed: _identifyPossibleLanguages,
        ),
        Container(
          child: ListView.builder(
            shrinkWrap: true,
              itemCount: _identifiedLanguages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      'Language: ${_identifiedLanguages[index].language}  Confidence: ${_identifiedLanguages[index].confidence.toString()}'),
                );
              }),
        )
      ]),
    );
  }

  @override
  void dispose() async{
    super.dispose();
    await _languageIdentifier.close();
  } 
}
