import 'package:flutter/material.dart';

class AIScanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AIScanButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 30, 1, 94),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.camera_alt, color: Colors.white),
          Text(
            'Use AI to scan your face',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }
}
