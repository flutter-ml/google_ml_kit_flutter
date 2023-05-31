import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class LanguageIdentifierView extends StatefulWidget {
  @override
  State<LanguageIdentifierView> createState() => _LanguageIdentifierViewState();
}

class _LanguageIdentifierViewState extends State<LanguageIdentifierView> {
  List<IdentifiedLanguage> _identifiedLanguages = <IdentifiedLanguage>[];
  final TextEditingController _controller = TextEditingController();
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  var _identifiedLanguage = '';

  @override
  void dispose() {
    _languageIdentifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Language Identification')),
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
          onPressed: _identifyPossibleLanguages,
          child: const Text('Identify possible languages'),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: _identifiedLanguages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    'Language: ${_identifiedLanguages[index].languageTag}  Confidence: ${_identifiedLanguages[index].confidence.toString()}'),
              );
            })
      ]),
    );
  }

  Future<void> _identifyLanguage() async {
    if (_controller.text == '') return;
    String language;
    try {
      language = await _languageIdentifier.identifyLanguage(_controller.text);
    } on PlatformException catch (pe) {
      if (pe.code == _languageIdentifier.undeterminedLanguageCode) {
        language = 'error: no language identified!';
      }
      language = 'error: ${pe.code}: ${pe.message}';
    } catch (e) {
      language = 'error: ${e.toString()}';
    }
    setState(() {
      _identifiedLanguage = language;
    });
  }

  Future<void> _identifyPossibleLanguages() async {
    if (_controller.text == '') return;
    String error;
    try {
      final possibleLanguages =
          await _languageIdentifier.identifyPossibleLanguages(_controller.text);
      setState(() {
        _identifiedLanguages = possibleLanguages;
      });
      return;
    } on PlatformException catch (pe) {
      if (pe.code == _languageIdentifier.undeterminedLanguageCode) {
        error = 'error: no languages identified!';
      }
      error = 'error: ${pe.code}: ${pe.message}';
    } catch (e) {
      error = 'error: ${e.toString()}';
    }
    setState(() {
      _identifiedLanguages = [];
      _identifiedLanguage = error;
    });
  }
}
