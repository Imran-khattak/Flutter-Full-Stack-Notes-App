import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechController extends StatefulWidget {
  const SpeechController({super.key});

  @override
  State<SpeechController> createState() => _SpeechControllerState();
}

class _SpeechControllerState extends State<SpeechController> {
  late stt.SpeechToText speech;
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  void listen() async {
    if (!_speechEnabled) {
      bool available = await speech.initialize(
        onStatus: (value) => print("onStatus $value"),
        onError: (value) => print("onError $value"),
      );

      if (available) {
        setState(() => _speechEnabled = true);

        speech.listen(
          onResult: (value) => setState(() {
            _lastWords = value.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _speechEnabled = false);
      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(padding: EdgeInsets.all(20), child: Text(_lastWords)),
      floatingActionButton: AvatarGlow(
        animate: _speechEnabled,
        glowColor: Theme.of(context).primaryColor,
        duration: Duration(microseconds: 2000),
        glowRadiusFactor: 75.0,
        repeat: true,
        child: FloatingActionButton(
          onPressed: listen,
          child: Icon(_speechEnabled ? Icons.mic : Icons.mic_none),
        ),
      ),
    );
  }
}
