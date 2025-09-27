import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:skinsage/services/local_auth_service.dart';
import '../screens/camera_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';



class SkinReportPage extends StatelessWidget {
  final CameraStateController cameraStateController = Get.find();
  final ScreenshotController screenshotController = ScreenshotController();
  final LocalAuthService _authService = Get.find<LocalAuthService>();
  late final Map<String, dynamic>? user;

  SkinReportPage({super.key}) {
    user = _authService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final int skinTone = cameraStateController.tonescore;
    final String skinType = cameraStateController.currentSkinType;
    // final int skintoneScore = cameraStateController.tonescore ?? 0;
    final int skinAge = cameraStateController.skinAge ?? 0;
    final double goldenRatioScore = cameraStateController.goldenRatio;
    final double skinHealthScore = cameraStateController.overallSkinHealth;
    final InputImage userImage = cameraStateController.inputImage;
    final Map<String, dynamic> skinConditions =
        cameraStateController.detectedSkinConditions ?? {};
    final int userAge = (user != null && user!['age'] != null) ? user!['age'] as int : 0;
    final int ageGap = skinAge - userAge;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Skin Report", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.purple.shade800,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.purple.shade700),
              const SizedBox(height: 20),
              Text(
                "Preparing your report...",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 🧠 Generate Comments
    String ageComment = ageGap > 3
        ? "Your skin appears slightly older than your actual age. Consider boosting hydration and sun protection."
        : ageGap < -3
            ? "Your skin looks younger than your age – great job maintaining your skincare!"
            : "Your skin age is well-aligned with your actual age. Keep up the good routine!";

    String toneComment = skinTone > 7
        ? "Your skin tone suggests high melanin. Don't forget sunscreen to prevent hyperpigmentation."
        : skinTone < 3
            ? "You may have a lighter skin tone – be cautious with sun exposure and use gentle products."
            : "Your skin tone is well-balanced. Maintain a consistent routine to keep it that way.";

    String goldenRatioComment = goldenRatioScore > 0.7
        ? "Your face shows great symmetry based on the golden ratio."
        : "Minor asymmetry is natural. Focus on holistic health and skincare rather than perfection.";

    String healthComment = skinHealthScore < 5
        ? "Skin health is below average. Ensure you're cleansing, moisturizing, and drinking enough water."
        : skinHealthScore > 8
            ? "Excellent skin health! Whatever you're doing, keep it up."
            : "Your skin health is moderate. Consider adding antioxidant-rich serums or lifestyle tweaks.";

    // 📝 Skin Condition-Based Recommendations
    List<String> conditionRecommendations = [];
    skinConditions.forEach((key, value) {
      if ((value as double) > 0.5) {
        switch (key.toLowerCase()) {
          case 'acne':
            conditionRecommendations.add('Try using salicylic acid or niacinamide products to manage acne.');
            break;
          case 'wrinkles':
            conditionRecommendations.add('Consider retinol and hydration-focused products to reduce wrinkles.');
            break;
          case 'blackheads':
            conditionRecommendations.add('Use exfoliants like BHA to clear out pores and reduce blackheads.');
            break;
          case 'dark-spots':
            conditionRecommendations.add('Vitamin C serums or niacinamide can help fade dark spots.');
            break;
          case 'eyebags':
            conditionRecommendations.add('Look into caffeine-based eye creams and better sleep habits.');
            break;
          case 'enlarged-pores':
            conditionRecommendations.add('Clay masks and pore-tightening toners may help.');
            break;
          default:
            conditionRecommendations.add('$key: Consider consulting a dermatologist for better care.');
        }
      }
    });

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            "Skin Analysis Report",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.purple.shade800,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                // Share functionality could be added here
                Get.snackbar(
                  'Share Report',
                  'Report sharing feature coming soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.purple.shade100,
                  colorText: Colors.purple.shade800,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // User image header section
              if (userImage != null)
                Container(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Blurred background
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                        },
                        blendMode: BlendMode.dstIn,
                       
                      ),
                      // Content overlay
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                // User image circle
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.file(
                                      File(userImage.filePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Name and greeting
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hello, ${user!['name'] ?? 'User'}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Here\'s your personalized skin analysis',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Skin Score summary card
                    _buildScoreCard(
                      title: 'Skin Health Overview',
                      score: skinHealthScore,
                      maxScore: 10,
                      color: _getHealthColor(skinHealthScore),
                      icon: Icons.favorite,
                    ),
                    const SizedBox(height: 20),
      
                    // Metrics section
                    _buildSectionHeader('Key Metrics'),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Skin Age',
                            value: '$skinAge',
                            icon: Icons.access_time_rounded,
                            color: Colors.blue.shade700,
                            suffix: ' years',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Skin Tone',
                            value: '$skinTone',
                            icon: Icons.palette_rounded,
                            color: Colors.amber.shade700,
                            suffix: '/10',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Skin Type',
                            value: skinType,
                            icon: Icons.face_rounded,
                            color: Colors.teal.shade700,
                            // color: Colors.green.shade700,
                            suffix: '',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Golden Ratio',
                            value: goldenRatioScore.toStringAsFixed(2),
                            icon: Icons.stay_current_portrait_rounded,
                            color: Colors.purple.shade700,
                            suffix: '/1.618',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Age Gap',
                            value: '$ageGap',
                            icon: Icons.compare_arrows_rounded,
                            color: ageGap > 3 
                                ? Colors.orange.shade700 
                                : ageGap < -3 
                                  ? Colors.green.shade700 
                                  : Colors.blue.shade700,
                            suffix: ' years',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
      
                    // Analysis Comments
                    _buildSectionHeader('Expert Analysis'),
                    const SizedBox(height: 12),
                    _buildCommentCard('Age Analysis', ageComment, Icons.access_time_rounded),
                    const SizedBox(height: 12),
                    _buildCommentCard('Skin Tone', toneComment, Icons.palette_rounded),
                    const SizedBox(height: 12),
                    _buildCommentCard('Facial Symmetry', goldenRatioComment, Icons.stay_current_portrait_rounded),
                    const SizedBox(height: 12),
                    _buildCommentCard('Skin Health', healthComment, Icons.favorite_rounded),
                    const SizedBox(height: 24),
                    _buildCommentCard('Skin Type', _getSkinTypeComment(skinType), Icons.check_circle_rounded), 

                    // Skin Conditions Section
                    if (skinConditions.isNotEmpty) ...[
                      _buildSectionHeader('Detected Skin Conditions'),
                      const SizedBox(height: 12),
                      _buildSkinConditionsCard(skinConditions),
                      const SizedBox(height: 24),
                    ],
      
                    // Recommendations Section
                    if (conditionRecommendations.isNotEmpty) ...[
                      _buildSectionHeader('Personalized Recommendations'),
                      const SizedBox(height: 12),
                      ...conditionRecommendations.map((rec) => _buildRecommendationItem(rec)),
                      const SizedBox(height: 16),
                    ],
                    
                    // Disclaimer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Note: This analysis is for informational purposes only and is not a substitute for professional medical advice.',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
         onPressed: () async {
  try {
    // Get the Downloads directory (Android) or Documents directory (iOS)
    final Directory? downloadsDir = await getDownloadsDirectory();
    final String savePath = '${downloadsDir?.path}/skin_report_${DateTime.now().millisecondsSinceEpoch}.txt';
    
    // Create the report content
    final reportContent = '''
Skin Analysis Report

Name: ${user!['name'] ?? 'User'}
Date: ${DateTime.now()}

Skin Health Score: ${cameraStateController.overallSkinHealth?.toStringAsFixed(1) ?? 'N/A'}/10
Skin Age: ${cameraStateController.skinAge} years
Skin Type: ${cameraStateController.currentSkinType}   Skin Tone: ${cameraStateController.currentSkinTone}
Tone Score: ${cameraStateController.tonescore}/10
Golden Ratio: ${cameraStateController.goldenRatio?.toStringAsFixed(2) ?? 'N/A'}

Detected Conditions:
${_formatSkinConditions(cameraStateController.detectedSkinConditions ?? {})}

Recommendations:
${_formatRecommendations(cameraStateController.detectedSkinConditions ?? {})}

Note: This analysis is for informational purposes only.
''';

    // Write the file
  await File(savePath).writeAsString(reportContent);

  // Call the uploadReport method
  await uploadReport(File(savePath), cameraStateController.imageFile);

    Get.snackbar(
      'Report Saved to: $savePath',
      'Your skin analysis report has been saved successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  } catch (e) {
    print("Error saving file: $e");
    Get.snackbar(
      'Error',
      'Failed to save report: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }
},
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.article_rounded),
          label: Text(
            'Download Report',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

Future<void> uploadReport(File textFile, File? imageFile) async {
  var uri = Uri.parse("https://report-api-228621321547.us-central1.run.app/generate-report");
  
  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('text_file', textFile.path));

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath('image_file', imageFile.path));
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    final bytes = await response.stream.toBytes();

    // Use path_provider to get the documents directory
    final Directory? downloadsDir = await getDownloadsDirectory();
    final String path = '${downloadsDir?.path}/skin_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    

    final file = File(path);
    await file.writeAsBytes(bytes);

    print("✅ PDF saved at: $path");
  } else {
    print("❌ Failed to generate PDF: ${response.statusCode}");
  }
}

String _formatSkinConditions(Map<String, dynamic> conditions) {
  if (conditions.isEmpty) return '  No significant conditions detected';
  
  return conditions.entries.map((entry) {
    final formattedKey = entry.key.split('-').map((word) => 
      word.substring(0, 1).toUpperCase() + word.substring(1)
    ).join(' ');
    return '  $formattedKey: ${_getSeverityText(entry.value as double)} (${(entry.value * 100).toStringAsFixed(0)}%)';
  }).join('\n');
}
String _formatRecommendations(Map<String, dynamic> conditions) {
  final recommendations = <String>[];

  conditions.forEach((key, value) {
    if ((value as double) > 0.5) {
      switch (key.toLowerCase()) {
        case 'acne':
          recommendations.add(
              '  Acne is commonly caused by clogged pores, excess oil production, and bacteria. Consider using skincare products containing salicylic acid to help exfoliate and unclog pores, or niacinamide to reduce inflammation and regulate sebum production. Maintaining a consistent routine and avoiding comedogenic ingredients can also help manage breakouts.');
          break;
        case 'wrinkles':
          recommendations.add(
              '  Wrinkles are a natural part of aging, often resulting from decreased collagen and sun exposure. Incorporate products with retinol, which promotes collagen production, and hydrating ingredients like hyaluronic acid to improve skin elasticity. Consistent sunscreen use is essential in preventing further skin damage.');
          break;
        case 'blackheads':
          recommendations.add(
              '  Blackheads form when pores become clogged with dead skin and oil. Exfoliating with beta hydroxy acids (BHAs), such as salicylic acid, can penetrate deep into the pores to clear blockages. Regular gentle exfoliation and non-comedogenic skincare can help reduce their appearance.');
          break;
        case 'dark-spots':
          recommendations.add(
              '  Dark spots or hyperpigmentation can result from sun damage, acne scars, or hormonal changes. Applying Vitamin C serums can help lighten these spots over time by inhibiting melanin production. Daily use of sunscreen is crucial to prevent worsening pigmentation.');
          break;
        case 'eyebags':
          recommendations.add(
              '  Eyebags can be caused by aging, fluid retention, or lack of sleep. Eye creams that contain caffeine can temporarily reduce puffiness by constricting blood vessels. Adequate sleep, hydration, and a cold compress may also help diminish under-eye swelling.');
          break;
        case 'enlarged-pores':
          recommendations.add(
              '  Enlarged pores are often due to excess oil, aging, or loss of skin elasticity. Using clay masks can help absorb oil and tighten pores temporarily. Incorporating pore-refining toners and consistent exfoliation can help improve the skin’s overall texture.');
          break;
        default:
          recommendations.add(
              '  The condition "$key" was detected with some significance. For a personalized skincare plan, consider consulting a dermatologist who can assess your skin type and recommend targeted treatments.');
      }
    }
  });

  if (recommendations.isEmpty) {
    return '  No specific recommendations based on your analysis';
  }

  return recommendations.join('\n\n');
}
 
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.purple.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required String title,
    required double score,
    required double maxScore,
    required Color color,
    required IconData icon,
  }) {
    final percentage = (score / maxScore * 100).clamp(0, 100);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${score.toStringAsFixed(1)}/$maxScore',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getHealthScoreMessage(score),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(String title, String comment, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinConditionsCard(Map<String, dynamic> conditions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...conditions.entries.map((entry) {
            final double value = entry.value as double;
            final String formattedKey = entry.key.split('-').map((word) => 
              word.substring(0, 1).toUpperCase() + word.substring(1)
            ).join(' ');
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedKey,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        _getSeverityText(value),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _getSeverityColor(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getSeverityColor(value),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: Colors.purple.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthScoreMessage(double score) {
    if (score >= 8) return 'Excellent skin health! Your skin is thriving.';
    if (score >= 6) return 'Good skin health. Minor improvements could help.';
    if (score >= 4) return 'Average skin health. Consider targeted treatments.';
    return 'Your skin needs some attention and care.';
  }

  Color _getHealthColor(double score) {
    if (score >= 8) return Colors.green.shade700;
    if (score >= 6) return Colors.teal.shade700;
    if (score >= 4) return Colors.amber.shade700;
    return Colors.deepOrange.shade700;
  }

  String _getSeverityText(double value) {
    if (value < 0.3) return 'Low';
    if (value < 0.7) return 'Moderate';
    return 'High';
  }

  Color _getSeverityColor(double value) {
    if (value < 0.3) return Colors.green.shade600;
    if (value < 0.7) return Colors.amber.shade600;
    return Colors.red.shade600;
  }
String _getSkinTypeComment(String skinType) {
  switch (skinType.toLowerCase()) {
    case 'normal':
      return 'Your skin type is normal, which means it is well-balanced. Maintain a consistent skincare routine to keep it healthy.';
    case 'oily':
      return 'Your skin type is oily, which may lead to excess shine and clogged pores. Use lightweight, non-comedogenic products and consider incorporating salicylic acid into your routine.';
    case 'dry':
      return 'Your skin type is dry, which may cause flakiness or tightness. Focus on hydrating products like hyaluronic acid and ceramides to restore moisture.';
    default:
      return 'Your skin type is unique. Consider consulting a dermatologist for personalized advice.';
  }
}
}