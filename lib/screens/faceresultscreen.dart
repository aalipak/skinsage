import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:skinsage/screens/home.dart';

class FaceLandmarkScreen extends StatelessWidget {
  final InputImage inputImage; // ML Kit's InputImage
  final Face faces; // Detected faces with landmarks

  const FaceLandmarkScreen(
      {required this.inputImage, required this.faces, super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final availableHeight = screenSize.height - AppBar().preferredSize.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Face Landmarks")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<ui.Image>(
              future: loadUiImage(inputImage),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError || snapshot.data == null) {
                  return const Text("Failed to load image");
                }

                final ui.Image image = snapshot.data!;
                final Size imageSize =
                    Size(image.width.toDouble(), image.height.toDouble());

                // Calculate the scaling factor to make the drawing larger
                final double aspectRatio = imageSize.width / imageSize.height;
                final double targetWidth =
                    screenSize.width * 0.95; // Use 95% of screen width
                final double targetHeight = targetWidth / aspectRatio;

                // Make sure it fits vertically
                final Size finalSize;
                if (targetHeight > availableHeight * 0.95) {
                  final double adjustedHeight = availableHeight * 0.95;
                  final double adjustedWidth = adjustedHeight * aspectRatio;
                  finalSize = Size(adjustedWidth, adjustedHeight);
                } else {
                  finalSize = Size(targetWidth, targetHeight);
                }

                return _buildCustomPainter(image, imageSize, finalSize);
              },
            ),
            const SizedBox(height: 30),

            // New Button to Navigate to Home
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("See the analysis results"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPainter(ui.Image image, Size imageSize, Size targetSize) {
    return SizedBox(
      width: targetSize.width,
      height: targetSize.height,
      child: CustomPaint(
        size: targetSize,
        painter: FaceDetectorPainter(
          image,
          faces,
          imageSize,
          targetSize,
          InputImageRotation.rotation0deg,
          CameraLensDirection.front,
        ),
      ),
    );
  }

  // Load InputImage as UI image
  Future<ui.Image> loadUiImage(InputImage image) async {
    List<int>? bytes;

    if (image.bytes != null) {
      bytes = image.bytes!.toList();
    } else if (image.filePath != null) {
      bytes = await File(image.filePath!).readAsBytes();
    }

    if (bytes == null) throw Exception("Invalid image data");

    final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.image,
    this.faces,
    this.originalImageSize,
    this.canvasSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final ui.Image image;
  final Face faces;
  final Size originalImageSize;
  final Size canvasSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    // First, paint the image
    paintImage(canvas, size);

    // Then paint the face landmarks
    paintFaceLandmarks(canvas, size);
  }

  void paintImage(Canvas canvas, Size size) {
    final Rect destinationRect = Offset.zero & size;
    final Rect sourceRect =
        Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, sourceRect, destinationRect, Paint());
  }

  void paintFaceLandmarks(Canvas canvas, Size size) {
    final Paint boundingBoxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    final Paint landmarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..color = Colors.green;

    // Calculate scaling factors - the key to fixing alignment
    final double scaleX = size.width / originalImageSize.width;
    final double scaleY = size.height / originalImageSize.height;

    // Apply scaling directly instead of using translateX/Y
    final left = faces.boundingBox.left * scaleX;
    final top = faces.boundingBox.top * scaleY;
    final right = faces.boundingBox.right * scaleX;
    final bottom = faces.boundingBox.bottom * scaleY;

    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      boundingBoxPaint,
    );

    void paintContour(FaceContourType type) {
      final contour = faces.contours[type];
      if (contour?.points != null) {
        for (final Point point in contour!.points) {
          canvas.drawCircle(
              Offset(
                point.x.toDouble() * scaleX,
                point.y.toDouble() * scaleY,
              ),
              2,
              boundingBoxPaint);
        }
      }
    }

    void paintLandmark(FaceLandmarkType type) {
      final landmark = faces.landmarks[type];
      if (landmark?.position != null) {
        canvas.drawCircle(
            Offset(
              landmark!.position.x.toDouble() * scaleX,
              landmark.position.y.toDouble() * scaleY,
            ),
            3,
            landmarkPaint);
      }
    }

    for (final type in FaceContourType.values) {
      paintContour(type);
    }

    for (final type in FaceLandmarkType.values) {
      paintLandmark(type);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.originalImageSize != originalImageSize ||
        oldDelegate.faces != faces ||
        oldDelegate.canvasSize != canvasSize;
  }
}
