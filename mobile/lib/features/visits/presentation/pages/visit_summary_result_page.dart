import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

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
    if (h > 0) return '$h hours $m mins';
    if (m > 0) return '$m mins $s secs';
    return '$s secs';
  }

  Color _outcomeColor(String outcome) {
    if (['PO Submitted', 'Sample Given', 'Price Negotiation'].contains(outcome)) {
      return const Color(0xFF10B981); 
    }
    if (['Rejected', 'No Answer'].contains(outcome)) {
      return const Color(0xFFEF4444); 
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    HapticFeedback.heavyImpact();
    final color = _outcomeColor(outcome);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.05)),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2000.ms),
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
                    ),
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [color, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                      child: const Icon(LucideIcons.check, size: 36, color: Colors.white),
                    ).animate().scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              Text('Visit Successful!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 12),
              Text(customerName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w600)).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 48),

              _SummaryCard(icon: LucideIcons.target, label: 'OUTCOME', value: outcome, valueColor: color).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 16),
              _SummaryCard(icon: LucideIcons.clock9, label: 'DURATION', value: _formatDuration(visitDuration)).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
              const SizedBox(height: 16),
              if (nextAction.isNotEmpty)
                _SummaryCard(icon: LucideIcons.arrowRight, label: 'NEXT ACTION', value: nextAction).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),

              const SizedBox(height: 24),

              Row(
                children: [
                  if (hasInventory)
                    Expanded(child: _BadgeCard(icon: LucideIcons.clipboardList, label: 'Stock Logged', color: const Color(0xFF6366F1))),
                  if (hasInventory && hasSignature) const SizedBox(width: 12),
                  if (hasSignature)
                    Expanded(child: _BadgeCard(icon: LucideIcons.pencil, label: 'Signed', color: const Color(0xFF3B82F6))),
                ],
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 60),

              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                child: const Text('BACK TO DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary, minimumSize: const Size(double.infinity, 64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text('VIEW VISIT HISTORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
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

  const _SummaryCard({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)), child: Icon(icon, size: 20, color: AppColors.textPlaceholder)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textPlaceholder, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: valueColor ?? AppColors.textPrimary)),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
