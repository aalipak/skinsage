import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinsage/screens/home.dart';

class SkinTypeResultsScreen extends StatelessWidget {
  final String skinType;

  const SkinTypeResultsScreen({
    super.key,
    required this.skinType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Skin Type Results",
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
                // Added result label on top
                _buildResultLabel(skinType),
                const SizedBox(height: 20),
                _buildSkinTypeCard(skinType),
                const SizedBox(height: 20),
                _buildConcernsSection(skinType),
                const SizedBox(height: 20),
                _buildRecommendationsSection(skinType),
                const SizedBox(height: 20),
                _buildDailyRoutineSection(skinType),
                const SizedBox(height: 20),
                _buildIngredientSection(skinType),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New widget for result label on top
  Widget _buildResultLabel(String skinType) {
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
              "Your Skin Analysis Result",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getTypeIcon(skinType),
                const SizedBox(width: 10),
                Text(
                  skinType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _getShortSkinTypeSummary(skinType),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New helper method for short skin type summary
  String _getShortSkinTypeSummary(String skinType) {
    switch (skinType.toLowerCase()) {
      case 'normal':
        return 'You have well-balanced skin with good moisture levels';
      case 'oily':
        return 'Your skin produces excess sebum, especially in the T-zone';
      case 'dry':
        return 'Your skin lacks natural oils and needs extra hydration';
      default:
        return 'Your skin requires personalized care based on its characteristics';
    }
  }

  Widget _getTypeIcon(String skinType) {
    switch (skinType.toLowerCase()) {
      case 'normal':
        return const Icon(Icons.check_circle, color: Colors.white, size: 28);
      case 'oily':
        return const Icon(Icons.water_drop, color: Colors.white, size: 28);
      case 'dry':
        return const Icon(Icons.grain, color: Colors.white, size: 28);
      default:
        return const Icon(Icons.face, color: Colors.white, size: 28);
    }
  }

  Widget _buildSkinTypeCard(String skinType) {
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
                  "About Your Skin Type",
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
              _getSkinTypeDescription(skinType),
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

  Widget _buildConcernsSection(String skinType) {
    List<Map<String, dynamic>> concerns = _getSkinConcerns(skinType);

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
                  Icons.warning_amber_outlined,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Common Concerns",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...concerns.map((concern) => _buildConcernItem(
                  concern['icon'] as IconData,
                  concern['title'] as String,
                  concern['description'] as String,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildConcernItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.red,
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
                  description,
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
      ),
    );
  }

  Widget _buildRecommendationsSection(String skinType) {
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
                  "Recommended Approach",
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
              Icons.wash_outlined,
              "Cleansing",
              _getCleansingAdvice(skinType),
            ),
            const Divider(height: 30),
            _buildRecommendationItem(
              Icons.water_drop_outlined,
              "Hydration",
              _getHydrationAdvice(skinType),
            ),
            const Divider(height: 30),
            _buildRecommendationItem(
              Icons.wb_sunny_outlined,
              "Protection",
              _getProtectionAdvice(skinType),
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

  Widget _buildDailyRoutineSection(String skinType) {
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
                  Icons.calendar_today,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Daily Skincare Routine",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRoutineStep(
              "1",
              "Morning",
              _getMorningRoutine(skinType),
            ),
            const SizedBox(height: 16),
            _buildRoutineStep(
              "2", 
              "Evening",
              _getEveningRoutine(skinType),
            ),
            const SizedBox(height: 16),
            _buildRoutineStep(
              "3",
              "Weekly",
              _getWeeklyRoutine(skinType),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
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
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientSection(String skinType) {
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
                  Icons.science_outlined,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Beneficial Ingredients",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getBeneficialIngredients(skinType).map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ingredients to Avoid",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getIngredientsToAvoid(skinType).map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
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

  String _getSkinTypeDescription(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return 'You have balanced skin that is neither too oily nor too dry. Your skin typically has a smooth texture, good circulation, small pores, and an overall radiant complexion. Normal skin is generally not sensitive and tends to have fewer imperfections.';
      case 'oily':
        return 'Your skin produces excess sebum, resulting in a shiny appearance, especially in the T-zone (forehead, nose, and chin). Oily skin is characterized by enlarged pores, a thicker texture, and a greater tendency toward blackheads, whiteheads, and acne. However, oily skin often ages well with fewer wrinkles.';
      case 'dry':
        return 'Your skin produces less sebum than normal skin, leading to a lack of moisture and natural oils. Dry skin can feel tight, rough, and may show flaking or peeling. It\'s more prone to fine lines, redness, and irritation, especially in harsh weather conditions or after using certain skincare products.';
      default:
        return 'Your skin type has been analyzed. Following a consistent skincare routine tailored to your specific needs is essential for maintaining healthy skin.';
    }
  }

  List<Map<String, dynamic>> _getSkinConcerns(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return [
          {
            'icon': Icons.wb_sunny_outlined,
            'title': 'Environmental Damage',
            'description': 'Even balanced skin needs protection from pollution, UV radiation, and climate changes.'
          },
          {
            'icon': Icons.access_time,
            'title': 'Early Signs of Aging',
            'description': 'Prevention is key to maintaining your balanced skin as fine lines may begin to appear.'
          },
          {
            'icon': Icons.thermostat,
            'title': 'Seasonal Changes',
            'description': 'Your skin may become drier in winter and more combination-like in summer.'
          }
        ];
      case 'oily':
        return [
          {
            'icon': Icons.brightness_high,
            'title': 'Excess Shine',
            'description': 'Overproduction of sebum leads to a shiny appearance, especially in the T-zone.'
          },
          {
            'icon': Icons.circle,
            'title': 'Enlarged Pores',
            'description': 'Pores can appear larger due to increased oil production and potential clogging.'
          },
          {
            'icon': Icons.warning,
            'title': 'Acne & Breakouts',
            'description': 'Excess oil can combine with dead skin cells, leading to clogged pores and breakouts.'
          }
        ];
      case 'dry':
        return [
          {
            'icon': Icons.grain,
            'title': 'Flaking & Roughness',
            'description': 'Lack of moisture can cause visible flaking, peeling, and a rough texture.'
          },
          {
            'icon': Icons.straighten,
            'title': 'Tightness & Discomfort',
            'description': 'Your skin may feel tight and uncomfortable, especially after cleansing.'
          },
          {
            'icon': Icons.line_style,
            'title': 'Premature Aging',
            'description': 'Dry skin can show fine lines and wrinkles earlier due to lack of natural oils.'
          }
        ];
      default:
        return [
          {
            'icon': Icons.help_outline,
            'title': 'General Concerns',
            'description': 'Each skin type has specific concerns that need targeted care.'
          }
        ];
    }
  }

  String _getCleansingAdvice(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return 'Use a gentle, pH-balanced cleanser twice daily. Avoid harsh soaps that can disrupt your skin\'s natural balance. Look for cleansers with hydrating ingredients.';
      case 'oily':
        return 'Choose a foaming or gel cleanser with salicylic acid or benzoyl peroxide. Cleanse twice daily, but don\'t overdo it as excessive cleansing can trigger more oil production.';
      case 'dry':
        return 'Opt for cream or oil-based cleansers that don\'t strip natural oils. Consider cleansing only once daily (evening) and using just water or a gentle hydrating toner in the morning.';
      default:
        return 'Use a cleanser appropriate for your skin type to remove impurities without disrupting the skin barrier.';
    }
  }

  String _getHydrationAdvice(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return 'Choose a lightweight, balanced moisturizer. Layer with hydrating serums containing ingredients like hyaluronic acid when needed. Adapt your moisturizer seasonal changes.';
      case 'oily':
        return 'Use oil-free, non-comedogenic gel moisturizers. Don\'t skip moisturizing as it\'s essential even for oily skin - dehydration can trigger more oil production.';
      case 'dry':
        return 'Apply rich, emollient creams containing ceramides, fatty acids, and natural oils. Consider layering with hydrating serums and using facial oils. Reapply moisturizer throughout the day if needed.';
      default:
        return 'Proper hydration is essential for all skin types to maintain the skin barrier and overall health.';
    }
  }

  String _getProtectionAdvice(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return 'Apply broad-spectrum SPF 30+ daily, even on cloudy days. Use antioxidant serums to protect against environmental damage. Reapply sunscreen every 2 hours when outdoors.';
      case 'oily':
        return 'Choose oil-free, mattifying sunscreens labeled "non-comedogenic." Consider powder sunscreens for touch-ups without adding shine. Look for formulations with zinc oxide.';
      case 'dry':
        return 'Use moisturizing sunscreens with hydrating ingredients. Consider sunscreen balms or creams with added skin barrier support. Avoid alcohol-based formulations that can be drying.';
      default:
        return 'Sun protection is crucial for all skin types to prevent damage, premature aging, and skin cancer risk.';
    }
  }

  String _getMorningRoutine(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return '1. Gentle cleanser\n2. Antioxidant serum (optional)\n3. Light moisturizer\n4. SPF 30+ sunscreen';
      case 'oily':
        return '1. Foaming cleanser\n2. Oil-control toner\n3. Lightweight gel moisturizer\n4. Oil-free sunscreen';
      case 'dry':
        return '1. Cream cleanser or just water rinse\n2. Hydrating toner\n3. Hyaluronic acid serum\n4. Rich moisturizer\n5. SPF 30+ sunscreen';
      default:
        return 'Cleanse, moisturize, and protect with SPF daily.';
    }
  }

  String _getEveningRoutine(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return '1. Makeup remover (if needed)\n2. Gentle cleanser\n3. Treatment product (vitamin C or retinol)\n4. Night moisturizer';
      case 'oily':
        return '1. Oil-based cleanser (double cleansing)\n2. Exfoliating cleanser with salicylic acid\n3. Treatment serum (niacinamide or retinol)\n4. Light oil-free moisturizer';
      case 'dry':
        return '1. Oil cleanser\n2. Cream cleanser\n3. Hydrating toner/essence\n4. Treatment serum\n5. Rich night cream\n6. Facial oil (optional)';
      default:
        return 'Evening routines focus on repair and recovery.';
    }
  }

  String _getWeeklyRoutine(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return '1-2 times weekly: Gentle exfoliation\nOnce weekly: Hydrating mask';
      case 'oily':
        return '2-3 times weekly: Chemical exfoliation with BHA\nOnce weekly: Clay or charcoal mask';
      case 'dry':
        return 'Once weekly: Gentle exfoliation\n2-3 times weekly: Hydrating or overnight mask';
      default:
        return 'Weekly treatments provide deeper care based on specific needs.';
    }
  }

  List<String> _getBeneficialIngredients(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return [
          'Hyaluronic Acid',
          'Vitamin C',
          'Niacinamide',
          'Peptides',
          'Green Tea Extract',
          'Ceramides'
        ];
      case 'oily':
        return [
          'Salicylic Acid',
          'Niacinamide',
          'Tea Tree Oil',
          'Retinol',
          'Zinc PCA',
          'Clay',
          'Glycolic Acid'
        ];
      case 'dry':
        return [
          'Hyaluronic Acid',
          'Ceramides',
          'Squalane',
          'Glycerin',
          'Shea Butter',
          'Oils (Jojoba, Argan)',
          'Lactic Acid'
        ];
      default:
        return ['Hyaluronic Acid', 'Niacinamide', 'Vitamin C', 'SPF'];
    }
  }

  List<String> _getIngredientsToAvoid(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return [
          'Harsh Alcohols',
          'Fragrance',
          'Sodium Lauryl Sulfate'
        ];
      case 'oily':
        return [
          'Comedogenic Oils',
          'Petroleum',
          'Cocoa Butter',
          'Isopropyl Myristate'
        ];
      case 'dry':
        return [
          'Alcohol Denat',
          'Sodium Lauryl Sulfate',
          'High concentrations of AHAs',
          'Fragrance',
          'Menthol'
        ];
      default:
        return ['Harsh Alcohols', 'Fragrance', 'Sulfates'];
    }
  }
}