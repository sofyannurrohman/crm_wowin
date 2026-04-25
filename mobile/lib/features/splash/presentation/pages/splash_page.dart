import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 2.5 seconds to show splash
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.goNamed(kRouteLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with subtle parallax/scale
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_premium.png',
              fit: BoxFit.cover,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 10.seconds,
                  curve: Curves.easeInOut,
                ),
          ),

          // Dark Overlay for contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Highlighted Logo Box
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 1200.ms, curve: Curves.easeOut)
                    .scale(begin: const Offset(0.7, 0.7), duration: 1200.ms, curve: Curves.elasticOut)
                    .shimmer(delay: 1500.ms, duration: 2.seconds),
                
                const SizedBox(height: 48),

                // Text: Wowin CRM
                Text(
                  'Wowin CRM',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 1000.ms).moveY(begin: 30, end: 0, duration: 1000.ms, curve: Curves.easeOutQuart),

                const SizedBox(height: 12),

                // Premium Subtitle
                Text(
                  'EXCELLENCE IN EVERY INTERACTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 4.0,
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 1000.ms),

                const SizedBox(height: 120),

                // Loading Indicator
                const SizedBox(
                  width: 40,
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ).animate().fadeIn(delay: 1800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
