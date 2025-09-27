import 'package:flutter/material.dart';
import 'recommendation_card.dart'; // Assuming you have this import

class RecommendationSlider extends StatefulWidget {
  final List<Map<String, String>> recommendations;

  const RecommendationSlider({super.key, required this.recommendations});

  @override
  _RecommendationSliderState createState() => _RecommendationSliderState();
}

class _RecommendationSliderState extends State<RecommendationSlider> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  void _goToNextPage() {
    if (_currentPage < widget.recommendations.length - 1) {
      _pageController.animateToPage(
        ++_currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        --_currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200, // Adjust height to match the card size
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.recommendations.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return RecommendationCard(
                title: widget.recommendations[index]['title']!,
                imagePath: widget.recommendations[index]['imagePath']!,
              );
            },
          ),
        ),
        // Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goToPreviousPage,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _goToNextPage,
            ),
          ],
        ),
      ],
    );
  }
}
