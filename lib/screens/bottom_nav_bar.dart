import 'package:flutter/material.dart';
import 'package:skinsage/screens/chatbot_screen.dart';
import 'package:skinsage/screens/report_screen.dart';
import 'package:skinsage/screens/welcome.dart';
import 'package:skinsage/screens/profile_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  // Animation controller for the continuous pulsing animation
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller with repeating behavior
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slower for a gentler effect
    )..repeat(reverse: true); // Important: makes the animation continuous
    
    // Create a gentle pulse animation that doesn't grow too large
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08, // Subtle pulse - not too dramatic
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme color to maintain consistency
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Color(0xFFFFC6BC); // Using a color from our previous design
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Regular nav items in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: NavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  screen: WelcomeScreen(),
                  isActive: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
              ),
              
              // Placeholder for center button to maintain spacing
              Expanded(child: SizedBox()),
              
              Expanded(
                child: NavItem(
                  icon: Icons.person_rounded,
                  label: "Profile",
                  screen: ProfilePage(),
                  isActive: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
            ],
          ),
          
          // Floating center button with continuous animation
          Positioned(
            left: 0,
            right: 0,
            top: -5, // Reduced elevation to bring button down
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [secondaryColor, primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Add a quick "pop" effect on tap by manipulating the controller
                        final double currentValue = _animationController.value;
                        
                        // Briefly pause the continuous animation
                        _animationController.stop();
                        
                        // Create a more dramatic pop effect when tapped
                        Animation<double> _tapAnimation = Tween<double>(
                          begin: 1.0,
                          end: 1.2,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          ),
                        );
                        
                        // Play quick animation sequence
                        _animationController.forward(from: 0.0).then((_) {
                          // After animation completes, navigate
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => SkinReportPage()),
                          );
                          
                          // Resume the continuous pulse animation from where it was
                          _animationController.value = currentValue;
                          _animationController.repeat(reverse: true);
                        });
                      },
                      customBorder: CircleBorder(),
                      splashColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [Colors.white, Colors.white.withOpacity(0.8)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Icon(
                                Icons.save_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2.0,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget screen;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key, 
    required this.icon, 
    required this.label, 
    required this.screen,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive 
        ? Theme.of(context).primaryColor 
        : Colors.grey[600];
        
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => screen),
          );
        },
        customBorder: CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                color: color, 
                size: 28
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, 
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}