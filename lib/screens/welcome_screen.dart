import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController fadeController;
  late final AnimationController slideController;
  late final Animation<double> fade;
  late final Animation<Offset> slide;

  late final AnimationController bgController;

  final Random random = Random();
  final List<_AnimatedCircle> circles = [];

  @override
  void initState() {
    super.initState();

    // Text animations
    fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    fade = CurvedAnimation(parent: fadeController, curve: Curves.easeIn);
    slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOutCubic,
    ));

    fadeController.forward();
    slideController.forward();

    // Background animations
    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      circles.add(_AnimatedCircle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: random.nextDouble() * 60 + 20,
        speed: random.nextDouble() * 0.002 + 0.0005,
        color: Colors.white.withOpacity(0.1 + random.nextDouble() * 0.2),
      ));
    }
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: bgController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CustomPaint(
              painter: _BackgroundPainter(circles, bgController.value),
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "FocusFlow",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Stay Focused. Stay Productive.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    // Get Started button small and centered
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Class for animated background circles
class _AnimatedCircle {
  double x;
  double y;
  double radius;
  double speed;
  Color color;

  _AnimatedCircle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.color,
  });
}

// Painter for background animations
class _BackgroundPainter extends CustomPainter {
  final List<_AnimatedCircle> circles;
  final double animationValue;

  _BackgroundPainter(this.circles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var circle in circles) {
      paint.color = circle.color;
      final dx = circle.x * size.width;
      double dy = (circle.y + animationValue * circle.speed * 1000) % 1 * size.height;
      canvas.drawCircle(Offset(dx, dy), circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

