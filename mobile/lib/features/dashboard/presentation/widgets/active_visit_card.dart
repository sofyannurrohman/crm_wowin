import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/visits/presentation/widgets/check_out_sheet.dart';
import '../../../../features/visits/presentation/bloc/visit_bloc.dart';
import '../../../../features/visits/presentation/bloc/visit_state.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../features/visits/presentation/bloc/visit_event.dart';
import 'dart:async';
import 'dart:ui';

class ActiveVisitCard extends StatefulWidget {
  final String scheduleId;
  final String customerName;
  final DateTime startTime;
  final String? customerId;
  final String? leadId;
  final String? taskDestinationId;

  const ActiveVisitCard({
    super.key,
    required this.scheduleId,
    required this.customerId,
    this.leadId,
    this.taskDestinationId,
    required this.customerName,
    required this.startTime,
  });

  @override
  State<ActiveVisitCard> createState() => _ActiveVisitCardState();
}

class _ActiveVisitCardState extends State<ActiveVisitCard> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.startTime);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                LucideIcons.activity,
                size: 100,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Live animated ACTIVE badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (c) => c.repeat()).fade(duration: 500.ms),
                            const SizedBox(width: 6),
                            const Text(
                              'ACTIVE VISIT',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Live timer display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.clock, size: 12, color: Colors.white70),
                            const SizedBox(width: 5),
                            Text(
                              _formatDuration(_elapsed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.customerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kunjungan Sedang Berlangsung',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // Navigate to Add Deal Page with current customer context
                            final newDealId = await context.pushNamed<String>(
                              'add_deal', // Route name for kRouteAddDeal
                              extra: {
                                'initialCustomerId': widget.customerId,
                                'initialCustomerName': widget.customerName,
                                'initialLeadId': widget.leadId,
                              },
                            );

                            if (newDealId != null && mounted) {
                              context.read<VisitBloc>().add(LinkDealToVisit(newDealId));
                            }
                          },
                          icon: const Icon(LucideIcons.shoppingBag, size: 18),
                          label: const Text('BUAT PENJUALAN'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Unify flow: Navigate to OngoingVisitPage instead of bottom sheet
                            final visitState = context.read<VisitBloc>().state;
                            String? currentDealId;
                            if (visitState is VisitSuccess) {
                               currentDealId = visitState.currentDealId;
                            }

                            context.pushNamed(
                              kRouteOngoingVisit,
                              extra: {
                                'scheduleId': widget.scheduleId,
                                'customerId': widget.customerId,
                                'leadId': widget.leadId,
                                'customerName': widget.customerName,
                                'taskDestinationId': widget.taskDestinationId,
                                'checkInTime': widget.startTime,
                                'dealId': currentDealId,
                              },
                            );
                          },
                          icon: const Icon(LucideIcons.timer, size: 18),
                          label: const Text('LIHAT TIMER'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1A237E),
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
