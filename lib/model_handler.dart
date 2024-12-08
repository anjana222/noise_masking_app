// lib/model_handler.dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class ModelHandler {
  Future<void> runModel(Uint8List inputBuffer) async {
    // Load the interpreter from the asset
    final interpreter = await Interpreter.fromAsset('model.tflite');

    // Define output buffer
    var outputBuffer = List.filled(1, 0).reshape([1]);

    // Run the model
    interpreter.run(inputBuffer, outputBuffer);

    // Print the prediction
    print('Predicted Noise Type: ${outputBuffer[0]}');

    // Close the interpreter after use
    interpreter.close();
  }
}
