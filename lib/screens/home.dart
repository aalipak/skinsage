import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:skinsage/screens/ageresult.dart';
import 'package:skinsage/screens/analysis_results_screen.dart';
import 'package:skinsage/screens/camera_controller.dart';
import 'package:skinsage/screens/chatbot_screen.dart';
import 'package:skinsage/screens/golden_ratio.dart';
import 'package:skinsage/screens/message_view.dart';
import 'package:skinsage/screens/profile_page.dart';
import 'package:skinsage/screens/skin%20type%20results%20screen.dart';
import 'package:skinsage/screens/skin_tone_results_screen.dart';
import 'package:skinsage/widgets/main_drawer.dart';
import 'bottom_nav_bar.dart';
import '../widgets/category_item.dart';

class HomeScreen extends StatelessWidget {
  final CameraStateController cameraStateController =
      Get.find<CameraStateController>();
  final List<Map<String, dynamic>> features = [
    {
      "image": "assets/images/skin_tone.png",
      "label": "Skin Tone Classification"
    },
    {
      "image": "assets/images/skin type.jpg",
      "label": "Skin Type Classification"
    },

    {
      "image": "assets/images/skin_condition_detection.png",
      "label": "Skin Condition Detection"
    },
    {
      "image": "assets/images/skin_age_estimation.png",
      "label": "Skin Age Estimation"
    },
    {"image": "assets/images/facial-landmarks.png",
     "label": "Golden Ratio"},
     {"image": "assets/images/chatbot.jpg",
     "label": "ChatBot"
     },
  ];

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.foundation, "label": "Foundation"},
    {"icon": Icons.wash, "label": "Moisturizer"},
    {"icon": Icons.wb_sunny, "label": "Sunscreen"},
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "SkinSage",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => ProfilePage()));
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/me.jpg'),
              ),
            ),
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The right product for your skin type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Discover the perfect match for your skin",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: categories.map((category) {
                return CategoryItem(
                  icon: category["icon"],
                  label: category["label"],
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _buildFeatureCard(
                    context,
                    features[index]["image"],
                    features[index]["label"],
                  );
                },
              ),
            ),
            BottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "Skin Tone Classification") {
          _handleSkinToneAnalysis(context);
        } else if (label == "Skin Condition Detection") {
          _handleSkinConditionAnalysis(context);
        } else if (label == "Golden Ratio") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FaceGoldenRatio(),
            ),
          );
        } else if (label == "Skin Age Estimation") {
          cameraStateController.skinAge = 0;
          cameraStateController.processSkinAge();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkinAgeResults(),
            ),
          );
        }
        else if (label == "Skin Type Classification") {
          _handleSkinTypeAnalysis(context);
        }
        else if (label == "ChatBot") {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatbotScreen(),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handler for skin tone analysis
  void _handleSkinToneAnalysis(BuildContext context) async {
    // Navigate to the loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>MessageScreen(message: "Analyzing, Hold tight!",
                  icon: CircularProgressIndicator(color: Colors.pink),),
      ),
    );

    // Reset skin tone values before starting new analysis
    cameraStateController.currentSkinTone = '';
    cameraStateController.skinToneConfidence.value = 0.0;
    cameraStateController.isAnalysisComplete.value = false;

    await cameraStateController.processtone();

    // Navigate to the results screen or pop the loading screen
    Navigator.pop(context); // Remove the loading screen
    if (cameraStateController.currentSkinTone.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkinToneResultsScreen(
            skinTone: cameraStateController.currentSkinTone,
            tonePercentage: cameraStateController.skinToneConfidence.value,
          ),
        ),
      );
    } else {
      debugPrint("Skin tone analysis failed or returned empty results.");
    }
  }

  // Handler for skin condition analysis
  void _handleSkinConditionAnalysis(BuildContext context) async {
    // Navigate to the loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(message: "Analyzing, Hold tight!",
                  icon: CircularProgressIndicator(color: Colors.pink),),
      ),
    );

    // Reset skin condition values before starting new analysis
    cameraStateController.detectedSkinConditions.clear();
    cameraStateController.isAnalysisComplete.value = false;
    await cameraStateController.processcondition();

    // Navigate to the results screen or pop the loading screen
    Navigator.pop(context); // Remove the loading screen
    if (cameraStateController.detectedSkinConditions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultsScreen(
            skinConditions: cameraStateController.detectedSkinConditions,
            gradCamPaths: cameraStateController.gradCamPaths,
          ),
        ),
      );
    } else {
      debugPrint("Skin condition analysis failed or returned empty results.");
    }
  }

  void _handleSkinTypeAnalysis(BuildContext context) async {
    // Navigate to the loading screen
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(message: "Analyzing, Hold tight!",
                  icon: CircularProgressIndicator(color: Colors.pink),),
      ),
    );
    cameraStateController.currentSkinType = '';
    await cameraStateController.processSkinType();
    Navigator.pop(context);

    if(cameraStateController.currentSkinType.isNotEmpty) {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkinTypeResultsScreen(
            skinType: cameraStateController.currentSkinType,
          ),
        ),
      );
    } else {
      debugPrint("Skin Type analysis failed or returned empty results.");
    }
    }
}
    // Get.snackbar(
    //   'Coming Soon!',
    //   'Skin Type Classification is not available yet.',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: const Color.fromARGB(255, 227, 204, 167),
    //   colorText: const Color.fromARGB(255, 91, 68, 13),
    //   duration: Duration(seconds: 2),
    // );