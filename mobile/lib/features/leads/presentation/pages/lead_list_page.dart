import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/utils/animation_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  final TextEditingController _searchController = TextEditingController();
  
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Baru', 'Memenuhi Syarat'];

  Future<void> _launchWA(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    final url = Uri.parse('whatsapp://send?phone=$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse('https://wa.me/$cleanPhone');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    }
  }

  Future<void> _launchMaps(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  void _fetchLeads() {
    String? status;
    switch (_selectedTabIndex) {
      case 0:
        status = 'new';
        break;
      case 1:
        status = 'qualified';
        break;
    }

    final authState = context.read<AuthBloc>().state;
    String? salesId;
    if (authState is Authenticated && authState.user.role == 'sales') {
      salesId = authState.user.id;
    }

    context.read<LeadBloc>().add(
          FetchLeads(
            query: _searchController.text,
            status: status,
            salesId: salesId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.pushNamed(kRouteAddLead),
        icon: const Icon(LucideIcons.userPlus, color: Colors.white, size: 20),
        label: const Text(
          'Add Lead',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: BlocListener<LeadBloc, LeadState>(
        listener: (context, state) {
          if (state is LeadOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
            _fetchLeads(); 
          } else if (state is LeadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: Stack(
          children: [
            // Premium Header Decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildFilterTabs(),
                  Expanded(child: _buildLeadsList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(LucideIcons.menu, color: Colors.white, size: 22),
              ),
            ),
          ),
          const Column(
            children: [
              Text(
                'Leads Pipeline',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Opportunity Management',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 44), 
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Search by name, email or source...',
            hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.normal),
            prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            suffixIcon: _searchController.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _fetchLeads();
                  },
                )
              : null,
          ),
          onSubmitted: (_) => _fetchLeads(),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                _fetchLeads();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade200,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeadsList() {
    return BlocBuilder<LeadBloc, LeadState>(
      builder: (context, state) {
        if (state is LeadLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        } else if (state is LeadsLoaded) {
          if (state.leads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.userX, size: 48, color: AppColors.textPlaceholder.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No leads found in this stage',
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async => _fetchLeads(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: state.leads.length,
              itemBuilder: (context, index) {
                final lead = state.leads[index];
                return _buildLeadCard(lead).animateEntrance(
                  delay: Duration(milliseconds: index * 50),
                  offset: const Offset(0, 20),
                );
              },
            ),
          );
        } else if (state is LeadError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLeadCard(dynamic lead) {
    String initials = '';
    if (lead.name.isNotEmpty) {
      final parts = lead.name.split(' ');
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}';
      } else {
        initials = parts[0][0];
      }
    }

    Color statusColor;
    String statusStr = (lead.status ?? 'new').toLowerCase();

    if (statusStr == 'new' || statusStr == 'baru') {
      statusColor = const Color(0xFF3B82F6);
      statusStr = 'NEW LEAD';
    } else if (statusStr == 'contacted' || statusStr == 'dihubungi') {
      statusColor = const Color(0xFFF59E0B);
      statusStr = 'CONTACTED';
    } else if (statusStr == 'qualified' || statusStr == 'memenuhi syarat') {
      statusColor = const Color(0xFF10B981);
      statusStr = 'QUALIFIED';
    } else {
      statusColor = AppColors.textPlaceholder;
      statusStr = 'ARCHIVED';
    }

    IconData sourceIcon = LucideIcons.globe;
    String sourceText = lead.source.isNotEmpty ? (lead.source[0].toUpperCase() + lead.source.substring(1)) : 'Unknown';
    if (sourceText.toLowerCase().contains('referral')) {
      sourceIcon = LucideIcons.share2;
    } else if (sourceText.toLowerCase().contains('email')) {
      sourceIcon = LucideIcons.mail;
    } else if (sourceText.toLowerCase().contains('phone') || sourceText.toLowerCase().contains('call')) {
      sourceIcon = LucideIcons.phone;
    }

    return GestureDetector(
      onTap: () => context.pushNamed(kRouteLeadDetail, pathParameters: {'id': lead.id}, extra: lead),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Premium Initial Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.1), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                lead.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(statusStr, statusColor),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(LucideIcons.user, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              lead.name,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 12),
                            Icon(sourceIcon, size: 12, color: AppColors.textPlaceholder),
                            const SizedBox(width: 4),
                            Text(
                              sourceText,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (lead.potentialProducts != null && lead.potentialProducts!.isNotEmpty) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primary.withOpacity(0.04),
                child: Row(
                  children: [
                    const Icon(LucideIcons.package, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${lead.potentialProducts!.length} INTERESTED PRODUCTS',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildActionBtn(LucideIcons.messageSquare, const Color(0xFF25D366), () => _launchWA(lead.phone)),
                        const SizedBox(width: 10),
                        _buildActionBtn(LucideIcons.map, const Color(0xFF4285F4), () => _launchMaps(lead.latitude, lead.longitude)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (lead.status == 'new' || lead.status == 'contacted')
                    Expanded(
                      flex: 2,
                      child: _buildQuickActionBtn(
                        label: lead.status == 'new' ? 'REACH OUT' : 'QUALIFY LEAD',
                        icon: lead.status == 'new' ? LucideIcons.phoneCall : LucideIcons.checkCircle,
                        color: lead.status == 'new' ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        onTap: () => _updateStatus(lead.id, lead.status == 'new' ? 'contacted' : 'qualified'),
                      ),
                    ),
                  const SizedBox(width: 8),
                  _buildMoreButton(lead),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildQuickActionBtn({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(dynamic lead) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.textPlaceholder),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'edit') {
          context.pushNamed(kRouteAddLead, extra: lead);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, lead);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.edit2, size: 16, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text('Edit Lead', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 16, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Lead?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove "${lead.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete(context, lead.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Delete Now', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, String id) {
    context.read<LeadBloc>().add(DeleteLeadSubmitted(id));
  }

  void _updateStatus(String id, String status) {
    context.read<LeadBloc>().add(UpdateLeadStatusSubmitted(id: id, status: status));
  }
}

