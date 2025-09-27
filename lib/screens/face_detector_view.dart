import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'detector_view.dart';
import 'camera_controller.dart';
import 'faceresultscreen.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
   CameraStateController cameraStateController = Get.find<CameraStateController>();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'SkinSage:',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
     cameraStateController.inputImage = inputImage;
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    
    final faces = await _faceDetector.processImage(inputImage);
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
     
     // Navigate to Result Analysis Screen
  if (faces.isNotEmpty) {
     cameraStateController.faces=faces[0];
     await cameraStateController.cropBoundingBox(cameraStateController.inputImage, cameraStateController.faces.boundingBox);
     
    Get.to(() => FaceLandmarkScreen(
          inputImage: cameraStateController.inputImage,
          faces: cameraStateController.faces,
        ),
      );
  }
  }
}
