import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:skinsage/screens/message_view.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:skinsage/model_controller.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:image/image.dart' as img;

class CameraStateController extends GetxController {
  RxBool isProcessing = false.obs;
  RxBool isCameraInitialized = false.obs;
  RxBool isFaceDetected = false.obs;
  RxBool isError = false.obs;
  RxBool isAnalysisComplete = false.obs;
  late CameraController cameraController;
  late double overallSkinHealth=0;
  late double goldenRatio=0;
  late String currentSkinTone = '';
  late String currentSkinType = '--';
  Rx<Rect> faceBox = const Rect.fromLTWH(0, 0, 0, 0).obs;
  RxDouble skinConditionConfidence = 0.0.obs;
  RxDouble skinToneConfidence = 0.0.obs;
  late File? imageFile;
  late double estimatedAge;
  late int skinAge=0;
  late int tonescore=0;
  late img.Image? imge;
   late List<String> gradCamPaths;
  late Uint8List imageBytes;
  // Store all detected skin conditions with their confidence values
  Map<String, double> detectedSkinConditions = {};
  Map<String, double> detectedSkinTone = {};
  RxBool isFacePositionConfirmed = false.obs;
  late img.Image? faceArea;
  ModelController modelController = Get.find<ModelController>();
  // Coordinates for the bounding box
  static const double boxTop = -350;
  static const double boxLeft = 100.0;
  static const double boxWidth = 230.0;
  static const double boxHeight = 230.0;
  late Face faces;
  late InputImage inputImage;
  int ageAsInt = 0;

  Image convertToFlutterImagee(img.Image image) {
    // Convert img.Image to PNG byte data
    List<int> imageBytes = img.encodePng(image);
    return Image.memory(Uint8List.fromList(imageBytes));
  }

  flutter.Image convertImgToFlutterImage(img.Image image) {
    // Convert img.Image to PNG byte data
    final List<int> imageBytes = img.encodePng(image);

    // Create a flutter.Image widget from the byte data
    return flutter.Image.memory(
      Uint8List.fromList(imageBytes),
      fit: BoxFit.cover,
    );
  }

  flutter.Image convertToFlutterImage(img.Image image) {
    // Convert img.Image to Flutter's Image widget
    return convertImgToFlutterImage(image);
  }



  Future<void> initializeCamera() async {
    debugPrint('hex-Initializing camera...');
    isFaceDetected.value = false;
    isCameraInitialized.value = true;
  }

  String _getSkinToneLabel(int index) {
    final labels = [
      "Very Fair with Cool Undertones",
        "Fair with Neutral Undertones",
        "Fair with Warm Undertones",
        "Light Beige with Yellow Undertones",
        "Light-Medium with Olive Undertones",
        "Medium with Golden Undertones",
        "Tan with Warm Undertones",
        "Deep Tan with Red Undertones",
        "Dark with Neutral Undertones",
        "Deep Dark with Cool Undertones"
    ];
    return labels[index];
  }

  String _getConditionLabel(int index) {
    final labels = [
      'Acne',
      'Blackheads',
      'Dark-Spots',
      'Enlarged-Pores',
      'Eyebags',
      'Wrinkles'
    ];
    return labels[index];
  }

  String _getSkinTypeLabel(int index) {
    final labels = [
      'Normal',
      'Oily',
      'Dry',
    ];
    return labels[index];
  }

  Future<img.Image?> convertInputImageToImg(InputImage inputImage) async {
    List<int>? bytes;

    if (inputImage.bytes != null) {
      bytes = inputImage.bytes!.toList(); // Convert Uint8List to List<int>
    } else if (inputImage.filePath != null) {
      bytes = await File(inputImage.filePath!)
          .readAsBytes(); // Read file as List<int>
    }

    if (bytes != null) {
      return img.decodeImage(bytes); // Decode image using image package
    }

    return null; // Return null if conversion fails
  }

  Future<img.Image> cropBoundingBox(InputImage image, Rect boundingBox) async {
   
    
    final left = boundingBox.left.toInt();
    final top = boundingBox.top.toInt();
    final right = boundingBox.right.toInt();
    final bottom = boundingBox.bottom.toInt();
    imge = await convertInputImageToImg(image);

    if (imge != null) {
      img.Image croppedFace =
          img.copyCrop(imge!, left, top, right - left, bottom - top);
    faceArea = croppedFace;
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/face_${DateTime.now().millisecondsSinceEpoch}.png';
    imageFile = File(filePath);
    await imageFile!.writeAsBytes(img.encodePng(faceArea!));
    await uploadImage(imageFile!);
      return croppedFace;
    } else {
      throw Exception('Failed to convert input image to img.Image');
    }
  }
Future<File> convertImageToFilee(Image image, String fileName) async {
  try {
    // Extract the ImageProvider from the Image widget
    final ImageProvider imageProvider = image.image;

    // Resolve the image to get its bytes
    final ByteData byteData = await _getImageByteData(imageProvider);

    // Get the temporary directory to save the file
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$fileName';

    // Write the bytes to a file
    final File file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file;
  } catch (e) {
    throw Exception("Failed to convert image to file: $e");
  }
}

Future<File> convertImageToFile(flutter.Image image, String fileName) async {
  try {
    // Extract the ImageProvider from the Flutter Image widget
    final flutter.ImageProvider imageProvider = image.image;

    // Resolve the image to get its bytes
    final ByteData byteData = await _getImageByteData(imageProvider);

    // Get the temporary directory to save the file
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$fileName';

    // Write the bytes to a file
    final File file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file;
  } catch (e) {
    throw Exception("Failed to convert image to file: $e");
  }
}

Future<ByteData> _getImageByteData(ImageProvider imageProvider) async {
  final ImageConfiguration config = ImageConfiguration();
  final Completer<ByteData> completer = Completer<ByteData>();

  imageProvider.resolve(config).addListener(
    ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) async {
      final ByteData? byteData =
          await imageInfo.image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        completer.complete(byteData);
      } else {
        completer.completeError("Failed to get byte data from image.");
      }
    }),
  );

  return completer.future;
}
  Future<void> processSkinTone() async {
    debugPrint('Starting skin tone analysis...');

    if (modelController.skinToneInterpreter != null) {
      debugPrint('Starting skin tone analysis.');
      const toneInputSize = 224;
      final toneImage = img.copyResize(
        faceArea!,
        width: toneInputSize,
        height: toneInputSize,
      );

      Float32List toneInputArray =
          Float32List(1 * toneInputSize * toneInputSize * 3);
      int tonePixelIndex = 0;
      for (int y = 0; y < toneInputSize; y++) {
        for (int x = 0; x < toneInputSize; x++) {
          final pixel = toneImage.getPixel(x, y);
          toneInputArray[tonePixelIndex] = img.getRed(pixel) / 255.0;
          toneInputArray[tonePixelIndex + 1] = img.getGreen(pixel) / 255.0;
          toneInputArray[tonePixelIndex + 2] = img.getBlue(pixel) / 255.0;
          tonePixelIndex += 3;
        }
      }

      var toneInput =
          toneInputArray.reshape([1, toneInputSize, toneInputSize, 3]);
      var toneOutput =
          List<List<double>>.filled(1, List<double>.filled(10, 0.0));
      modelController.skinToneInterpreter!.run(toneInput, toneOutput);

      var toneResults = toneOutput[0];
      int maxToneIndex = toneResults.indexOf(toneResults.reduce(max));
      tonescore= maxToneIndex;
      currentSkinTone = _getSkinToneLabel(maxToneIndex);
      skinToneConfidence.value = toneResults[maxToneIndex];
    }
  }

  Future<void> processSkinConditions() async {
    debugPrint('Starting skin condition analysis...');
    if (modelController.skinConditionInterpreter != null) {
      debugPrint('Starting skin condition analysis.');
      const inputSize = 224;
      final resizedImage = img.copyResize(
        faceArea!,
        width: inputSize,
        height: inputSize,
      );

      Float32List inputArray = Float32List(1 * inputSize * inputSize * 3);
      int pixelIndex = 0;
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          inputArray[pixelIndex] = img.getRed(pixel) / 255.0;
          inputArray[pixelIndex + 1] = img.getGreen(pixel) / 255.0;
          inputArray[pixelIndex + 2] = img.getBlue(pixel) / 255.0;
          pixelIndex += 3;
        }
      }

      var input = inputArray.reshape([1, inputSize, inputSize, 3]);
      var output = List<List<double>>.filled(1, List<double>.filled(6, 0.0));
      modelController.skinConditionInterpreter!.run(input, output);

      var results = output[0];
      detectedSkinConditions.clear();
      for (int i = 0; i < results.length; i++) {
          // Only include conditions with confidence > 50%
          detectedSkinConditions[_getConditionLabel(i)] = results[i];
        
      }
    }
  }

Future<void> processSkinType() async {
  try {
    debugPrint('Starting skin type analysis...');
    // Prepare the request
    var uri = Uri.parse("https://skintype-api-228621321547.us-central1.run.app/predict");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile!.path));
    // Send the request
    var response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      currentSkinType = data['label'];
      print("Predicted Label: ${data['label']}");
      print("Confidence: ${data['confidence']}");
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}

Future<void> processSkinAge () async {
    
    debugPrint('Starting age analysis...');
    if (modelController.ageInterpreter != null) {
      const inputSize = 160;
      final resizedImage = img.copyResize(
        faceArea!,
        width: inputSize,
        height: inputSize,
      );
      Float32List inputArray = Float32List(1 * inputSize * inputSize * 3);
      int pixelIndex = 0;
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          double red = img.getRed(pixel) / 255.0;
          double green = img.getGreen(pixel) / 255.0;
          double blue = img.getBlue(pixel) / 255.0;

          inputArray[pixelIndex] = red;
          inputArray[pixelIndex + 1] = green;
          inputArray[pixelIndex + 2] = blue;
          pixelIndex += 3;
        }
      }
      var input = inputArray.reshape([1, inputSize, inputSize, 3]);
      var output = List.filled(1, 0.0).reshape([1, 1]);
      try {
        modelController.ageInterpreter!.run(input, output);
      } catch (e, stack) {
        debugPrint('Error during inference: $e');
        debugPrint('Stack trace: $stack');
      }
      double estimatedAge = output[0][0];
      skinAge = (estimatedAge*100).round();
      if (skinAge >45) {
        skinAge = skinAge - 20;
      debugPrint('Model inference complete');
    } else {
      debugPrint('Age interpreter is null, skipping analysis.');
    }
  }
}


// Future processSkinAge() async{
//   final uri = Uri.parse('https://YOUR_CLOUD_RUN_URL/predict'); // Replace with your Cloud Run URL

//   final request = http.MultipartRequest('POST', uri)
//     ..files.add(await http.MultipartFile.fromPath('image', imageFile!.path));

//   try {
//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['results'] != null && data['results'].isNotEmpty) {
//         for (var face in data['results']) {
//           final age = face['age'];
//           print('Detected age: $age');
//           skinAge = age;
//           debugPrint('Model inference complete');
//         }
//       } else {
//         print('No faces detected.');
//       }
//     } else {
//       print('Error ${response.statusCode}: ${response.body}');
//     }
//   } catch (e) {
//     print('Failed to send image: $e');
//   }
// }

Future<void> uploadImage(File imageFile) async {
  try {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      debugPrint('Failed to decode image');
      return;
    }

    final rgbImage = img.copyResize(decodedImage, width: decodedImage.width);
    final jpegBytes = img.encodeJpg(rgbImage, quality: 100);

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/processed_image.jpg';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(jpegBytes);

    debugPrint('Created processed image at: $tempPath');
    debugPrint('File size: ${jpegBytes.length} bytes');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://skin-api-228621321547.us-central1.run.app/predict'),
    );

    request.files.add(
      http.MultipartFile(
        'image',
        tempFile.openRead(),
        await tempFile.length(),
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Predictions
      final predictions = decoded['predictions'] as List<dynamic>;
      for (var pred in predictions) {
        debugPrint('Class: ${pred['class']} | Score: ${pred['score']} | Label: ${pred['label']}');
        // probabilities = pred['score'];
      }

      // Grad-CAMs (paths)
      gradCamPaths = [];
      for (var gradCamBase64 in decoded['gradcams']) {
        final gradCamBytes = base64Decode(gradCamBase64);
        final gradCamFilePath =
        '${tempDir.path}/gradcam_${DateTime.now().millisecondsSinceEpoch}.png';
        debugPrint('Grad-CAM file path: $gradCamFilePath');
        final gradCamFile = File(gradCamFilePath);
        await gradCamFile.writeAsBytes(gradCamBytes);
        gradCamPaths.add(gradCamFilePath);
      }
      gradCamPaths = decoded['gradcams'] as List<String>;
      }
    else {
      debugPrint('Failed to predict');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
    }

    await tempFile.delete();
  } catch (e) {
    debugPrint('Exception during upload: $e');
  }
}


  Future<void> processcondition() async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/face_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(img.encodePng(faceArea!));
    debugPrint('Starting image processing...');
    processSkinConditions();
    debugPrint('Skin Condition Analysis done!.');
    isAnalysisComplete.value = true;
  }

  Future<void> processtone() async {
    debugPrint('Starting image processing...');
    processSkinTone();
    isAnalysisComplete.value = true;
    debugPrint('Skin Tone Analysis done!.');
  }

  Future<void> processAge(InputImage image, Face face) async {
    debugPrint('Starting image processing...');
    processSkinAge();
    debugPrint('Skin Tone Analysis done!.');
  }

  Future<void> processtype() async {
    debugPrint('Starting image processing...');
    processSkinType();
    debugPrint('Skin Type Analysis done!.');
  }
  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}

class RealTimeScanner extends StatefulWidget {
  final VoidCallback? onAnalysisComplete;
  final bool processSkinTone;
  final bool processSkinConditions;
  final CameraStateController cameraStateController;

  const RealTimeScanner({
    super.key,
    this.onAnalysisComplete,
    this.processSkinTone = false,
    this.processSkinConditions = false,
    required this.cameraStateController,
  });

  @override
  State<RealTimeScanner> createState() => _RealTimeScannerState();
}

class _RealTimeScannerState extends State<RealTimeScanner> {
  @override
  void initState() {
    super.initState();
    // Initialize camera when the state is created
    widget.cameraStateController.initializeCamera();
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.cameraStateController.isCameraInitialized.isTrue) {
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 80, 21, 88),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 130, 60, 140),
            title: const Text('SkinSage'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfo(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              if (widget
                  .cameraStateController.modelController.isModelLoaded.isFalse)
                const MessageScreenModels(
                  message: "Loading models...",
                  icon: CircularProgressIndicator(
                    
                  ),
                ),
             
            ],
          ),
        );
      } else {
        return Container();
      }
    });
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About SkinSage'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SkinSage uses AI to analyze your skin in real-time:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Detects facial features and position'),
                Text('• Analyzes skin tone using Fitzpatrick scale'),
                Text('• Identifies common skin conditions'),
                SizedBox(height: 16),
                Text(
                  'Important Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Use in good lighting for best results'),
                Text('• Keep your face centered in the frame'),
                Text(
                    '• This is not a substitute for professional medical advice'),
                Text('• Consult a dermatologist for serious skin concerns'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}