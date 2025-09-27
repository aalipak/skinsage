import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';

import 'package:skinsage/screens/camera_controller.dart';

class FaceGoldenRatio extends StatelessWidget {
  CameraStateController cameraStateController = Get.find<CameraStateController>();

  FaceGoldenRatio({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Montserrat',
        useMaterial3: true,
      ),
      home: FaceDetectionScreen(faceInputProvider: FaceInputProvider(cameraStateController.faces)),
    );
  }
}

class FaceInputProvider {
  final Face face;
  FaceInputProvider(this.face);
}

class FaceDetectionScreen extends StatefulWidget {
  final FaceInputProvider faceInputProvider;

  const FaceDetectionScreen({super.key, required this.faceInputProvider});

  @override
  FaceDetectionScreenState createState() => FaceDetectionScreenState();
}

class FaceDetectionScreenState extends State<FaceDetectionScreen> with SingleTickerProviderStateMixin {
  CameraStateController cameraStateController = Get.find<CameraStateController>();
  String _result = "Analyzing your facial proportions...";
  late double goldenratio=0.0;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _processFace(widget.faceInputProvider.face);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processFace(Face face) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate processing time
    
    double? eyeWidth = _distance(face.landmarks[FaceLandmarkType.leftEye]!, face.landmarks[FaceLandmarkType.rightEye]!);
    double? noseToChin = _distance(face.landmarks[FaceLandmarkType.noseBase]!, face.landmarks[FaceLandmarkType.bottomMouth]!);
    double? faceWidth = _distance(face.landmarks[FaceLandmarkType.leftCheek]!, face.landmarks[FaceLandmarkType.rightCheek]!);
    // Approximate chin as ~15% lower than bottom mouth (can tune this)
double chinOffset = 0.15 * noseToChin!;
double approxNoseToChin = noseToChin + chinOffset;
    if (noseToChin == null) {
      setState(() {
        _result = "Could not calculate facial proportions.";
        _isLoading = false;
      });
      return;
    }

    cameraStateController.goldenRatio = (eyeWidth + approxNoseToChin) / faceWidth;
    
    goldenratio = cameraStateController.goldenRatio; // Ensure the ratio is within a reasonable range

    setState(() {
      goldenratio = cameraStateController.goldenRatio;
      // cameraStateController.goldenRatio = goldenratio;
      _result = _assessGoldenRatio(goldenratio);
      _isLoading = false;
    });
  }

  double _distance(FaceLandmark a, FaceLandmark b) {
    return sqrt(pow(a.position.x - b.position.x, 2) + pow(a.position.y - b.position.y, 2));
  }

  String _assessGoldenRatio(double ratio) {
    const double idealRatio = 1.618;
    if ((ratio - idealRatio).abs() < 0.1) {
      return "Your face is very close to the golden ratio! Well-proportioned and balanced.";
    } else if (ratio < idealRatio) {
      return "Your face proportions suggest a slightly shorter vertical symmetry. Hairstyles that add height may enhance balance.";
    } else {
      return "Your face has an elongated proportion. A hairstyle that reduces vertical length may help balance it.";
    }
  }

  Color _getRatioColor() {
    const double idealRatio = 1.618;
    double difference = (goldenratio - idealRatio).abs();
    
    if (difference < 0.1) {
      return Colors.green.shade400; // Very close to golden ratio
    } else if (difference < 0.2) {
      return Colors.amber.shade400; // Somewhat close
    } else {
      return Colors.deepOrange.shade400; // Further from golden ratio
    }
  }

  Widget _buildRatioGauge() {
    const double idealRatio = 1.618;
    double percentage = 100 - ((goldenratio - idealRatio).abs() / idealRatio * 100);
    percentage = percentage.clamp(0, 100);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.purple.shade200,
                    Colors.purple.shade600,
                  ],
                  stops: [0.0, percentage / 100],
                  startAngle: 3 * pi / 2,
                  endAngle: 7 * pi / 2,
                ),
              ),
            ),
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    goldenratio.toStringAsFixed(3),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _getRatioColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Your Ratio",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Ideal Ratio: ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const Text(
              "1.618",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Colors.purple.shade400,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Recommendation",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _result,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purple.withOpacity(_animation.value),
                    width: 6,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.face,
                      size: 50,
                      color: Colors.purple.withOpacity(_animation.value),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "Analyzing facial proportions...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
           Get.back();
          },
        ),
        title: const Text(
          "Golden Ratio Analyzer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        
      ),
      body: _isLoading
          ? _buildLoadingView()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: _buildRatioGauge(),
                    ),
                    const SizedBox(height: 20),
                    _buildRecommendationCard(),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.purple.shade400,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "About the Golden Ratio",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "The Golden Ratio (approximately 1.618) has been used throughout history as a measure of ideal facial proportions. It's considered to create a balanced and aesthetically pleasing appearance.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}