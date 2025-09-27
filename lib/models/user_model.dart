import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final List<ScanResult> scanHistory;
  final DateTime createdAt;
  final DateTime? lastScanAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.scanHistory,
    required this.createdAt,
    this.lastScanAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      scanHistory: (data['scanHistory'] as List<dynamic>?)
          ?.map((scan) => ScanResult.fromMap(scan as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastScanAt: data['lastScanAt'] != null
          ? (data['lastScanAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'scanHistory': scanHistory.map((scan) => scan.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastScanAt': lastScanAt != null ? Timestamp.fromDate(lastScanAt!) : null,
    };
  }
}

class ScanResult {
  final String condition;
  final double confidence;
  final String imageUrl;
  final DateTime scanDate;
  final Map<String, dynamic>? additionalInfo;

  ScanResult({
    required this.condition,
    required this.confidence,
    required this.imageUrl,
    required this.scanDate,
    this.additionalInfo,
  });

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      condition: map['condition'] ?? '',
      confidence: (map['confidence'] as num).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      scanDate: (map['scanDate'] as Timestamp).toDate(),
      additionalInfo: map['additionalInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'scanDate': Timestamp.fromDate(scanDate),
      'additionalInfo': additionalInfo,
    };
  }
} 