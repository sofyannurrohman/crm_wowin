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
  static const Color _darkGreen = AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, l10n),
          const SizedBox(height: 8),
          _buildDrawerItem(
            context, 
            LucideIcons.layoutDashboard, 
            l10n.home, 
            () => _navigate(context, kRouteDashboard),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.checkSquare, 
            l10n.tasks, 
            () => _navigate(context, kRouteTasks),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.userPlus, 
            l10n.leads, 
            () => _navigate(context, kRouteLeads),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.users, 
            l10n.customers, 
            () => _navigate(context, kRouteCustomers),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.package, 
            l10n.productCatalog, 
            () => _navigate(context, kRouteProducts),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.columns, 
            'Pipeline Kanban', 
            () => _navigate(context, kRouteDeals),
          ),
          
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              l10n.historyAndLogs,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.map, 
            l10n.routeHistory, 
            () => _navigate(context, kRouteRouteHistory),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.list, 
            l10n.activityLog, 
            () => _navigate(context, kRouteActivityLog),
          ),
          
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          
          _buildDrawerItem(
            context, 
            LucideIcons.user, 
            l10n.profile, 
            () => _navigate(context, kRouteProfile),
          ),
          _buildDrawerItem(
            context, 
            LucideIcons.settings, 
            l10n.settings, 
            () => _navigate(context, kRouteSettings),
          ),
          
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          
          _buildDrawerItem(
            context, 
            LucideIcons.logOut, 
            'Logout', 
            () {
              // Add logout logic here via AuthBloc if needed
              context.pop();
              context.goNamed(kRouteLogin);
            },
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Sales User';
        String userEmail = 'sales@wowin.com';
        
        if (state is Authenticated) {
          userName = state.user.name;
          userEmail = state.user.email;
        }

        return Container(
          padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
          decoration: const BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(LucideIcons.user, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
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
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF4B5563), size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF111827),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }

  void _navigate(BuildContext context, String routeName) {
    context.pop(); // Close drawer
    
    // Use goNamed for top-level navigation to avoid stacking
    context.goNamed(routeName);
  }
}
