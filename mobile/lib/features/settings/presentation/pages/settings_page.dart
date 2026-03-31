import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../bloc/settings_bloc.dart';
import '../../domain/entities/user_settings.dart';
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  String _cacheSize = '124 MB';

  Future<void> _handleClearCache() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: _orange)),
    );
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _cacheSize = '0 MB';
      });
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      drawer: AppSidebar(),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsInitial || state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator(color: _orange));
          }
          
          if (state is SettingsError) {
            return Center(child: Text(state.message));
          }

          if (state is SettingsLoaded) {
            final s = state.settings;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildSectionTitle('GENERAL PREFERENCES'),
                  _buildGeneralPreferencesSection(s),
                  const SizedBox(height: 16),
                  _buildSectionTitle('TRACKING & SYSTEM'),
                  _buildTrackingSystemSection(s),
                  const SizedBox(height: 40),
                  _buildAppFooter(),
                  const SizedBox(height: 48),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(LucideIcons.menu, color: _orange),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'Settings',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey.shade100, height: 1.0),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: _orange,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildGeneralPreferencesSection(UserSettings settings) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildListTile(
            icon: LucideIcons.globe,
            title: 'App Language',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settings.language,
                  style: TextStyle(
                    color: _textSecondary.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey.shade400),
              ],
            ),
            onTap: () {},
            showDivider: true,
          ),
          _buildListTile(
            icon: LucideIcons.bell,
            title: 'Notifications',
            trailingWidget: CupertinoSwitch(
              value: settings.notificationsEnabled,
              activeColor: _orange,
              onChanged: (val) {
                context.read<SettingsBloc>().add(UpdateSettingChanged('mobile.notifications_enabled', val));
              },
            ),
            onTap: null,
            showDivider: true,
          ),
          _buildListTile(
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            trailingWidget: CupertinoSwitch(
              value: settings.darkModeEnabled,
              activeColor: _orange,
              onChanged: (val) {
                context.read<SettingsBloc>().add(UpdateSettingChanged('mobile.dark_mode_enabled', val));
              },
            ),
            onTap: null,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSystemSection(UserSettings settings) {
    final interval = settings.gpsIntervalSeconds;
    final intervalLabel = interval < 60 ? '$interval secs' : '${interval ~/ 60} mins';

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildListTile(
            icon: LucideIcons.mapPin,
            title: 'GPS Tracking Interval',
            subtitle: 'Update frequency for location data',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  intervalLabel,
                  style: TextStyle(
                    color: _textSecondary.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey.shade400),
              ],
            ),
            onTap: () {},
            showDivider: true,
          ),
          _buildListTile(
            icon: LucideIcons.trash2,
            title: 'Clear Cache',
            trailingWidget: Text(
              _cacheSize,
              style: TextStyle(
                color: _textSecondary.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: _cacheSize != '0 MB' ? _handleClearCache : null,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailingWidget,
    VoidCallback? onTap,
    required bool showDivider,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _orange, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: _textSecondary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailingWidget,
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 66),
              child: Divider(height: 1, color: Colors.grey.shade100),
            ),
        ],
      ),
    );
  }

  Widget _buildAppFooter() {
    return Column(
      children: [
        const Text(
          'Wowin CR Mobile',
          style: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Version 2.4.0 (Build 892)',
          style: TextStyle(
            color: _textSecondary.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

}
