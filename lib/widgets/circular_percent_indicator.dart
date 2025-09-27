import 'package:flutter/material.dart';

class CircularPercentIndicator extends StatelessWidget {
  final double percentage;

  const CircularPercentIndicator({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: CircularProgressIndicator(
        value: percentage / 100,
        strokeWidth: 8,
        backgroundColor: Colors.grey.shade300,
        valueColor: const AlwaysStoppedAnimation<Color>(
            Color.fromARGB(255, 237, 186, 76)),
      ),
    );
  }
}
