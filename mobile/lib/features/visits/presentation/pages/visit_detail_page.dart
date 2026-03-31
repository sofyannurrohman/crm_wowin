import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_state.dart';

class VisitDetailPage extends StatefulWidget {
  final String visitId;

  const VisitDetailPage({super.key, required this.visitId});

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _lightOrangeBg = Color(0xFFFFF7ED);

  @override
  void initState() {
    super.initState();
    // context.read<VisitBloc>().add(FetchVisitDetail(widget.visitId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          // if (state is VisitLoading) return const Center(child: CircularProgressIndicator());
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSectionTitle(LucideIcons.camera, 'Check-in Photo'),
                _buildPhotoSection(),
                const SizedBox(height: 24),
                _buildSectionTitle(LucideIcons.fileText, 'Visit Summary'),
                _buildSummarySection(),
                const SizedBox(height: 24),
                _buildSectionTitle(LucideIcons.checkSquare, 'Next Step'),
                _buildNextStepSection(),
                const SizedBox(height: 24),
                _buildSectionTitle(LucideIcons.map, 'Check-in Location'),
                _buildMapSection(),
                const SizedBox(height: 120), // Bottom padding for button
              ],
            ),
          );
        },
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: _textPrimary),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Visit Detail',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.share2, color: _textPrimary, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _lightOrangeBg,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
          ),
          child: const Icon(LucideIcons.building2, color: _orange, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Acme Corp - John Doe',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Oct 24, 2023 • 10:30 AM - 11:45 AM',
                style: TextStyle(
                  color: _textSecondary.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: _orange, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Successful',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: _textSecondary.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'Captured at 10:32 AM',
                      style: TextStyle(color: _textSecondary.withOpacity(0.9), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 14, color: _textSecondary.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'GPS: 34.0522° N, 118.2437° W',
                      style: TextStyle(color: _textSecondary.withOpacity(0.9), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _lightOrangeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'VERIFIED LOCATION',
                    style: TextStyle(
                      color: _orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Met with John and the procurement team. We discussed the Q4 inventory requirements and the upcoming product launch. They expressed interest in the premium subscription tier. John requested a revised quote including the bulk discount for 50+ licenses.',
        style: TextStyle(
          color: _textSecondary,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildNextStepSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightOrangeBg,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: _orange, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Revised Quote',
            style: TextStyle(
              color: _orange,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Due: Oct 26, 2023',
            style: TextStyle(
              color: _textSecondary.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    const lat = 34.0522;
    const lng = -118.2437;

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 12.0,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.wowin.crm',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(lat, lng),
                  child: const Icon(Icons.location_on, color: _orange, size: 30),
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.edit2, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Edit Visit Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
