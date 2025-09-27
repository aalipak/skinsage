import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/local_auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AnalysisHistory extends StatelessWidget {
  const AnalysisHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<LocalAuthService>();
    final analysisResults = authService.getAnalysisResults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        centerTitle: true,
      ),
      body: analysisResults.isEmpty
          ? _buildEmptyState()
          : _buildAnalysisList(analysisResults),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No analysis history yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete a skin analysis to see your history',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisList(List<Map<String, dynamic>> analyses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final analysis = analyses[index];
        final timestamp = DateTime.parse(analysis['timestamp'] ?? DateTime.now().toIso8601String());
        final formattedDate = DateFormat('MMM dd, yyyy').format(timestamp);
        final formattedTime = DateFormat('hh:mm a').format(timestamp);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                color: Colors.purple,
              ),
            ),
            title: Text(
              'Skin Analysis',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '$formattedDate at $formattedTime',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnalysisSection(
                      'Skin Health Score',
                      analysis['score']?.toString() ?? 'N/A',
                      Icons.health_and_safety,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalysisSection(
                      'Skin Type',
                      analysis['skinType']?.toString() ?? 'N/A',
                      Icons.face,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalysisSection(
                      'Skin Tone',
                      analysis['skinTone']?.toString() ?? 'N/A',
                      Icons.color_lens,
                      Colors.brown,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalysisSection(
                      'Concerns',
                      _formatConcerns(analysis['concerns']),
                      Icons.warning,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalysisSection(
                      'Recommendations',
                      _formatRecommendations(analysis['recommendations']),
                      Icons.lightbulb,
                      Colors.purple,
                    ),
                    if (analysis['imagePath'] != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(analysis['imagePath']),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalysisSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatConcerns(dynamic concerns) {
    if (concerns == null) return 'No concerns detected';
    if (concerns is List) {
      return concerns.join('\n');
    }
    return concerns.toString();
  }

  String _formatRecommendations(dynamic recommendations) {
    if (recommendations == null) return 'No recommendations available';
    if (recommendations is List) {
      return recommendations.join('\n');
    }
    return recommendations.toString();
  }
}