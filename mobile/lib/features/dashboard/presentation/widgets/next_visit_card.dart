import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/visit_recommendation.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task.dart' as task_ent;
import '../../../../core/theme/app_colors.dart';

class NextVisitCard extends StatelessWidget {
  final VisitRecommendation nextStop;
  final task_ent.Task? parentTask;

  const NextVisitCard({
    super.key,
    required this.nextStop,
    this.parentTask,
  });

  static const Color _emerald = AppColors.primary;

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
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _emerald.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.navigation, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'TUJUAN BERIKUTNYA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              nextStop.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 18, color: Colors.white70),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nextStop.address,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (parentTask != null) {
                        context.pushNamed(
                          kRouteRoutePlanner,
                          extra: parentTask,
                        );
                        return;
                      }
                      
                      context.pushNamed(
                        kRouteCheckIn,
                        extra: {
                          'scheduleId': 'task',
                          'customerId': nextStop.customerId,
                          'leadId': nextStop.leadId,
                          'taskDestinationId': nextStop.taskDestinationId,
                          'dealId': nextStop.dealId,
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
                      foregroundColor: _emerald,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(LucideIcons.userCheck, size: 24),
                    label: const Text(
                      'MULAI VISIT',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: _openMap,
                    icon: const Icon(LucideIcons.map, color: Colors.white, size: 28),
                    tooltip: 'Buka Map',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
