import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum FaceValidationStatus {
  none,
  notDetected,
  tooFar,
  tooClose,
  lookStraight,
  eyesClosed,
  multipleFaces,
  valid,
}

class FaceValidationOverlay extends StatelessWidget {
  final FaceValidationStatus status;
  final String? customMessage;

  const FaceValidationOverlay({
    super.key,
    required this.status,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (status == FaceValidationStatus.none) return const SizedBox.shrink();

    final isValid = status == FaceValidationStatus.valid;
    final color = isValid ? Colors.green : Colors.amber;
    final icon = isValid ? LucideIcons.checkCircle : LucideIcons.alertCircle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Visual Guide (Oval)
        Container(
          width: 240,
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.8),
              width: 3,
            ),
            borderRadius: BorderRadius.all(Radius.elliptical(120, 160)),
          ),
        ),
        const SizedBox(height: 24),
        // Message Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                customMessage ?? _getMessage(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMessage(FaceValidationStatus status) {
    switch (status) {
      case FaceValidationStatus.notDetected:
        return 'Cari posisi/cahaya lebih baik di depan toko';
      case FaceValidationStatus.tooFar:
        return 'Dekatkan wajah Anda';
      case FaceValidationStatus.tooClose:
        return 'Jauhkan wajah Anda';
      case FaceValidationStatus.lookStraight:
        return 'Lihat lurus ke kamera';
      case FaceValidationStatus.eyesClosed:
        return 'Pastikan mata terbuka';
      case FaceValidationStatus.multipleFaces:
        return 'Hanya satu wajah diperbolehkan';
      case FaceValidationStatus.valid:
        return 'Wajah Terdeteksi';
      default:
        return '';
    }
  }
}
