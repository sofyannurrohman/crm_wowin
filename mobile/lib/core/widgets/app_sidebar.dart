import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../router/route_constants.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  static const Color _primaryGreen = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDrawerItem(context, LucideIcons.home, 'Beranda', () => _navigate(context, kRouteDashboard)),
                _buildDrawerItem(context, LucideIcons.checkSquare, 'Tugas & Rute', () => _navigate(context, kRouteTasks)),
                _buildDrawerItem(context, LucideIcons.userPlus, 'Calon Toko (Leads)', () => _navigate(context, kRouteLeads)),
                _buildDrawerItem(context, LucideIcons.users, 'Daftar Toko', () => _navigate(context, kRouteCustomers)),
                _buildDrawerItem(context, LucideIcons.package, 'Katalog Produk', () => _navigate(context, kRouteProducts)),
                _buildDrawerItem(context, LucideIcons.columns, 'Penjualan (Kanban)', () => _navigate(context, kRouteDeals)),
                
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                
                _buildDrawerItem(context, LucideIcons.history, 'Riwayat Aktivitas', () => _navigate(context, kRouteActivityLog)),
                _buildDrawerItem(context, LucideIcons.settings, 'Pengaturan', () => _navigate(context, kRouteSettings)),
                
                const SizedBox(height: 40),
                _buildDrawerItem(
                  context, 
                  LucideIcons.logOut, 
                  'Keluar Aplikasi', 
                  () {
                    context.pop();
                    context.goNamed(kRouteLogin);
                  },
                  iconColor: Colors.red,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Pengguna Sales';
        String userEmail = 'sales@wowin.com';
        
        if (state is Authenticated) {
          userName = state.user.name;
          userEmail = state.user.email;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
          decoration: const BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(LucideIcons.user, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                userName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    VoidCallback onTap, {
    Color? iconColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF64748B)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFF334155), size: 26),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
      ),
    );
  }

  void _navigate(BuildContext context, String routeName) {
    context.pop();
    context.goNamed(routeName);
  }
}
