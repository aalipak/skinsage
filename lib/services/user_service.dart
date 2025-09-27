import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes and update user data accordingly
    ever(_authService.user, (user) {
      if (user != null) {
        _loadUserData((user as UserModel).uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> createNewUser(String uid, String email) async {
    final userModel = UserModel(
      uid: uid,
      email: email,
      scanHistory: [],
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      currentUser.value = userModel;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> addScanResult(ScanResult scanResult) async {
    if (_authService.user.value == null) return;

    try {
      final userRef = _firestore.collection('users').doc(_authService.user.value!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          throw Exception('User document does not exist!');
        }

        final userData = UserModel.fromFirestore(userDoc);
        final updatedScanHistory = [...userData.scanHistory, scanResult];

        transaction.update(userRef, {
          'scanHistory': updatedScanHistory.map((scan) => scan.toMap()).toList(),
          'lastScanAt': Timestamp.fromDate(scanResult.scanDate),
        });
      });

      // Reload user data to update the UI
      await _loadUserData(_authService.user.value!.uid);
    } catch (e) {
      print('Error adding scan result: $e');
      rethrow;
    }
  }

  Future<List<ScanResult>> getUserScanHistory() async {
    if (_authService.user.value == null) return [];

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_authService.user.value!.uid)
          .get();

      if (!doc.exists) return [];

      final userData = UserModel.fromFirestore(doc);
      return userData.scanHistory;
    } catch (e) {
      print('Error getting scan history: $e');
      return [];
    }
  }
} 