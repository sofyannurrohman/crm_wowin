import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../../core/di/injection.dart';

class PhotoPreviewPage extends StatelessWidget {
  final String scheduleId;
  final String customerName;
  final String photoPath;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String checkInNotes;

  const PhotoPreviewPage({
    super.key,
    required this.scheduleId,
    required this.customerName,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.checkInNotes = '',
  });

  static const Color _orange = Color(0xFFE8622A);
  static const Color _bg = Color(0xFFF9FAFB);

  void _submitVisit(BuildContext context) {
    context.read<VisitBloc>().add(
          CheckInSubmitted(
            scheduleId: scheduleId,
            latitude: latitude,
            longitude: longitude,
            photoFile: File(photoPath),
            notes: checkInNotes,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = DateFormat('MMM dd, yyyy hh:mm:ss a').format(DateTime.now()).toUpperCase() + ' LOCAL';

    return BlocProvider(
      create: (context) => sl<VisitBloc>(),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1A1A1A)),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: const Text(
            'Photo Preview',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                'STEP 2 OF 3',
                style: TextStyle(
                  color: Color(0xFFE8622A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        body: BlocListener<VisitBloc, VisitState>(
          listener: (context, state) {
            if (state is VisitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF10B981)),
              );
              // Pop back to dashboard/visits list
              context.go('/dashboard'); 
            } else if (state is VisitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444)),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (distanceMeters > 100) _buildWarningBanner(),
                const SizedBox(height: 20),
                _buildPhotoPreview(timestamp),
                const SizedBox(height: 24),
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please ensure the storefront sign and entrance are clearly visible in the photo for audit compliance.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPrimaryButton(context),
                const SizedBox(height: 16),
                _buildSecondaryButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.alertTriangle, color: Color(0xFFDC2626), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Warning: Outside 100m Radius',
                  style: TextStyle(
                    color: Color(0xFF991B1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current distance: ${distanceMeters.toStringAsFixed(0)}m from store location.',
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(String timestamp) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: FileImage(File(photoPath)),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VERIFIED VISIT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'GPS: ${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° W (±4M)',
                        style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'TIMESTAMP: $timestamp',
                        style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        final isLoading = state is VisitLoading;

        return ElevatedButton(
          onPressed: isLoading ? null : () => _submitVisit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            disabledBackgroundColor: _orange.withOpacity(0.5),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Visit Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.pop(), // Go back to camera page
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4B5563),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(LucideIcons.refreshCcw, size: 20),
          SizedBox(width: 8),
          Text(
            'Retake Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}
