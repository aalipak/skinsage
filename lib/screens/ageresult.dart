import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:skinsage/model_controller.dart';
import 'package:skinsage/screens/camera_controller.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:intl/intl.dart';
import 'package:skinsage/services/skin_age_history_service.dart';
import 'package:skinsage/models/skin_age_history.dart';

class SkinAgeResults extends StatelessWidget {
  final CameraStateController cameraStateController =
      Get.find<CameraStateController>();
  final ModelController modelController = Get.find<ModelController>();
  final SkinAgeHistoryService _historyService = Get.find<SkinAgeHistoryService>();

  SkinAgeResults({Key? key}) : super(key: key) {
    _saveMeasurement();
  }

  void _saveMeasurement() async {
    await _historyService.addMeasurement(cameraStateController.skinAge);
  }

  void analyzeAgeAndGender() {
    if (modelController.ageInterpreter != null) {
      const inputSize = 160;
      final resizedImage = img.copyResize(
        cameraStateController.faceArea!,
        width: inputSize,
        height: inputSize,
      );

      Float32List inputArray = Float32List(1 * inputSize * inputSize * 3);
      int pixelIndex = 0;

      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixelSafe(x, y); // Use getPixelSafe
          inputArray[pixelIndex] = img.getRed(pixel) / 255.0;
          inputArray[pixelIndex + 1] = img.getGreen(pixel) / 255.0;
          inputArray[pixelIndex + 2] = img.getBlue(pixel) / 255.0;
          pixelIndex += 3;
          
        }
      }

      var input = inputArray.reshape([1, inputSize, inputSize, 3]);
      var output = List.filled(1, 0.0).reshape([1, 1]);

      try {
        modelController.ageInterpreter!.run(input, output);
      } catch (e) {
        debugPrint('Error during inference: $e');
      }

      cameraStateController.skinAge = output[0][0].round();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Custom color scheme
    final primaryColor = Color(0xFF8E44AD); // Rich purple
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Color(0xFFF8F0FE);
    final cardColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF333333);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Results",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                
                // User face preview
                if (cameraStateController.faceArea != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.memory(
                        Uint8List.fromList(img.encodePng(cameraStateController.faceArea!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                SizedBox(height: 30),
                
                // Results card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Your Skin Age",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "${cameraStateController.skinAge}",
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "years",
                            style: TextStyle(
                              fontSize: 20,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Recommendations summary
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Colors.grey[850]
                              : primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: primaryColor,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "We've prepared personalized skincare recommendations based on your results.",
                                style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Skin Age Information Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.12),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Understanding Skin Age",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      Text(
                        "Skin age can differ from your chronological age due to various factors:",
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Factors section with expandable panels
                      ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          "When Skin Age Is Higher",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        children: [
                          _buildBulletPoint("Excessive sun exposure without protection", textColor),
                          _buildBulletPoint("Smoking and tobacco use", textColor),
                          _buildBulletPoint("Poor nutrition lacking in antioxidants", textColor),
                          _buildBulletPoint("Chronic stress levels", textColor),
                          _buildBulletPoint("Insufficient hydration", textColor),
                          _buildBulletPoint("Environmental pollution exposure", textColor),
                          _buildBulletPoint("Irregular skincare routine", textColor),
                        ],
                      ),
                      
                      Divider(height: 24, thickness: 0.5, color: textColor.withOpacity(0.2)),
                      
                      ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          "When Skin Age Is Lower",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        children: [
                          _buildBulletPoint("Consistent sun protection", textColor),
                          _buildBulletPoint("Balanced diet rich in antioxidants", textColor),
                          _buildBulletPoint("Regular exercise improving circulation", textColor),
                          _buildBulletPoint("Consistent appropriate skincare", textColor),
                          _buildBulletPoint("Adequate hydration", textColor),
                          _buildBulletPoint("Good genetics", textColor),
                          _buildBulletPoint("Effective stress management", textColor),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Action buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to recommendations screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "View Skincare Recommendations",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    OutlinedButton(
                      onPressed: () {
                        Get.to(() => SkinAgeHistoryScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "View History",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to create bullet points
  Widget _buildBulletPoint(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•  ",
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkinAgeHistoryScreen extends StatelessWidget {
  final SkinAgeHistoryService _historyService = Get.find<SkinAgeHistoryService>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF8E44AD);
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Color(0xFFF8F0FE);
    final cardColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF333333);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Skin Age History",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: primaryColor),
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<SkinAgeHistory>>(
        future: _historyService.getMeasurements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No history yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your skin age measurements will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildProgressCard(history, cardColor, textColor, primaryColor),
                  SizedBox(height: 30),
                  Text(
                    "Measurement History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return _buildHistoryItem(
                          context,
                          _formatDate(item.date),
                          item.age,
                          item.change,
                          isDarkMode,
                          primaryColor,
                          cardColor,
                          textColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('MMMM d, y').format(date);
  }

  Widget _buildProgressCard(
    List<SkinAgeHistory> history,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    final latestAge = history.isNotEmpty ? history.first.age : 0;
    final oldestAge = history.length > 1 ? history.last.age : latestAge;
    final totalChange = latestAge - oldestAge;
    final averageAge = history.isEmpty
        ? 0
        : history.map((e) => e.age).reduce((a, b) => a + b) / history.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat(
                "Latest",
                "$latestAge",
                "years",
                true,
                isHighlighted: true,
              ),
              _buildProgressStat(
                "Change",
                "${totalChange >= 0 ? '+' : ''}$totalChange",
                "overall",
                true,
                isChange: true,
              ),
              _buildProgressStat(
                "Average",
                "${averageAge.toStringAsFixed(1)}",
                "years",
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String date,
    int age,
    int? change,
    bool isDarkMode,
    Color primaryColor,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$age",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Skin age measurement",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    if (change != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getChangeColor(change).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${change >= 0 ? '+' : ''}$change",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getChangeColor(change),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getChangeColor(int change) {
    if (change > 0) return Colors.red;
    if (change < 0) return Colors.green;
    return Colors.blue;
  }

  Widget _buildProgressStat(
    String label,
    String value,
    String subtext,
    bool isDarkMode, {
    bool isHighlighted = false,
    bool isChange = false,
  }) {
    Color valueColor;
    if (isChange) {
      if (value.startsWith('-')) {
        valueColor = Colors.green;
      } else if (value == '0') {
        valueColor = Colors.grey;
      } else {
        valueColor = Colors.red;
      }
    } else {
      valueColor = isHighlighted ? Color(0xFF8E44AD) : Colors.grey[800]!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtext,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text('Are you sure you want to clear all skin age history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _historyService.clearHistory();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
