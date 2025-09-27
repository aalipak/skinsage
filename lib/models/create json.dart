import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> createSkinAnalysisJson() async {
  // Define the data
  final Map<String, dynamic> skinAnalysisData = {
    "user_name": "ABC",
    "user_email": "abc@gmail.com",
    "age": 26,
    "gender": "Female",
    "dob": "1998-06-21",
    "skin_health": "78",
    "skin_conditions": {
      "acne": {"present": true, "confidence": 0.92},
      "blackheads": {"present": false, "confidence": 0.12},
      "darkspots": {"present": true, "confidence": 0.85},
      "enlarged_pores": {"present": false, "confidence": 0.18},
      "eyebags": {"present": true, "confidence": 0.77},
      "wrinkles": {"present": false, "confidence": 0.25}
    },
    "skin_tone": 4,
    "golden_ratio_score": 1.55,
    "skin_age": 26,
    "localization": {
      "acne": [
        {"x": 40, "y": 85}
      ],
      "darkspots": [
        {"x": 130, "y": 90}
      ],
      "eyebags": [
        {"x": 70, "y": 110}
      ]
    },
    "recommendations": {
      "cleansing": "Use a gentle foaming cleanser with salicylic acid.",
      "moisturizing": "Use an oil-free moisturizer to prevent clogged pores.",
      "treatment": "Consider using benzoyl peroxide or a salicylic acid treatment for acne."
    }
  };

  try {
    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/skin_analysis.json';

    // Convert the data to JSON and save it to a file
    final file = File(filePath);
    await file.writeAsString(jsonEncode(skinAnalysisData));

    print('JSON file created successfully at: $filePath');
  } catch (e) {
    print('Error creating JSON file: $e');
  }
}