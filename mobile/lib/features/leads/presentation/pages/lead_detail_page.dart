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
        backgroundColor: const Color(0xFFF9FAFB),
        body: BlocBuilder<auth.AuthBloc, auth.AuthState>(
          builder: (context, authState) {
            final currentUser = (authState is auth.Authenticated) ? authState.user : null;
            final bool isOwner = currentUser != null && 
                (widget.lead.salesId?.toLowerCase().trim() == currentUser.id.toLowerCase().trim());
            final bool isAdmin = currentUser?.role == 'admin';
            final bool isLocked = !isOwner && !isAdmin;

            return Column(
              children: [
                _buildHeader(context, isLocked),
                if (isLocked)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.lock, color: Color(0xFFF97316), size: 18),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Data ini dikunci karena dimiliki oleh salesman lain.',
                            style: TextStyle(
                              color: Color(0xFFC2410C),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
             final currentUser = (authState is auth.Authenticated)
                 ? authState.user
                 : null;
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

  Widget _buildHeader(BuildContext context, bool isLocked) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  if (!isLocked)
                    IconButton(
                      onPressed: () => context.pushNamed(kRouteAddLead, extra: widget.lead),
                      icon: const Icon(LucideIcons.edit2, color: AppColors.textPrimary, size: 20),
                    ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(widget.lead.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.user, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLocked ? _obscureText(widget.lead.name) : widget.lead.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lead.company ?? 'No Company',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'new':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade600;
        break;
      case 'contacted':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade600;
        break;
      case 'qualified':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade600;
        break;
      case 'unqualified':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade600;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        tabs: const [
          Tab(text: 'Informasi'),
          Tab(text: 'Aktivitas'),
        ],
      ),
    );
  }

  Widget _buildInfoTab(bool isLocked) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildInfoCard(
          title: 'Kontak Detail',
          items: [
            _buildInfoItem(LucideIcons.phone, 'Telepon', isLocked ? _obscureText(widget.lead.phone) : (widget.lead.phone ?? '-')),
            _buildInfoItem(LucideIcons.mail, 'Email', isLocked ? _obscureText(widget.lead.email) : (widget.lead.email ?? '-')),
            _buildInfoItem(LucideIcons.mapPin, 'Alamat', isLocked ? 'Alamat disembunyikan' : (widget.lead.address ?? '-')),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Potensi Bisnis',
          items: [
            _buildInfoItem(LucideIcons.dollarSign, 'Estimasi Nilai', 
              (isLocked) ? '*******' : (widget.lead.estimatedValue != null 
                ? NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(widget.lead.estimatedValue)
                : '-')),
            _buildInfoItem(LucideIcons.package, 'Produk Potensial', 
              isLocked ? '*******' : (widget.lead.potentialProducts?.join(', ') ?? '-')),
            _buildInfoItem(LucideIcons.info, 'Sumber', isLocked ? '*******' : widget.lead.source),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Catatan',
          items: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                isLocked ? 'Catatan disembunyikan' : (widget.lead.notes ?? 'Tidak ada catatan.'),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 100),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
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
          return const Center(child: CircularProgressIndicator());
        } else if (state is ActivitiesLoaded) {
          if (state.activities.isEmpty) {
            return _buildEmptyActivity();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.activities.length,
            itemBuilder: (context, index) {
              final activity = state.activities[index];
              return _buildActivityItem(activity);
            },
          );
        } else if (state is VisitError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Siap mengambil data...'));
      },
    );
  }

  Widget _buildEmptyActivity() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.calendarX, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          'Belum ada aktivitas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Aktivitas kunjungan akan muncul di sini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActivityItem(dynamic activity) {
    // Assuming activity has createdAt, type, and notes
    final date = activity.createdAt;
    final type = activity.type; // check-in / check-out
    
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: type == 'check-in' ? AppColors.primary : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type == 'check-in' ? 'Check-In Kunjungan' : 'Check-Out Kunjungan',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        DateFormat('HH:mm').format(date),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(date),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      activity.notes!,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
              child: _buildActionButton(
                icon: LucideIcons.phone,
                label: 'Hubungi',
                onPressed: () {},
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: LucideIcons.layout,
                label: 'Survey',
                onPressed: () => context.pushNamed(
                  kRouteAddBanner,
                  extra: {'lead': widget.lead},
                ),
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
