import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo: White squircle with custom note icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Note Sheet Lines
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 40, height: 4, color: const Color(0xFF4F46E5), margin: const EdgeInsets.only(bottom: 4)),
                            Container(width: 40, height: 4, color: const Color(0xFF4F46E5), margin: const EdgeInsets.only(bottom: 4)),
                            Container(width: 25, height: 4, color: const Color(0xFF4F46E5)),
                          ],
                        ),
                        // Yellow notification bell badge
                        Positioned(
                          top: 18,
                          right: 18,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'NoteAlert',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your reminders, beautifully noted.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFEADDFF),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Progress loader
                  SizedBox(
                    width: 140,
                    height: 4,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.white.withAlpha(51),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          borderRadius: BorderRadius.circular(2),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Version info at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Version 1.0.0 • Built for Focus',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: Colors.white.withAlpha(128),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
