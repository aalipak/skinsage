import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../models/skin_age_history.dart';
import '../services/local_auth_service.dart';

class SkinAgeHistoryService extends GetxService {
  static const String _storageKey = 'skin_age_history_';
  final LocalAuthService _authService = Get.find<LocalAuthService>();

  String get _userKey => _storageKey + (_authService.getCurrentUser()?['uid'] ?? 'guest');

  Future<void> addMeasurement(int skinAge) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getMeasurements();
    
    // Calculate change from previous measurement
    int? change;
    if (history.isNotEmpty) {
      change = skinAge - history.first.age;
    }

    // Add new measurement
    history.insert(0, SkinAgeHistory(
      date: DateTime.now().toString(),
      age: skinAge,
      change: change,
    ));

    // Keep only last 10 measurements
    if (history.length > 10) {
      history.removeLast();
    }

    // Save to SharedPreferences
    await prefs.setString(_userKey, jsonEncode(
      history.map((item) => item.toJson()).toList(),
    ));
  }

  Future<List<SkinAgeHistory>> getMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_userKey);
    
    if (historyJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded
          .map((item) => SkinAgeHistory.fromJson(item))
          .toList();
    } catch (e) {
      print('Error decoding skin age history: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
