import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class VisitSummaryResultPage extends StatelessWidget {
  final String customerName;
  final String outcome;
  final String nextAction;
  final Duration visitDuration;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final bool hasSignature;
  final bool hasInventory;

  const VisitSummaryResultPage({
    super.key,
    required this.customerName,
    required this.outcome,
    required this.nextAction,
    required this.visitDuration,
    required this.checkInTime,
    required this.checkOutTime,
    this.hasSignature = false,
    this.hasInventory = false,
  });

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '$h jam $m menit';
    if (m > 0) return '$m menit $s detik';
    return '$s detik';
  }

  Color _outcomeColor(String outcome) {
    if (['PO Submitted', 'Sample Given', 'Price Negotiation'].contains(outcome)) {
      return const Color(0xFF16A34A); // green for positive outcomes
    }
    if (['Rejected', 'No Answer'].contains(outcome)) {
      return const Color(0xFFDC2626); // red for negative
    }
    return const Color(0xFFEA580C); // orange for neutral
  }

  @override
  Widget build(BuildContext context) {
    HapticFeedback.heavyImpact();
    final color = _outcomeColor(outcome);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Success icon ──────────────────────────────
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.08),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1500.ms),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15)),
                    ),
                    Icon(LucideIcons.checkCircle2, size: 48, color: color)
                        .animate()
                        .scale(begin: const Offset(0, 0), duration: 400.ms, curve: Curves.elasticOut),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ──────────────────────────────────────
              Text(
                'Kunjungan Selesai!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              Text(
                customerName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              // ── Summary Cards ──────────────────────────────
              _SummaryCard(
                icon: LucideIcons.target,
                label: 'Hasil Kunjungan',
                value: outcome,
                valueColor: color,
              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

              const SizedBox(height: 12),

              _SummaryCard(
                icon: LucideIcons.clock9,
                label: 'Durasi Kunjungan',
                value: _formatDuration(visitDuration),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

              const SizedBox(height: 12),

              if (nextAction.isNotEmpty)
                _SummaryCard(
                  icon: LucideIcons.arrowRight,
                  label: 'Tindakan Selanjutnya',
                  value: nextAction,
                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),

              const SizedBox(height: 12),

              // ── Data collected indicators ──────────────────
              Row(
                children: [
                  if (hasInventory)
                    Expanded(
                      child: _BadgeCard(
                        icon: LucideIcons.clipboardList,
                        label: 'Stok Dicatat',
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  if (hasInventory && hasSignature) const SizedBox(width: 12),
                  if (hasSignature)
                    Expanded(
                      child: _BadgeCard(
                        icon: LucideIcons.pencil,
                        label: 'Tanda Tangan',
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 40),

              // ── CTA Buttons ────────────────────────────────
              ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(LucideIcons.home, size: 18),
                label: const Text('KEMBALI KE DASHBOARD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.clipboardList, size: 18),
                label: const Text('LIHAT RIWAYAT KUNJUNGAN'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A237E),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFF1A237E)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF374151)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor ?? const Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BadgeCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}
