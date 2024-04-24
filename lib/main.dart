import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sigturk_sakha_transliterator_app/src/rust/api/sigturk_sakha_transliterator.dart';
import 'package:sigturk_sakha_transliterator_app/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGTURK Sakha Transliterator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TransliteratorScreen(),
    );
  }
}

class TransliteratorScreen extends StatefulWidget {
  const TransliteratorScreen({super.key});

  @override
  _TransliteratorScreenState createState() => _TransliteratorScreenState();
}

class _TransliteratorScreenState extends State<TransliteratorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _transliteratedText = "";
  int _inputLength = 0;
  int _outputLength = 0;

  void _transliterateText(String inputText) {
    final String result =
        transliterateSakhaCyrillicToSakhaLatin(text: inputText);
    setState(() {
      _transliteratedText = result;
      _inputLength = inputText.length;
      _outputLength = result.length;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _transliteratedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      _controller.text = data.text!;
      _transliterateText(data.text!);
    }
  }

  void _clearText() {
    _controller.clear();
    setState(() {
      _transliteratedText = "";
      _inputLength = 0;
      _outputLength = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _transliterateText(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakha Transliterator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Enter text in Sakha Cyrillic',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _pasteFromClipboard,
                  child: const Text('Paste'),
                ),
                const SizedBox(width: 8), // Add some spacing between buttons
                ElevatedButton(
                  onPressed: _clearText,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _transliteratedText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _copyToClipboard,
                  child: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Input Length: $_inputLength',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Output Length: $_outputLength',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
