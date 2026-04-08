import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class FullLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;

  const FullLoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return AbsorbPointer(
      absorbing: true,
      child: Stack(
        children: [
          // Semi-transparent background with Blur
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5 * value, sigmaY: 5 * value),
                child: Container(
                  color: Colors.black.withOpacity(0.2 * value),
                ),
              );
            },
          ),
          
          // Spinner and Message
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.5)),
                      
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      ],
                    ],
                  ),
                ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.8, 0.8),
                ).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
