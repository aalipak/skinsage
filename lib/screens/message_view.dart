import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'login_screen.dart';

class MessageScreen extends StatefulWidget {
  final String message;
  final Widget icon;

  const MessageScreen({super.key, required this.message, required this.icon});

  @override
  MessageScreenState createState() => MessageScreenState();
}

class MessageScreenState extends State<MessageScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _circleAnimation;
  late final AnimationController _pulseAnimationController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for continuous movement in a circle
    _animationController = AnimationController(
      duration: const Duration(seconds: 8), // Slowed down for more graceful movement
      vsync: this,
    )..repeat();

    // Circular path animation (0 to 2π for a full revolution)
    _circleAnimation = Tween<double>(begin: 0, end: 2 * pi)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    
    // Pulse animation for the logo
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple[400]!,
            Colors.deepPurple[300]!,
            Colors.purple[200]!,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showInfo(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo with combined animations
                AnimatedBuilder(
                  animation: _circleAnimation,
                  builder: (context, child) {
                    double radius = 50; // Reduced radius for subtler movement
                    double xPosition = radius * cos(_circleAnimation.value);
                    double yPosition = radius * sin(_circleAnimation.value);

                    return Transform.translate(
                      offset: Offset(xPosition, yPosition),
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple[300]!.withOpacity(0.5),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo_transparent.png',
                                width: 180,
                                height: 180,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Message with animation
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(seconds: 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Icon with elevation
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: widget.icon,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          title: const Text(
            'About SkinSage',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SkinSage uses AI to analyze your skin in real-time:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.face, color: Colors.deepPurple),
                  minLeadingWidth: 10,
                  title: Text('Detects facial features and position'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.palette, color: Colors.deepPurple),
                  minLeadingWidth: 10,
                  title: Text('Analyzes skin tone using Fitzpatrick scale'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.health_and_safety, color: Colors.deepPurple),
                  minLeadingWidth: 10,
                  title: Text('Identifies common skin conditions'),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 16),
                Text(
                  'Important Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Use in good lighting for best results'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.center_focus_strong, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Keep your face centered in the frame'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.medical_services, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Not a substitute for professional medical advice'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.healing, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Consult a dermatologist for serious skin concerns'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}







class MessageScreenModels extends StatefulWidget {
  final String message;
  final Widget icon;

  const MessageScreenModels({super.key, required this.message, required this.icon});

  @override
  MessageScreenModelsState createState() => MessageScreenModelsState();
}

class MessageScreenModelsState extends State<MessageScreenModels> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _circleAnimation;
  late final AnimationController _pulseAnimationController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for continuous movement in a circle
    _animationController = AnimationController(
      duration: const Duration(seconds: 8), // Slowed down for more graceful movement
      vsync: this,
    )..repeat();

    // Circular path animation (0 to 2π for a full revolution)
    _circleAnimation = Tween<double>(begin: 0, end: 2 * pi)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    
    // Pulse animation for the logo
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple[400]!,
            Colors.deepPurple[300]!,
            Colors.purple[200]!,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showInfo(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo with combined animations
                AnimatedBuilder(
                  animation: _circleAnimation,
                  builder: (context, child) {
                    double radius = 50; // Reduced radius for subtler movement
                    double xPosition = radius * cos(_circleAnimation.value);
                    double yPosition = radius * sin(_circleAnimation.value);

                    return Transform.translate(
                      offset: Offset(xPosition, yPosition),
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple[300]!.withOpacity(0.5),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo_transparent.png',
                                width: 180,
                                height: 180,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Message with animation
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(seconds: 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Icon with elevation
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: widget.icon,
                ),
              ],
            ),
          ),
        ),
        
        
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          title: const Text(
            'About SkinSage',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SkinSage uses AI to analyze your skin in real-time:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.face, color: Colors.deepPurple),
                  minLeadingWidth: 10,
                  title: Text('Detects facial features and position'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.palette, color: Colors.deepPurple),
                  minLeadingWidth: 10,
                  title: Text('Analyzes skin tone using Fitzpatrick scale'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.health_and_safety, color: Colors.deepPurple),
                  minLeadingWidth: 10,
                  title: Text('Identifies common skin conditions'),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 16),
                Text(
                  'Important Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Use in good lighting for best results'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.center_focus_strong, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Keep your face centered in the frame'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.medical_services, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Not a substitute for professional medical advice'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.healing, color: Colors.amber),
                  minLeadingWidth: 10,
                  title: Text('Consult a dermatologist for serious skin concerns'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}