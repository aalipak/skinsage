import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:get/get.dart';
import 'package:skinsage/screens/home.dart';
import 'package:skinsage/widgets/circular_percent_indicator.dart';
import '../widgets/recommendations/recommendation_slider.dart';
import 'camera_controller.dart';
import '../services/local_auth_service.dart';
import '../services/health_score_history_service.dart';

class AnalysisResultsScreen extends StatelessWidget {
  final CameraStateController cameraStateController =
      Get.put(CameraStateController());
  final Map<String, double> skinConditions;
  final List<String> gradCamPaths;
  late double overallSkinHealth;

  AnalysisResultsScreen({super.key, required this.skinConditions, required this.gradCamPaths});

  double calculateSkinHealthScore(double confidence) {
    return 100 - (confidence * 100);
  }

  double calculateOverallSkinHealth() {
    if (skinConditions.isEmpty) return 0;
    double totalScore = 0;
    skinConditions.forEach((_, confidence) {
      totalScore += calculateSkinHealthScore(confidence);
    });
    cameraStateController.overallSkinHealth = totalScore / skinConditions.length;
    return totalScore / skinConditions.length;
  }

  String getSkinHealthStatus(double score) {
    if (score >= 90) return "Excellent";
    if (score >= 70) return "Good";
    if (score >= 50) return "Fair";
    if (score >= 30) return "Poor";
    return "Critical";
  }

  void saveAnalysisToHistory() {
    final authService = Get.find<LocalAuthService>();
    final healthScoreHistoryService = Get.find<HealthScoreHistoryService>();

    // Generate personalized recommendations based on skin conditions
    List<String> recommendations = [];
    skinConditions.forEach((condition, confidence) {
      if (confidence > 0.7) {
        recommendations.add("Consult a dermatologist for $condition.");
      } else if (confidence > 0.4) {
        recommendations.add("Use skincare products targeting $condition.");
      } else {
        recommendations.add("Maintain a healthy skincare routine to prevent $condition.");
      }
    });

    final result = {
      'timestamp': DateTime.now().toIso8601String(),
      'score': overallSkinHealth,
      'skinTone': cameraStateController.currentSkinTone,
      'concerns': skinConditions.keys.toList(),
      'recommendations': recommendations,
    };

    // Save the analysis result to local storage
    authService.saveAnalysisResult(result);

    // Save the health score to the history
    healthScoreHistoryService.addMeasurement(overallSkinHealth);
  }

  @override
  Widget build(BuildContext context) {
    overallSkinHealth = calculateOverallSkinHealth();
    saveAnalysisToHistory();
    List<Map<String, String>> recommendations = [
      {
        'title': 'Guide to properly washing your face',
        'imagePath': 'assets/images/guide_image.jpg',
      },
      {
        'title': 'Guide to properly washing your face',
        'imagePath': 'assets/images/guide_image1.jpg',
      },
    ];

    // Get only the latest 6 GradCAM paths (or fewer if less than 6 are available)
    List<String> latestGradCams = [];
    if (gradCamPaths.length > 6) {
      // Take the last 6 elements
      latestGradCams = gradCamPaths.sublist(gradCamPaths.length - 6);
      debugPrint("Analysis Grad-CAM Paths: $gradCamPaths");
      
    } else {
      // Take all elements if there are 6 or fewer
      latestGradCams = List.from(gradCamPaths);
       debugPrint("Analysis Grad-CAM Paths: $gradCamPaths");

    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.to(() => HomeScreen());
          },
        ),
        title: const Text(
          "Skin Analysis Results",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4A1A56), // Deeper purple
              Color(0xFF8C41A6), // Lighter purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success message card
                  _buildSuccessCard(),
                  const SizedBox(height: 24),
                  
                  // Overall Skin Health Score Card
                  _buildOverallHealthCard(overallSkinHealth),
                  const SizedBox(height: 24),
                  
                  // Section title for conditions
                  _buildSectionTitle("Detected Conditions"),
                  const SizedBox(height: 16),
                  
                  // Individual condition cards with index-based gradCam
                  ...skinConditions.entries.toList().asMap().entries.map((entry) {
                    int index = entry.key; // This gives us the index in the list
                    MapEntry<String, double> condition = entry.value;
                    return _buildAnalysisCard(condition.key, condition.value, index);
                  }),
                  const SizedBox(height: 32),
                  
                  // Recommendations section
                  _buildSectionTitle("Personalized Recommendations"),
                  const SizedBox(height: 16),
                  RecommendationSlider(recommendations: recommendations),
                  // const SizedBox(height: 32),

                  // // Face landmarks button
                  // Center(
                  //   child: _buildFaceLandmarksButton(context),
                  // ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Your skin analysis is complete!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildOverallHealthCard(double overallScore) {
    String healthStatus = getSkinHealthStatus(overallScore);
    Color statusColor = _getStatusColor(healthStatus);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "OVERALL SKIN HEALTH",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularPercentIndicator(
                  percentage: overallScore,
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${overallScore.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        healthStatus,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getHealthDescription(healthStatus),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHealthDescription(String status) {
    switch (status) {
      case "Excellent":
        return "Your skin is in great condition! Keep up your current skincare routine.";
      case "Good":
        return "Your skin is healthy with minor concerns. Small improvements to your routine could help.";
      case "Fair":
        return "Your skin has some issues that need attention. Check our recommendations.";
      case "Poor":
        return "Your skin needs significant care. Follow our detailed recommendations.";
      case "Critical":
        return "Your skin requires immediate attention. Consider consulting a dermatologist.";
      default:
        return "";
    }
  }

  Widget _buildAnalysisCard(String label, double percentage, int index) {
  double skinHealthScore = calculateSkinHealthScore(percentage);
  String severity = _getSeverityLevel(skinHealthScore);
  Color severityColor = _getSeverityColor(skinHealthScore);

  return GestureDetector(
    onTap: () {
      // Use the filtered Grad-CAM paths
      List latestGradCamPaths = getLatestGradCamPaths();
      if (index < latestGradCamPaths.length) {
        _showGradCamDialog(label, index, latestGradCamPaths.cast<String>());
      } else {
        Get.snackbar(
          "Please Wait!",
          "Let the model analyse the image first.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
        );
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with condition name and icon
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.visibility,
                  color: Colors.purple[300],
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  "View details",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Score display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircularPercentIndicator(percentage: skinHealthScore),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${skinHealthScore.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          severity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: severityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: skinHealthScore / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(severityColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ),
  );
}

  String _getSeverityLevel(double score) {
    if (score >= 80) return "Minimal";
    if (score >= 60) return "Mild";
    if (score >= 40) return "Moderate";
    if (score >= 20) return "Severe";
    return "Critical";
  }

  Color _getSeverityColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.amber;
    if (score >= 20) return Colors.orange;
    return Colors.red;
  }

List getLatestGradCamPaths() {
  // Ensure only the last 6 Grad-CAMs are used
  return gradCamPaths.length > 6
      ? gradCamPaths.sublist(gradCamPaths.length - 6)
      : gradCamPaths;
}

  void _showGradCamDialog(String label, int index, List<String> latestGradCamPaths) async {
  double skinHealthScore = calculateSkinHealthScore(skinConditions[label] ?? 0);

  String imagePath;
  if (skinHealthScore < 60) {
    // Use Grad-CAM image if health score is less than 50
    if (index < 0 || index >= latestGradCamPaths.length) {
      Get.snackbar(
        "Error",
        "No Grad-CAM #$index available for $label",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
      );
      return;
    }
    imagePath = latestGradCamPaths[index];
  } else {
    // Use the original image if health score is 50 or higher
    if (cameraStateController.imge != null) {
      // Convert img.Image to flutter.Image
      flutter.Image flutterImage = cameraStateController.convertToFlutterImage(cameraStateController.imge!);

      // Convert flutter.Image to File
      File imageFile = await cameraStateController.convertImageToFile(flutterImage, 'processed_image.png');
      imagePath = imageFile.path;
    } else {
      // Handle the case where the image is null
      Get.snackbar(
        "Error",
        "No image available to process.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
      );
      return;
    }
  }

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  "Analysis for $label",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
          ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      skinHealthScore < 50
                          ? "This heatmap shows areas where $label was detected on your skin."
                          : "This is the original image as the health score is satisfactory.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          );
}

  Color _getStatusColor(String status) {
    switch (status) {
      case "Excellent":
        return Colors.green[700]!;
      case "Good":
        return Colors.green[400]!;
      case "Fair":
        return Colors.amber[700]!;
      case "Poor":
        return Colors.orange[700]!;
      case "Critical":
        return Colors.red[700]!;
      default:
        return Colors.black;
    }
  }

}