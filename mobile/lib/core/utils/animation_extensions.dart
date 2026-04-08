import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AnimationExtension on Widget {
  /// Adds a smooth entrance animation with fade and slide.
  /// Uses RepaintBoundary to ensure the animation is 'lightweight' and doesn't 
  /// cause unnecessary repaints of the parent.
  Widget animateEntrance({
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Offset offset = const Offset(0, 20),
  }) {
    return RepaintBoundary(
      child: animate(delay: delay)
          .fadeIn(duration: duration, curve: Curves.easeOutCubic)
          .slide(
            begin: offset,
            end: Offset.zero,
            duration: duration,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  /// Adds a subtle scale entrance animation.
  Widget animateScale({
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    return RepaintBoundary(
      child: animate(delay: delay)
          .fadeIn(duration: duration)
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: duration,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
