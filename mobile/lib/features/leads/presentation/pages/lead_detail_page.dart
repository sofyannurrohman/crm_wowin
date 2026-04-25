import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';
import 'package:wowin_crm/features/leads/domain/entities/lead.dart';
import 'package:wowin_crm/features/visits/presentation/bloc/visit_bloc.dart';
import 'package:wowin_crm/features/visits/presentation/bloc/visit_event.dart';
import 'package:wowin_crm/features/visits/presentation/bloc/visit_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart' as auth;
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../../auth/presentation/bloc/auth_event.dart' as auth;

class LeadDetailPage extends StatefulWidget {
  final Lead lead;
  const LeadDetailPage({super.key, required this.lead});

  @override
  State<LeadDetailPage> createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends State<LeadDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<LeadBloc>()),
        BlocProvider(create: (context) => sl<VisitBloc>()..add(FetchActivities(leadId: widget.lead.id))),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<auth.AuthBloc, auth.AuthState>(
          builder: (context, authState) {
            final currentUser = (authState is auth.Authenticated) ? authState.user : null;
            final bool isOwner = currentUser != null && 
                (widget.lead.salesId?.toLowerCase().trim() == currentUser.id.toLowerCase().trim());
            final bool isAdmin = currentUser?.role == 'admin';
            final bool isLocked = !isOwner && !isAdmin;

            return Column(
              children: [
                _buildPremiumHeader(context, isLocked),
                
                if (isLocked)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.lock, color: Color(0xFFEF4444), size: 18),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This record is locked because it is managed by another salesman.',
                              style: TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 10),
                _buildTabBar(),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(isLocked),
                      _buildActivityTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<auth.AuthBloc, auth.AuthState>(
          builder: (context, authState) {
             final currentUser = (authState is auth.Authenticated) ? authState.user : null;
             final bool isOwner = currentUser != null && (widget.lead.salesId == currentUser.id);
             final bool isAdmin = currentUser?.role == 'admin';
             final bool isLocked = !isOwner && !isAdmin;
             
             if (isLocked) return const SizedBox.shrink();
             return _buildBottomActions(context);
          },
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, bool isLocked) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  ),
                  const Text(
                    'Lead Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!isLocked)
                    IconButton(
                      onPressed: () => context.pushNamed(kRouteAddLead, extra: widget.lead),
                      icon: const Icon(LucideIcons.edit3, color: Colors.white, size: 22),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildProfileSection(isLocked),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(bool isLocked) {
    String initials = '';
    if (widget.lead.name.isNotEmpty) {
      final parts = widget.lead.name.split(' ');
      initials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}' : parts[0][0];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBadge(widget.lead.status),
                const SizedBox(height: 8),
                Text(
                  isLocked ? _obscureText(widget.lead.name) : widget.lead.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.lead.company ?? 'Individual Lead',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'new':
        color = const Color(0xFF3B82F6);
        break;
      case 'contacted':
        color = const Color(0xFFF59E0B);
        break;
      case 'qualified':
        color = const Color(0xFF10B981);
        break;
      case 'unqualified':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == Colors.white ? Colors.white : color.withOpacity(0.9),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.2),
        tabs: const [
          Tab(text: 'General Info'),
          Tab(text: 'Activities'),
        ],
      ),
    );
  }

  Widget _buildInfoTab(bool isLocked) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 10),
        _buildInfoCard(
          title: 'Contact Details',
          items: [
            _buildInfoItem(LucideIcons.phone, 'Phone Number', isLocked ? _obscureText(widget.lead.phone) : (widget.lead.phone ?? '-'), valueColor: const Color(0xFF10B981)),
            _buildInfoItem(LucideIcons.mail, 'Email Address', isLocked ? _obscureText(widget.lead.email) : (widget.lead.email ?? '-'), valueColor: const Color(0xFF3B82F6)),
            _buildInfoItem(LucideIcons.mapPin, 'Location / Address', isLocked ? 'Protected' : (widget.lead.address ?? '-')),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          title: 'Business Potential',
          items: [
            _buildInfoItem(LucideIcons.trendingUp, 'Estimated Value', 
              (isLocked) ? '*******' : (widget.lead.estimatedValue != null 
                ? NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(widget.lead.estimatedValue)
                : '-'), valueColor: AppColors.primary),
            _buildInfoItem(LucideIcons.package, 'Interested Products', 
              isLocked ? '*******' : (widget.lead.potentialProducts?.join(', ') ?? '-')),
            _buildInfoItem(LucideIcons.info, 'Lead Source', isLocked ? '*******' : widget.lead.source.toUpperCase()),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          title: 'Internal Notes',
          items: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                isLocked ? 'Notes are hidden for non-owners' : (widget.lead.notes ?? 'No internal notes provided.'),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  String _obscureText(String? text) {
    if (text == null || text == '-' || text.isEmpty) return '-';
    if (text.length <= 4) return '****';
    return '${text.substring(0, 2)}********${text.substring(text.length - 2)}';
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.textPrimary, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textPlaceholder, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w800, 
                    color: valueColor ?? AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        if (state is VisitLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        } else if (state is ActivitiesLoaded) {
          if (state.activities.isEmpty) {
            return _buildEmptyActivity();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: state.activities.length,
            itemBuilder: (context, index) {
              final activity = state.activities[index];
              return _buildActivityItem(activity, index == state.activities.length - 1);
            },
          );
        } else if (state is VisitError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyActivity() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.activity, size: 64, color: AppColors.textPlaceholder.withOpacity(0.3)),
        const SizedBox(height: 16),
        const Text(
          'No Activities Found',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Interactions and visits will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActivityItem(dynamic activity, bool isLast) {
    final date = activity.createdAt;
    final type = activity.type.toLowerCase();
    final isCheckIn = type.contains('check-in') || type == 'checkin';
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCheckIn ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(color: isCheckIn ? AppColors.primary.withOpacity(0.1) : const Color(0xFFDCFCE7)),
                ),
                child: Icon(
                  isCheckIn ? LucideIcons.mapPin : LucideIcons.checkCircle,
                  size: 18,
                  color: isCheckIn ? AppColors.primary : const Color(0xFF10B981),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCheckIn ? 'Visit Check-In' : 'Visit Completed',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 15),
                      ),
                      Text(
                        DateFormat('HH:mm').format(date),
                        style: const TextStyle(fontSize: 11, color: AppColors.textPlaceholder, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(date),
                    style: const TextStyle(fontSize: 11, color: AppColors.textPlaceholder, fontWeight: FontWeight.w500),
                  ),
                  if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      activity.notes!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildActionButton(
                icon: LucideIcons.phone,
                label: 'Call',
                onPressed: () {},
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildActionButton(
                icon: LucideIcons.layout,
                label: 'Survey',
                onPressed: () => context.pushNamed(
                  kRouteAddBanner,
                  extra: {'lead': widget.lead},
                ),
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildActionButton(
                icon: LucideIcons.checkCircle,
                label: 'Qualify',
                onPressed: () => context.pushNamed(kRouteConvertLead, extra: widget.lead),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }
}
