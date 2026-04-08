import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/api/api_endpoints.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // changed orange -> new green #0D8549
  static const Color _orange = Color(0xFF0D8549);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(FetchProfile());
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );

    if (confirmed == true) {
      if (!mounted) return;
      context.read<AuthBloc>().add(LogoutRequested());
      // AuthGuard or AppRouter usually handles the redirect to Login based on AuthState
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.goNamed(kRouteLogin);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        UserEntity? user;
        bool isLoading = false;

        if (state is Authenticated) {
          user = state.user;
        } else if (state is AuthLoading) {
          isLoading = true;
        }

        return Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(),
          drawer: const AppSidebar(),
          body: isLoading 
              ? const Center(child: CircularProgressIndicator(color: _orange))
              : (user != null ? _buildProfileContent(user) : const Center(child: Text('Gagal memuat profil'))),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(LucideIcons.menu, color: Color(0xFF4B5563)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
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

  Widget _buildProfileContent(UserEntity user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildHeader(user),
          const SizedBox(height: 32),
          _buildSectionTitle('PERSONAL INFORMATION'),
          const SizedBox(height: 12),
          _buildPersonalInfoCard(user),
          const SizedBox(height: 32),
          _buildSectionTitle('ACCOUNT SETTINGS'),
          const SizedBox(height: 12),
          _buildAccountSettingsCard(user),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeader(UserEntity user) {
    final avatarUrl = user.avatarPath != null 
      ? '${ApiEndpoints.uploadsBaseUrl}${user.avatarPath}'
      // update avatar bg param from EA580C -> 0D8549
      : 'https://ui-avatars.com/api/?name=${user.name}&background=0D8549&color=fff';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCFF1E0), width: 2),
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundImage: NetworkImage(avatarUrl),
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
          user.name,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.role.toUpperCase(),
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
              user.email,
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

  Widget _buildPersonalInfoCard(UserEntity user) {
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
            value: user.name,
            showDivider: true,
            onTap: () => _showEditDialog('Update Full Name', user.name, (val) {
              context.read<AuthBloc>().add(UpdateProfileRequested(name: val));
            }),
          ),
          _buildInfoItem(
            icon: LucideIcons.phone,
            iconColor: _orange,
            iconBg: const Color(0xFFFFF7ED),
            label: 'Phone Number',
            value: user.phone ?? 'Not set',
            showDivider: true,
            onTap: () => _showEditDialog('Update Phone Number', user.phone ?? '', (val) {
              context.read<AuthBloc>().add(UpdateProfileRequested(phone: val));
            }),
          ),
          _buildInfoItem(
            icon: LucideIcons.hash,
            iconColor: _orange,
            iconBg: const Color(0xFFFFF7ED),
            label: 'Employee Code',
            value: user.employeeCode ?? '-',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard(UserEntity user) {
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
            trailingText: 'Indonesian',
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
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
                if (onTap != null)
                  const Icon(LucideIcons.edit2, color: Color(0xFFD1D5DB), size: 16)
                else
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
      ),
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

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _orange)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _orange, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

}
