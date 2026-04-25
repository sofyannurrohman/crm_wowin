import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_state.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/visit_activity.dart';

class VisitDetailPage extends StatefulWidget {
  final String visitId;

  const VisitDetailPage({super.key, required this.visitId});

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          if (state is! ActivitiesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final activity = state.activities.where((a) => a.id == widget.visitId).firstOrNull;
          
          if (activity == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.searchX, size: 64, color: AppColors.textPlaceholder),
                  const SizedBox(height: 16),
                  const Text('Activity record not found', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextButton(onPressed: () => context.pop(), child: const Text('Go Back')),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildPremiumHeader(activity),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activity.selfiePhotoPath != null || activity.placePhotoPath != null || activity.notaPhotoPath != null) ...[
                        _buildSectionTitle(LucideIcons.camera, 'VERIFICATION PHOTOS'),
                        const SizedBox(height: 12),
                        _buildPhotoSection(activity),
                        const SizedBox(height: 32),
                      ],
                      _buildSectionTitle(LucideIcons.fileText, 'ACTIVITY SUMMARY'),
                      const SizedBox(height: 12),
                      _buildSummarySection(activity),
                      const SizedBox(height: 32),
                      _buildSectionTitle(LucideIcons.map, 'CHECK-IN LOCATION'),
                      const SizedBox(height: 12),
                      _buildMapSection(activity),
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildPremiumHeader(VisitActivity activity) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  ),
                  const Text(
                    'Visit Detail',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.share2, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(LucideIcons.building, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.customerName ?? activity.leadName ?? 'Unknown Target',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(LucideIcons.calendar, size: 12, color: Colors.white.withOpacity(0.6)),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MMMM d, yyyy • HH:mm').format(activity.createdAt),
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(VisitActivity activity) {
    final String? mainPhoto = activity.notaPhotoPath ?? activity.placePhotoPath ?? activity.selfiePhotoPath;
    if (mainPhoto == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.network(
              '${ApiEndpoints.uploadsBaseUrl}$mainPhoto',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                height: 220,
                color: const Color(0xFFF1F5F9),
                child: const Icon(LucideIcons.imageOff, color: AppColors.textPlaceholder, size: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.notaPhotoPath != null ? 'Nota/Kuitansi Fisik' : 'Foto Lokasi/Kunjungan',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Text('LOCATION VERIFIED', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(LucideIcons.clock, 'Captured at ${DateFormat('HH:mm').format(activity.createdAt)}'),
                if (activity.distance != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(LucideIcons.mapPin, 'Distance: ${activity.distance!.toStringAsFixed(1)}m from target'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textPlaceholder),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSummarySection(VisitActivity activity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.dealAmount != null && activity.dealAmount! > 0) ...[
            const Text('TOTAL TRANSAKSI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.textPlaceholder, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text('Rp ${NumberFormat('#,###', 'id_ID').format(activity.dealAmount)}', 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.emerald)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],
          Text(
            activity.notes ?? 'No detailed notes recorded for this activity.',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
          ),
          if (activity.outcome != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.emerald),
                const SizedBox(width: 8),
                Text('Outcome: ${activity.outcome!.replaceAll("_", " ").toUpperCase()}', 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.emerald)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapSection(VisitActivity activity) {
    final lat = activity.latitude;
    final lng = activity.longitude;

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.wowin.crm',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lng),
                  child: const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(LucideIcons.download, color: Colors.white, size: 18),
        label: const Text(
          'EXPORT PDF REPORT',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.2),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }
}
