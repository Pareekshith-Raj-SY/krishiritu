import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _progress = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _animController.forward();

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06342A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient matching image sky (top) and ground (bottom)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF80C5F0), // Sky blue matching top of image
                  Color(0xFF06342A), // Dark green matching bottom of image
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // Splash image fitted correctly into display without cropping or overlapping
          Center(
            child: Image.asset(
              'assets/images/loading_screen.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Sleek, non-intrusive animated loading progress bar at the very bottom
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 48, right: 48),
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          backgroundColor:
                              const Color.fromRGBO(255, 255, 255, 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
