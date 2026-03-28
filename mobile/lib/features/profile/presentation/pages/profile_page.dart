import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/router/route_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  // Mock Backend State
  bool _isLoading = false;
  Map<String, dynamic> _userProfile = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    
    // Simulate API call to fetch user profile
    await Future.delayed(const Duration(milliseconds: 600));
    
    setState(() {
      _isLoading = false;
      _userProfile = {
        'name': 'Alex Rivera',
        'role': 'SENIOR SALES EXECUTIVE',
        'email': 'alex.rivera@wowin.com',
        'phone': '+1 (555) 234-5678',
        'location': 'Austin, TX, USA',
        'language': 'English',
        'imageUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      };
    });
  }

  Future<void> _handleLogout() async {
    // Simulate Logout
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: _orange)),
    );
    
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    context.pop(); // Remove dialog
    // Navigate strictly back to login in real scenario. Since there's no auth route explicit here, placeholder.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
    // context.goNamed(kRouteLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: _orange))
          : _buildProfileContent(),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF4B5563)),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.settings, color: Color(0xFF4B5563), size: 22),
          onPressed: () => context.pushNamed(kRouteSettings),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    if (_userProfile.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSectionTitle('PERSONAL INFORMATION'),
          const SizedBox(height: 12),
          _buildPersonalInfoCard(),
          const SizedBox(height: 32),
          _buildSectionTitle('ACCOUNT SETTINGS'),
          const SizedBox(height: 12),
          _buildAccountSettingsCard(),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFED7AA), width: 2), // Light orange halo
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundImage: NetworkImage(_userProfile['imageUrl']),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(LucideIcons.edit2, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _userProfile['name'],
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _userProfile['role'],
          style: const TextStyle(
            color: _orange,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.mail, size: 14, color: _textSecondary.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(
              _userProfile['email'],
              style: TextStyle(
                color: _textSecondary.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildInfoItem(
            icon: LucideIcons.user,
            iconColor: _orange,
            iconBg: const Color(0xFFFFF7ED),
            label: 'Full Name',
            value: _userProfile['name'],
            showDivider: true,
          ),
          _buildInfoItem(
            icon: LucideIcons.phone,
            iconColor: _orange,
            iconBg: const Color(0xFFFFF7ED),
            label: 'Phone Number',
            value: _userProfile['phone'],
            showDivider: true,
          ),
          _buildInfoItem(
            icon: LucideIcons.mapPin,
            iconColor: _orange,
            iconBg: const Color(0xFFFFF7ED),
            label: 'Location',
            value: _userProfile['location'],
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: LucideIcons.bell,
            title: 'Notifications',
            showDivider: true,
          ),
          _buildSettingItem(
            icon: LucideIcons.shield,
            title: 'Security & Privacy',
            showDivider: true,
          ),
          _buildSettingItem(
            icon: LucideIcons.globe,
            title: 'Language',
            trailingText: _userProfile['language'],
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Color(0xFFD1D5DB), size: 20),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 62), // Matches content alignment
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF4B5563), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronRight, color: Color(0xFFD1D5DB), size: 20),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 62),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: _handleLogout,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFDC2626), // Red
        minimumSize: const Size(double.infinity, 54),
        side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
        backgroundColor: const Color(0xFFFEF2F2).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(LucideIcons.logOut, size: 20),
          SizedBox(width: 8),
          Text(
            'Log Out',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
          _buildNavItem(LucideIcons.users, 'Leads', false, () {}),
          _buildNavItem(LucideIcons.checkSquare, 'Tasks', false, () => context.goNamed(kRouteTasks)),
          _buildNavItem(LucideIcons.user, 'Profile', true, () {}),
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
            isActive ? Icons.account_circle : icon, 
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
            ),
          ),
        ],
      ),
    );
  }
}
