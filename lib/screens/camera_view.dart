import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'package:face_camera/face_camera.dart';

class CameraView extends StatefulWidget {
  final Function(File)? onImageCaptured; // Callback to return selected image
  const CameraView({super.key, this.onImageCaptured});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  RxBool isCameraInitialized = false.obs;
  File? _capturedImage;
  bool isFaceDetected = false;
  late CameraController cameraController;
  late FaceCameraController controller;
  Rx<Rect> faceBox = Rect.zero.obs;
  // Define target bounding box dimensions
  static const double boxWidth = 300.0;
  static const double boxHeight = 300.0;
  late Rect guidanceBox;
  bool _isCapturing = false;

  @override
  void initState() {
    controller = FaceCameraController(
      autoCapture: false,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) async {
        if (image != null) {
          final Directory directory = await getApplicationDocumentsDirectory();
          final String filePath = '${directory.path}/captured_image.jpg';
          final File imageFile = await image.copy(filePath);

          setState(() => _capturedImage = imageFile);
          if (widget.onImageCaptured != null) {
            widget.onImageCaptured!(imageFile);
          }
        }
      },
      onFaceDetected: (Face? face) {
        if (face != null) {
          faceBox.value = face.boundingBox ?? Rect.zero;
          // checkFacePosition(face.boundingBox!);
        } else {
          faceBox.value = Rect.zero;
          // isFaceInBox.value = false;
        }
      },
    );
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await cameraController.initialize();
    isCameraInitialized.value = true;
    // startFaceDetection();
  }

//   void startFaceDetection() {
//   cameraController.startImageStream((CameraImage image) async {
//     if (!isCameraInitialized.value) {
//       print("Camera not initialized yet!");
//       return;
//     }

//     try {
//       final inputImage = InputImage.fromBytes(
//         bytes: image.planes[0].bytes,
//         metadata: InputImageMetadata(
//           size: Size(image.width.toDouble(), image.height.toDouble()),
//           rotation: InputImageRotation.rotation0deg, // Adjust based on your device
//           format: InputImageFormat.yuv420, // Try this format
//           bytesPerRow: image.planes[0].bytesPerRow,
//         ),
//       );

//       print("Image metadata: ${inputImage.metadata}");

//       final faces = await _faceDetector.processImage(inputImage);

//       if (faces.isNotEmpty) {
//         faceBox.value = faces.first.boundingBox;
//         print("Face detected: ${faceBox.value}");
//       } else {
//         faceBox.value = Rect.zero;
//         print("No face detected");
//       }

//       // Ensure UI updates in real time
//       setState(() {});
//     } catch (e) {
//       print("Face detection error: $e");
//     }
//   });
// }

  String getInstruction() {
    print("Face Box: $faceBox");

    if (faceBox.value == Rect.zero) {
      isFaceDetected = false;
      return "No face detected";
    } else if (faceBox.value.width < boxWidth * 0.8) {
      isFaceDetected = false;
      return "Move closer";
    } else if (faceBox.value.width > boxWidth * 1.2) {
      isFaceDetected = false;
      return "Move back";
    } else if (faceBox.value.left < guidanceBox.left) {
      isFaceDetected = false;
      return "Move right";
    } else if (faceBox.value.right > guidanceBox.right) {
      isFaceDetected = false;
      return "Move left";
    } else if (faceBox.value.top < guidanceBox.top) {
      isFaceDetected = false;
      return "Move down";
    } else if (faceBox.value.bottom > guidanceBox.bottom) {
      isFaceDetected = false;
      return "Move up";
    } else {
      isFaceDetected = true;
      // Add a small delay before capturing to ensure stability
      if (!_isCapturing) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (isFaceDetected && !_isCapturing) {
            // Check if still in perfect position
            captureImage();
          }
        });
      }
      return "Perfect! Hold still and capture";
    }
  }

  Future<void> captureImage() async {
    if (!isCameraInitialized.value || _isCapturing) return;

    try {
      _isCapturing = true;
      final file = await cameraController.takePicture();
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/captured_image.jpg';
      final File imageFile = await File(file.path).copy(filePath);

      // Return image file path when capture is done
      Get.back(result: imageFile.path);
    } finally {
      _isCapturing = false;
    }
  }

  IconData _getInstructionIcon(String instruction) {
    switch (instruction.toLowerCase()) {
      case 'move closer':
        return Icons.zoom_in;
      case 'move back':
        return Icons.zoom_out;
      case 'move right':
        return Icons.arrow_forward;
      case 'move left':
        return Icons.arrow_back;
      case 'move up':
        return Icons.arrow_upward;
      case 'move down':
        return Icons.arrow_downward;
      default:
        return Icons.face;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate center position for guidance box
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    guidanceBox = Rect.fromCenter(
      center: Offset(screenWidth / 2, screenHeight / 2),
      width: boxWidth,
      height: boxHeight,
    );

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Face Detection'),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: _capturedImage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.file(
                          _capturedImage!,
                          width: double.maxFinite,
                          fit: BoxFit.fitWidth,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await cameraController.startImageStream((image) {});
                            setState(() => _capturedImage = null);
                          },
                          child: const Text('Capture Again'),
                        ),
                      ],
                    ),
                  )
                : Obx(
                    () => isCameraInitialized.value
                        ? Stack(
                            children: [
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..scale(-1.0, 1.0, 1.0),
                                child: SmartFaceCamera(
                                  controller: controller,
                                  showControls: false,
                                  showCaptureControl: false,
                                  showFlashControl: false,
                                  showCameraLensControl: false,
                                ),
                              ),
                              Positioned(
                                left: guidanceBox.left,
                                top: guidanceBox.top,
                                child: Stack(
                                  children: [
                                    // Invisible rectangle for face detection logic
                                    Container(
                                      width: boxWidth,
                                      height: boxHeight,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: const Color.fromARGB(0, 104, 55, 55),
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    // Visible oval shape
                                    Container(
                                      width: boxWidth,
                                      height: boxHeight,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isFaceDetected
                                              ? const Color.fromARGB(255, 76, 175, 79)
                                              : const Color.fromARGB(255, 130, 40, 195),
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (faceBox.value != Rect.zero)
                                Positioned(
                                  left: faceBox.value.left,
                                  top: faceBox.value.top,
                                  child: Container(
                                    width: faceBox.value.width,
                                    height: faceBox.value.height,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(0, 151, 136, 136), width: 2),
                                    ),
                                  ),
                                ),
                              Obx(() {
                                String instruction = getInstruction();
                                return Positioned(
                                  top: 50,
                                  left: 20,
                                  right: 20,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFaceDetected
                                          ? const Color.fromARGB(
                                                  119, 76, 175, 79)
                                              .withOpacity(0.9)
                                          : Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (!isFaceDetected) ...[
                                          Icon(
                                            _getInstructionIcon(instruction),
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Text(
                                          instruction,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              Positioned(
                                bottom: 30,
                                left:
                                    MediaQuery.of(context).size.width / 2 - 35,
                                child: GestureDetector(
                                  onTap: captureImage,
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
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                          color: Colors.black, width: 3),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.camera_alt,
                                          color: Colors.black, size: 32),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text('Wait a sec..',
                                style: TextStyle(fontSize: 18)),
                          ),
                  ),
          ),
        ));
  }

  @override
  void dispose() {
    cameraController.dispose();
    // controller.dispose();
    super.dispose();
  }
}
