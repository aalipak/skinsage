import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../models/health_score_history.dart';
import '../services/local_auth_service.dart';

class HealthScoreHistoryService extends GetxService {
  static const String _storageKey = 'health_score_history_';
  final LocalAuthService _authService = Get.find<LocalAuthService>();

  String get _userKey => _storageKey + (_authService.getCurrentUser()?['uid'] ?? 'guest');

  Future<void> addMeasurement(double healthScore) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getMeasurements();
    
    // Calculate change from previous measurement
    double? change;
    if (history.isNotEmpty) {
      change = healthScore - history.first.score;
    }

    // Add new measurement
    history.insert(0, HealthScoreHistory(
      date: DateTime.now().toString(),
      score: healthScore,
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

  Future<List<HealthScoreHistory>> getMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_userKey);
    
    if (historyJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded
          .map((item) => HealthScoreHistory.fromJson(item))
          .toList();
    } catch (e) {
      print('Error decoding health score history: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
} 