import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class SimpleCameraView extends StatefulWidget {
  final Function(File)? onImageCaptured;
  const SimpleCameraView({super.key, this.onImageCaptured});

  @override
  _SimpleCameraViewState createState() => _SimpleCameraViewState();
}

class _SimpleCameraViewState extends State<SimpleCameraView> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (!_isCameraInitialized || _isCapturing) return;

    try {
      _isCapturing = true;
      final image = await _controller.takePicture();

      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/captured_image.jpg';
      final File imageFile = await File(image.path).copy(filePath);

      if (widget.onImageCaptured != null) {
        widget.onImageCaptured!(imageFile);
      }

      Get.back(result: imageFile.path);
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      _isCapturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Take Photo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                Center(
                  child: Transform.scale(
                    scale: 1.0,
                    child: Center(
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _captureImage,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: const Center(
                            child: Icon(Icons.camera_alt,
                                color: Colors.black, size: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
