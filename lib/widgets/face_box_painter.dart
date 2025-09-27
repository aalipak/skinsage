import 'package:flutter/material.dart';

class FaceBoxPainter extends CustomPainter {
  final Rect faceBox;

  FaceBoxPainter(this.faceBox);

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('hex-Printing face: $faceBox');

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw the main box based on the exact input Rect
    canvas.drawRect(faceBox, paint);

    // Draw corner markers
    final markerLength = faceBox.width * 0.1; // 10% of box width
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top-left corner
    canvas.drawLine(
      Offset(faceBox.left, faceBox.top),
      Offset(faceBox.left + markerLength, faceBox.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceBox.left, faceBox.top),
      Offset(faceBox.left, faceBox.top + markerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(faceBox.right, faceBox.top),
      Offset(faceBox.right - markerLength, faceBox.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceBox.right, faceBox.top),
      Offset(faceBox.right, faceBox.top + markerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(faceBox.left, faceBox.bottom),
      Offset(faceBox.left + markerLength, faceBox.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceBox.left, faceBox.bottom),
      Offset(faceBox.left, faceBox.bottom - markerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(faceBox.right, faceBox.bottom),
      Offset(faceBox.right - markerLength, faceBox.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceBox.right, faceBox.bottom),
      Offset(faceBox.right, faceBox.bottom - markerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FaceBoxPainter oldDelegate) {
    return faceBox != oldDelegate.faceBox;
  }
}
