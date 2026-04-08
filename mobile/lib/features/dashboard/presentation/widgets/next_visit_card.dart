import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/visit_recommendation.dart';

class NextVisitCard extends StatelessWidget {
  final VisitRecommendation nextStop;

  const NextVisitCard({
    super.key,
    required this.nextStop,
  });

  static const Color _navy = Color(0xFF1A237E);
  static const Color _green = Color(0xFF0D8549);

  Future<void> _openMap() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${nextStop.latitude},${nextStop.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, Color(0xFF283593)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.navigation, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'TUJUAN BERIKUTNYA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(LucideIcons.moreHorizontal, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  nextStop.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        nextStop.address,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            kRouteCheckIn,
                            extra: {
                              'customerId': nextStop.id,
                              'customerName': nextStop.name,
                              'customerAddress': nextStop.address,
                              'targetLat': nextStop.latitude,
                              'targetLng': nextStop.longitude,
                              'targetRadiusMeters': 200.0,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _navy,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(LucideIcons.userCheck, size: 18),
                        label: const Text(
                          'Mulai Kunjungan',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _openMap,
                        icon: const Icon(LucideIcons.map, color: Colors.white),
                        tooltip: 'Buka Map',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
