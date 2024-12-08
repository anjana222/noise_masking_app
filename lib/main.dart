import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

void main() {
  runApp(NoiseMaskingApp());
}

class NoiseMaskingApp extends StatefulWidget {
  @override
  _NoiseMaskingAppState createState() => _NoiseMaskingAppState();
}

class _NoiseMaskingAppState extends State<NoiseMaskingApp> {
  Interpreter? _interpreter;
  final AudioPlayer _player = AudioPlayer();
  final AudioStreamer _audioStreamer = AudioStreamer();

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeAudioStreamer();
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
    print("Model loaded successfully.");
  }

  // Initialize the audio streamer
  void _initializeAudioStreamer() {
    _audioStreamer.start(
      onAudioDataReceived: (Uint8List audioData) {
        // Run the model when audio data is received
        runModel(audioData);
      },
    );
  }

  // Run the model on the input buffer and print the result
  Future<void> runModel(Uint8List inputBuffer) async {
    if (_interpreter == null) {
      print("Model not loaded yet.");
      return;
    }
    var outputBuffer = List.filled(1, 0).reshape([1]);
    _interpreter!.run(inputBuffer, outputBuffer);
    print('Predicted Noise Type: ${outputBuffer[0]}');
    _playMaskingSound(outputBuffer[0]);
  }

  // Play a masking sound based on prediction
  void _playMaskingSound(int soundType) {
    String soundFile =
        'assets/sound_${soundType}.mp3'; // Adjust the sound file path based on your needs
    _player.play(AssetSource(soundFile));
  }

  @override
  void dispose() {
    _interpreter?.close();
    _player.dispose();
    _audioStreamer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noise Masking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Noise Masking App'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Start the audio streaming
              print("Audio streaming started.");
            },
            child: Text('Start Listening'),
          ),
        ),
      ),
    );
  }
}
