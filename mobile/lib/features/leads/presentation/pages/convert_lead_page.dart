import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/lead.dart';
import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';

class ConvertLeadPage extends StatelessWidget {
  final Lead lead;

  const ConvertLeadPage({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Convert to Deal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<LeadBloc, LeadState>(
        listener: (context, state) {
          if (state is LeadOperationSuccess) {
            _showSuccessDialog(context);
          } else if (state is LeadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              _buildRocketIcon(),
              const SizedBox(height: 32),
              const Text(
                'Konversi Prospek',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 12),
              Text(
                'Ubah "${lead.name}" menjadi pelanggan tetap dan buat peluang baru di pipeline Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.6),
              ),
              const SizedBox(height: 48),
              _buildModernSummaryCard(),
              const SizedBox(height: 64),
              _buildConvertButton(context),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Nanti Saja', style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: const Icon(LucideIcons.check, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Berhasil Konversi!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Prospek kini telah menjadi customer dan deal baru telah dibuat.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.pop(true); // Return to list with success
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Buka Pipeline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRocketIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE8622A), Color(0xFFF97316)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: const Color(0xFFE8622A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: const Icon(LucideIcons.rocket, size: 56, color: Colors.white),
    );
  }

  Widget _buildModernSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _buildInfoItem('PROSPEK UTAMA', lead.name, LucideIcons.user),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          _buildInfoItem('NAMA PERUSAHAAN', lead.company ?? '-', LucideIcons.building),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          _buildInfoItem('TIPE DEAL', 'Project Solution', LucideIcons.briefcase),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1A237E), letterSpacing: 1.0)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConvertButton(BuildContext context) {
    return BlocBuilder<LeadBloc, LeadState>(
      builder: (context, state) {
        final isLoading = state is LeadLoading;
        return Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 6))],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : () => context.read<LeadBloc>().add(ConvertLeadSubmitted(lead.id)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Konversi Sekarang', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                      Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFE8622A).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(LucideIcons.rocket, size: 48, color: Color(0xFFE8622A)),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUMMARY VIEW',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF8E8E93), letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Lead Title', lead.title, LucideIcons.type),
          const Divider(height: 24),
          _buildInfoRow('Customer', lead.name, LucideIcons.user),
          const Divider(height: 24),
          _buildInfoRow('Sales Cycle', 'New Pipeline Item', LucideIcons.trendingUp),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
      ],
    );
  }
}
