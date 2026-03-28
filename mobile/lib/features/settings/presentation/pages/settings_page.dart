import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/router/route_constants.dart';

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

  // Mock Backend / Preferences State
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _appLanguage = 'English';
  String _gpsInterval = '5 mins';
  String _cacheSize = '124 MB';

  Future<void> _handleClearCache() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: _orange)),
    );
    
    // Simulate cache clearing backend logic
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _cacheSize = '0 MB';
      });
      context.pop(); // Remove dialog
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('GENERAL PREFERENCES'),
            _buildGeneralPreferencesSection(),
            const SizedBox(height: 16),
            _buildSectionTitle('TRACKING & SYSTEM'),
            _buildTrackingSystemSection(),
            const SizedBox(height: 40),
            _buildAppFooter(),
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: _orange),
        onPressed: () => context.pop(),
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

  Widget _buildGeneralPreferencesSection() {
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
                  _appLanguage,
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
              value: _notificationsEnabled,
              activeColor: _orange,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                // Trigger backend preference update
              },
            ),
            onTap: null,
            showDivider: true,
          ),
          _buildListTile(
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            trailingWidget: CupertinoSwitch(
              value: _darkModeEnabled,
              activeColor: _orange,
              onChanged: (val) {
                setState(() => _darkModeEnabled = val);
                // Trigger backend preference update
              },
            ),
            onTap: null,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSystemSection() {
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
                  _gpsInterval,
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

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.home, 'Home', false, () => context.goNamed(kRouteDashboard)),
          _buildNavItem(LucideIcons.fileText, 'Reports', false, () {}),
          _buildNavItem(LucideIcons.checkSquare, 'Tasks', false, () => context.goNamed(kRouteTasks)),
          _buildNavItem(LucideIcons.settings, 'Settings', true, () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isActive ? _orange : const Color(0xFF9CA3AF), 
            size: 24
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _orange : const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
