import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:skinsage/controllers/chatController.dart';
import 'package:skinsage/screens/camera_controller.dart';
import 'package:skinsage/screens/login_screen.dart';
import 'package:skinsage/screens/welcome.dart';
import 'screens/message_view.dart';
import 'model_controller.dart';
import 'widgets/theme_controller.dart';
import 'package:face_camera/face_camera.dart';
import 'services/local_auth_service.dart';
import 'package:skinsage/services/skin_age_history_service.dart';
import 'services/health_score_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDDihvjYDB-6batI_XK-ZySq3WhB3NCHl0",
      authDomain: "skinsage-781c1.firebaseapp.com",
      projectId: "skinsage-781c1",
      storageBucket: "skinsage-781c1.appspot.com",
      messagingSenderId: "228621321547",
      appId: "1:228621321547:android:4367fbc2aa4ba98f2554ce",
    ),
  );

  // Initialize FaceCamera
  await FaceCamera.initialize();
  //for chatbotapi key
  await dotenv.load(fileName: "key.env");

  // Initialize all services in the correct order
  Get.put(ThemeController(), permanent: true);
  Get.put(LocalAuthService(), permanent: true);
  Get.put(ModelController(), permanent: true);
  Get.put(CameraStateController(), permanent: true);
  Get.put(SkinAgeHistoryService(), permanent: true);
  Get.put(HealthScoreHistoryService(), permanent: true);
  Get.put(ChatController(), permanent: true);

  // Get.put(FaceDetectorView());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final modelController = Get.find<ModelController>();
    final authService = Get.find<LocalAuthService>();

    return GetMaterialApp(
      title: 'SkinSage',
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeController.theme, // Apply dynamic theme
      // theme: ThemeData(
      //   primarySwatch: Colors.pink,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      home: Obx(() {
        if (modelController.isModelLoaded.value) {
          return LoginScreen();
        } else if (modelController.isError.value) {
          return const MessageScreenModels(
            message: "Error loading models!",
            icon:
                Icon(Icons.error_outline_outlined, size: 48, color: Colors.red),
          );
        } else {
          return const MessageScreenModels(
            message: "Loading models, please wait...",
            icon: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///
///
///
///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///
