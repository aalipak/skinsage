import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalAuthService extends GetxService {
  final RxBool isLoggedIn = false.obs;
  final RxString currentUserId = ''.obs;
  final RxString currentUserEmail = ''.obs;
  final RxInt currentUserAge = 0.obs;
  final RxString currentUserGender = ''.obs;
  final RxString currentUserDob = ''.obs;

  // User data storage
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadUserSession();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      // Initialize with default values if SharedPreferences fails
      isLoggedIn.value = false;
      currentUserId.value = '';
      currentUserEmail.value = '';
    }
  }

  void _loadUserSession() {
    if (_prefs == null) return;

    try {
      final userId = _prefs!.getString('user_id');
      final userEmail = _prefs!.getString('user_email');
      final userDob = _prefs!.getString('user_dob');
      final userGender = _prefs!.getString('user_gender');
      final userAge = _prefs!.getInt('user_age');

      if (userId != null && userEmail != null) {
        currentUserId.value = userId;
        currentUserEmail.value = userEmail;
        currentUserDob.value = userDob ?? '';
        currentUserGender.value = userGender ?? '';
        currentUserAge.value = userAge ?? 0;
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Error loading user session: $e');
      // Reset to default values on error
      isLoggedIn.value = false;
      currentUserId.value = '';
      currentUserEmail.value = '';
      currentUserDob.value = '';
      currentUserGender.value = '';
      currentUserAge.value = 0;
    }
  }

  Future<bool> signUp(String name, String email, String Age, String password,  String gender) async {
    if (_prefs == null) {
      Get.snackbar(
        'Error',
        'Unable to access storage. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }

    try {
      // Check if email already exists
      final existingEmail = _prefs!.getString('user_email');
      if (existingEmail == email) {
        Get.snackbar(
          'Error',
          'An account with this email already exists.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return false;
      }

      // Generate a simple user ID (in a real app, use a proper UUID)
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      // Calculate age from DOB
      // final birthDate = DateTime.parse(dob);
      // final currentDate = DateTime.now();
      final age = int.parse(Age);
      //     ((currentDate.month < birthDate.month || 
      //       (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) ? 1 : 0);

      // Store user data
      await _prefs!.setString('user_id', userId);
      await _prefs!.setString('user_email', email);
      await _prefs!.setString('user_password', password); // In a real app, hash this
      await _prefs!.setString('user_name', name);
      // await _prefs!.setString('user_dob', dob);
      await _prefs!.setString('user_gender', gender);
      await _prefs!.setInt('user_age', age);

      // Update state
      currentUserId.value = userId;
      currentUserEmail.value = email;
      // currentUserDob.value = dob;
      currentUserGender.value = gender;
      currentUserAge.value = age;
      isLoggedIn.value = true;

      return true;
    } catch (e) {
      print('Sign up error: $e');
      Get.snackbar(
        'Error',
        'Failed to create account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (_prefs == null) {
      Get.snackbar(
        'Error',
        'Unable to access storage. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }

    try {
      final storedEmail = _prefs!.getString('user_email');
      final storedPassword = _prefs!.getString('user_password');

      if (storedEmail == email && storedPassword == password) {
        final userId = _prefs!.getString('user_id') ?? '';
        final userDob = _prefs!.getString('user_dob') ?? '';
        final userGender = _prefs!.getString('user_gender') ?? '';
        final userAge = _prefs!.getInt('user_age') ?? 0;

        // Update state
        currentUserId.value = userId;
        currentUserEmail.value = email;
        currentUserDob.value = userDob;
        currentUserGender.value = userGender;
        currentUserAge.value = userAge;
        isLoggedIn.value = true;

        return true;
      }

      return false;
    } catch (e) {
      print('Sign in error: $e');
      Get.snackbar(
        'Error',
        'Failed to sign in. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    isLoggedIn.value = false;
    currentUserId.value = '';
    currentUserEmail.value = '';
  }

  Future<void> resetPassword(String email) async {
    if (_prefs == null) {
      Get.snackbar(
        'Error',
        'Unable to access storage. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      final storedEmail = _prefs!.getString('user_email');
      if (storedEmail == email) {
        // In a real app, this would send a reset email
        // For this local implementation, we'll just show a success message
        Get.snackbar(
          'Password Reset',
          'If an account exists with this email, you will receive password reset instructions.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else {
        // For security reasons, we still show the same message even if the email doesn't exist
        Get.snackbar(
          'Password Reset',
          'If an account exists with this email, you will receive password reset instructions.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      }
    } catch (e) {
      print('Password reset error: $e');
      Get.snackbar(
        'Error',
        'Failed to process password reset request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Map<String, dynamic> getCurrentUser() {
    if (_prefs == null || !isLoggedIn.value) {
      return {};
    }

    try {
      return {
        'name': _prefs!.getString('user_name') ?? '',
        'email': currentUserEmail.value,
        'age': currentUserAge.value,
        'gender': currentUserGender.value,
        // 'dob': currentUserDob.value,
      };
    } catch (e) {
      print('Error fetching current user: $e');
      return {};
    }
  }


  // Save user analysis results
  Future<void> saveAnalysisResult(Map<String, dynamic> result) async {
    if (_prefs == null) return;

    try {
      final userId = currentUserId.value;
      if (userId.isEmpty) return;

      // Get existing results
      final resultsKey = 'analysis_results_$userId';
      final existingResultsJson = _prefs!.getString(resultsKey);
      List<Map<String, dynamic>> results = [];

      if (existingResultsJson != null) {
        results = List<Map<String, dynamic>>.from(
            jsonDecode(existingResultsJson)
                .map((x) => Map<String, dynamic>.from(x)));
      }

      // Add timestamp to the result
      result['timestamp'] = DateTime.now().toIso8601String();

      // Add new result
      results.add(result);

      // Save back to preferences
      await _prefs!.setString(resultsKey, jsonEncode(results));
    } catch (e) {
      print('Save analysis error: $e');
    }
  }

  // Get user analysis results
  List<Map<String, dynamic>> getAnalysisResults() {
    if (_prefs == null) return [];

    try {
      final userId = currentUserId.value;
      if (userId.isEmpty) return [];

      final resultsKey = 'analysis_results_$userId';
      final resultsJson = _prefs!.getString(resultsKey);

      if (resultsJson == null) return [];

      return List<Map<String, dynamic>>.from(
          jsonDecode(resultsJson).map((x) => Map<String, dynamic>.from(x)));
    } catch (e) {
      print('Get analysis error: $e');
      return [];
    }
  }

  // Save user recommendations
  Future<void> saveRecommendation(String recommendation) async {
    if (_prefs == null) return;

    try {
      final userId = currentUserId.value;
      if (userId.isEmpty) return;

      final recommendationsKey = 'recommendations_$userId';
      final existingRecommendationsJson = _prefs!.getString(recommendationsKey);
      List<String> recommendations = [];

      if (existingRecommendationsJson != null) {
        recommendations =
            List<String>.from(jsonDecode(existingRecommendationsJson));
      }

      // Add new recommendation
      recommendations.add(recommendation);

      // Save back to preferences
      await _prefs!.setString(recommendationsKey, jsonEncode(recommendations));
    } catch (e) {
      print('Save recommendation error: $e');
    }
  }

  // Get user recommendations
  List<String> getRecommendations() {
    if (_prefs == null) return [];

    try {
      final userId = currentUserId.value;
      if (userId.isEmpty) return [];

      final recommendationsKey = 'recommendations_$userId';
      final recommendationsJson = _prefs!.getString(recommendationsKey);

      if (recommendationsJson == null) return [];

      return List<String>.from(jsonDecode(recommendationsJson));
    } catch (e) {
      print('Get recommendations error: $e');
      return [];
    }
  }

  // Store analysis results
  Future<void> storeAnalysisResult(Map<String, dynamic> analysisResult) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = currentUserEmail.value;
    
    // Get existing results
    final existingResults = getAnalysisResults();
    
    // Add timestamp if not present
    if (!analysisResult.containsKey('timestamp')) {
      analysisResult['timestamp'] = DateTime.now().toIso8601String();
    }
    
    // Add new result to the beginning of the list
    existingResults.insert(0, analysisResult);
    
    // Store updated results
    await prefs.setString('analysis_results_$userId', jsonEncode(existingResults));
  }

  // Get all analysis results for the current user
  Future<List<Map<String, dynamic>>> getAnalysisResultsForUser() async {
    final userId = currentUserEmail.value;
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final resultsString = prefs.getString('analysis_results_$userId');
      if (resultsString == null) return [];
      
      final List<dynamic> results = jsonDecode(resultsString);
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting analysis results: $e');
      return [];
    }
  }

  // Clear analysis results for the current user
  Future<void> clearAnalysisResults() async {
    final userId = currentUserEmail.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('analysis_results_$userId');
  }
}
