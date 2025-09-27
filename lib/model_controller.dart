import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'screens/face_detector_view.dart';

class ModelController extends GetxController {
  Interpreter? skinToneInterpreter;
  Interpreter? skinConditionInterpreter;
  Interpreter? ageInterpreter;
  RxBool isModelLoaded = false.obs;
  RxBool isError = false.obs;
  RxInt p2 = 0.obs, p3 = 0.obs;
  static const platform = MethodChannel('com.skinsage.model');

  @override
  void onInit() {
    loadAllModels();
    super.onInit();
  }

  Future<void> loadAllModels() async {
    try {
      await Future.wait([
        _loadModel("assets/models/skintone.tflite"),
        _loadModel("assets/models/skin_condition_model.tflite"),
        _loadModel("assets/models/age.tflite"),
      ]);
      isModelLoaded.value = true;
      isError.value = false;
      FaceDetectorView();
    } catch (e) {
      debugPrint('hex-Model Loading Error: $e');
      isError.value = true;
      isModelLoaded.value = false;
    }
  }

  Future<void> _loadModel(String assetPath) async {
    try {
      debugPrint('hex-Loading $assetPath');
      final tempDir = await getTemporaryDirectory();
      final modelFileName = assetPath.split('/').last;
      final localFile = File('${tempDir.path}/$modelFileName');

      // Copy asset file to temp directory
      final byteData = await rootBundle.load(assetPath);
      await localFile.writeAsBytes(byteData.buffer.asUint8List());

      final interpreter = Interpreter.fromFile(localFile);

      if (assetPath.contains('skintone')) {
        skinToneInterpreter = interpreter;
        p2.value = 100;
      } else if (assetPath.contains('skin_condition_model')) {
        skinConditionInterpreter = interpreter;
        p3.value = 100;
      } else if (assetPath.contains('age')) {
        ageInterpreter = interpreter;
        p3.value = 100;
      }
      debugPrint('hex-Loading complete: $assetPath');
    } catch (e) {
      debugPrint('hex-Error loading the model: $assetPath, error: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    skinToneInterpreter?.close();
    skinConditionInterpreter?.close();
    ageInterpreter?.close();
  }
}
