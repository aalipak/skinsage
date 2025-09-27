import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinsage/screens/home.dart';

class SkinToneResultsScreen extends StatelessWidget {
  final String skinTone;
  final double tonePercentage;

  const SkinToneResultsScreen({
    super.key,
    required this.skinTone,
    required this.tonePercentage,
  });

  double calculateSkinHealthScore(double confidence) {
    return 100 - (confidence * 100);
  }

  @override
  Widget build(BuildContext context) {
    double skinHealthScore = calculateSkinHealthScore(tonePercentage);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF8E24AA),
                Color(0xFFAB47BC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3E5F5),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderSection(skinTone, skinHealthScore),
                const SizedBox(height: 24),
                _buildSkinToneCard(skinTone),
                const SizedBox(height: 20),
                _buildRecommendationSection(skinTone),
                const SizedBox(height: 20),
                _buildNextStepsSection(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String skinTone, double skinHealthScore) {
    final List<String> skinTones = [
      "Very Fair",
      "Fair",
      "Medium",
      "Olive",
      "Tan",
      "Light Brown",
      "Medium Brown",
      "Dark Brown",
      "Black",
      "Deep"
    ];

    int currentToneIndex = skinTones.indexOf(skinTone);
    if (currentToneIndex == -1) {
      for (int i = 0; i < skinTones.length; i++) {
        if (skinTones[i].toLowerCase().contains(skinTone.toLowerCase()) ||
            skinTone.toLowerCase().contains(skinTones[i].toLowerCase())) {
          currentToneIndex = i;
          break;
        }
      }
      if (currentToneIndex == -1) {
        currentToneIndex = skinTones.length ~/ 2;
      }
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9C27B0).withOpacity(0.9),
              const Color(0xFFCE93D8).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              "Your Skin Analysis",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Identified Tone",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        skinTone,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSkinToneSlider(skinTones, currentToneIndex),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinToneSlider(List<String> skinTones, int currentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The slider visualization
        Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF3E0), // Very Fair
                Color(0xFFFFE0B2), // Fair
                Color(0xFFFFCC80), // Medium
                Color(0xFFFFB74D), // Olive
                Color(0xFFFFA726), // Tan
                Color(0xFFFF9800), // Light Brown
                Color(0xFFF57C00), // Medium Brown
                Color(0xFFEF6C00), // Dark Brown
                Color(0xFF5D4037), // Black
                Color(0xFF3E2723), // Deep
              ],
            ),
          ),
        ),

        // Position indicator
        Padding(
          padding: EdgeInsets.only(
            left: (currentIndex / (skinTones.length - 1)) * (100 - 2) +
                1, // 2% margin for triangle
          ),
          // child: const Icon(
          //   Icons.arrow_drop_up,
          //   color: Colors.white,
          //   size: 30,
          // ),
        ),

        // Tone labels
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skinTones.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              skinTones[skinTones.length ~/ 2],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              skinTones.last,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkinToneCard(String skinTone) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  "About Your Skin Tone",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getSkinToneDescription(skinTone),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(String skinTone) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.task_alt,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Recommended Skincare",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              Icons.wb_sunny_outlined,
              "Sun Protection",
              _getSunProtectionAdvice(skinTone),
            ),
            const Divider(height: 30),
            _buildRecommendationItem(
              Icons.water_drop_outlined,
              "Hydration",
              _getHydrationAdvice(skinTone),
            ),
            const Divider(height: 30),
            _buildRecommendationItem(
              Icons.color_lens_outlined,
              "Pigmentation",
              _getPigmentationAdvice(skinTone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.purple,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Next Steps",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNextStepItem(
              "1",
              "Complete your skin profile",
              "Add more information about your skin concerns and routine.",
            ),
            const SizedBox(height: 16),
            _buildNextStepItem(
              "2",
              "Get personalized routine",
              "Based on your skin analysis, we'll recommend products.",
            ),
            const SizedBox(height: 16),
            _buildNextStepItem(
              "3",
              "Track your progress",
              "Check back in a month to see your skin improvements.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Get.to(() => HomeScreen());
            },
            icon: const Icon(Icons.home),
            label: const Text("Return Home"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getSkinToneDescription(String tone) {
    switch (tone.toLowerCase()) {
      case 'fair':
        return 'Your skin has a light complexion with minimal melanin. It\'s important to use sunscreen daily and protect from UV radiation. Your skin may be more prone to redness and sun damage.';
      case 'medium':
        return 'Your skin has a balanced melanin level. While you have some natural protection, sunscreen is still essential for skin health. Your skin tone provides moderate protection against UV damage.';
      case 'olive':
        return 'Your skin has a moderate amount of melanin, providing some natural sun protection. Regular skincare is important for maintaining even tone and preventing hyperpigmentation.';
      case 'brown':
        return 'Your skin has higher melanin content, offering good natural sun protection. Focus on maintaining even skin tone and preventing hyperpigmentation. Your skin may be more resilient to environmental factors.';
      case 'dark':
        return 'Your skin has high melanin content, providing strong natural sun protection. Focus on maintaining skin hydration and preventing uneven tone. Dark skin can be more prone to keloids and hyperpigmentation.';
      default:
        return 'Your skin tone has been analyzed. Regular skincare routine and sun protection are important for maintaining healthy skin regardless of tone.';
    }
  }

  String _getSunProtectionAdvice(String tone) {
    switch (tone.toLowerCase()) {
      case 'fair':
        return 'Apply SPF 50+ daily, reapply every 2 hours when outdoors. Seek shade and wear protective clothing.';
      case 'medium':
        return 'Use SPF 30-50 daily, and reapply every 2-3 hours when exposed to direct sunlight.';
      case 'olive':
        return 'Apply SPF 30 daily, focusing on consistent application rather than higher SPF values.';
      case 'brown':
        return 'Use SPF 30 daily to prevent hyperpigmentation and uneven skin tone.';
      case 'dark':
        return 'Apply SPF 15-30 daily, focusing on broad-spectrum protection to prevent uneven tone.';
      default:
        return 'Apply broad-spectrum sunscreen daily appropriate for your outdoor exposure.';
    }
  }

  String _getHydrationAdvice(String tone) {
    switch (tone.toLowerCase()) {
      case 'fair':
        return '''Look for non-comedogenic moisturizers that won't clog pores. Hyaluronic acid serums are ideal.''';
      case 'medium':
        return 'Balance hydration with lightweight moisturizers. Consider adding a hydrating serum to your routine.';
      case 'olive':
        return 'Use medium-weight moisturizers that balance oil production and hydration needs.';
      case 'brown':
        return '''Focus on rich moisturizers that prevent ashiness and maintain your skin's natural glow.''';
      case 'dark':
        return '''Use emollient-rich moisturizers to prevent ashiness and maintain skin's natural radiance.''';
      default:
        return 'Keep skin hydrated with appropriate moisturizers based on your skin type.';
    }
  }

  String _getPigmentationAdvice(String tone) {
    switch (tone.toLowerCase()) {
      case 'fair':
        return 'Use antioxidants to prevent sun damage and address redness. Vitamin C can help with overall brightness.';
      case 'medium':
        return 'Incorporate gentle exfoliants to prevent dullness and maintain even tone.';
      case 'olive':
        return 'Consider products with niacinamide to help with oil control and uneven pigmentation.';
      case 'brown':
        return 'Look for ingredients like vitamin C, alpha arbutin, and niacinamide to maintain even tone.';
      case 'dark':
        return 'Use targeted treatments with licorice root extract and niacinamide for spot treatment.';
      default:
        return 'Maintain even skin tone with appropriate ingredients based on your specific concerns.';
    }
  }
}
