import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart' as auth;
import '../../../../features/auth/presentation/bloc/auth_state.dart' as auth;
import '../../../../features/auth/presentation/bloc/auth_event.dart' as auth;
import 'package:wowin_crm/features/deals/domain/entities/deal.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_activity.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_schedule.dart';
import '../../domain/entities/customer.dart';

class CustomerDetailPage extends StatefulWidget {
  final String id;
  const CustomerDetailPage({super.key, required this.id});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CustomerBloc>()..add(FetchCustomerDetail(widget.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<auth.AuthBloc, auth.AuthState>(
          builder: (context, authState) {
            final currentUser = (authState is auth.Authenticated)
                ? authState.user
                : null;
            
            return BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (state is CustomerDetailLoaded) {
                  final customer = state.customer;
                  final bool isOwner = currentUser != null && 
                      (customer.salesId?.toLowerCase().trim() == currentUser.id.toLowerCase().trim());
                  final bool isAdmin = currentUser?.role == 'admin';
                  final bool isLocked = !isOwner && !isAdmin;

                  return Scaffold(
                    backgroundColor: AppColors.background,
                    extendBodyBehindAppBar: true,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      leading: IconButton(
                        icon: const Icon(LucideIcons.arrowLeft,
                            color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: const Text(
                        'Customer Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        if (!isLocked)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.pushNamed(
                                  kRouteAddCustomer,
                                  extra: state.customer,
                                );
                              } else if (value == 'delete') {
                                _showDeleteConfirmation(context, state.customer);
                              }
                            },
                            icon: const Icon(LucideIcons.moreHorizontal,
                                color: Colors.white),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.edit2, size: 18),
                                    SizedBox(width: 12),
                                    Text('Edit Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.trash2,
                                        size: 18, color: Colors.red),
                                    SizedBox(width: 12),
                                    Text('Delete Customer',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    bottomNavigationBar: isLocked ? null : Container(
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
                              child: ElevatedButton.icon(
                                onPressed: () => context.pushNamed(
                                  kRouteAddBanner,
                                  extra: {'customer': customer},
                                ),
                                icon: const Icon(LucideIcons.layout, size: 18),
                                label: const Text('Survey Spanduk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: BlocListener<CustomerBloc, CustomerState>(
                      listener: (context, state) {
                        if (state is CustomerOperationSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.success),
                          );
                          if (state.message.contains('hapus')) {
                            Navigator.of(context).pop(); 
                          }
                        }
                      },
                      child: _buildContent(customer, state, isLocked, salesmanName: customer.salesmanName),
                    ),
                  );
                } else if (state is CustomerError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Pelanggan', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
            'Apakah Anda yakin ingin menghapus ${customer.companyName ?? customer.name}? Tindakan ini permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<CustomerBloc>()
                  .add(DeleteCustomerSubmitted(customer.id));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Customer customer, CustomerDetailLoaded state, bool isLocked, {String? salesmanName}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPremiumHeader(customer),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                if (isLocked)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.lock, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Data ini dikunci karena dimiliki oleh salesman lain${salesmanName != null ? " ($salesmanName)" : ""}.',
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                _buildContactInfoCard(customer, isLocked),
                const SizedBox(height: 24),
                _buildMapSection(customer, isLocked),
                const SizedBox(height: 32),
                if (!isLocked) ...[
                  _buildTabs(),
                  const SizedBox(height: 20),
                  _buildTabContent(customer, state),
                  const SizedBox(height: 100),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(Customer customer) {
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
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                customer.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                customer.companyName ?? customer.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag(
                  customer.industry ?? 'Food & Beverage',
                  Colors.white.withOpacity(0.15),
                  Colors.white,
                ),
                const SizedBox(width: 10),
                _buildTag(
                  customer.status ?? 'Active Client',
                  AppColors.success.withOpacity(0.8),
                  Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _obscureText(String? text) {
    if (text == null || text == '-' || text.isEmpty) return '-';
    if (text.length <= 4) return '****';
    return '${text.substring(0, 2)}********${text.substring(text.length - 2)}';
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(Customer customer, bool isLocked) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            LucideIcons.user,
            'PIC Name',
            isLocked ? _obscureText(customer.name) : customer.name,
            iconColor: AppColors.primary,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildInfoRow(
            LucideIcons.phone,
            'Phone Number',
            isLocked ? _obscureText(customer.phone) : (customer.phone ?? '-'),
            iconColor: const Color(0xFF10B981),
            valueColor: const Color(0xFF10B981),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildInfoRow(
            LucideIcons.mail,
            'Email Address',
            isLocked ? _obscureText(customer.email) : (customer.email ?? '-'),
            iconColor: const Color(0xFF3B82F6),
            valueColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.textSecondary).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapSection(Customer customer, bool isLocked) {
    final lat = customer.latitude ?? -6.200000;
    final lng = customer.longitude ?? 106.816666;

    return Container(
      clipBehavior: Clip.antiAlias,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (!isLocked)
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.wowin.crm',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      child: const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 36),
                    ),
                  ],
                ),
              ],
            )
          else
            Container(
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.mapPinOff, size: 48, color: AppColors.textPlaceholder),
                    SizedBox(height: 16),
                    Text('Location Locked', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 18, color: Color(0xFFEF4444)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isLocked ? 'Address hidden for security' : (customer.address ?? 'Jakarta, Indonesia'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.2),
        tabs: const [
          Tab(text: 'Activity'),
          Tab(text: 'Deals'),
          Tab(text: 'Visits'),
        ],
        onTap: (index) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildTabContent(Customer customer, CustomerDetailLoaded state) {
    switch (_tabController.index) {
      case 0:
        return _buildActivityLog(state.activities);
      case 1:
        return _buildDealsList(state.deals);
      case 2:
        return _buildVisitHistory(state.schedules);
      default:
        return const SizedBox();
    }
  }

  Widget _buildActivityLog(List<VisitActivity> activities) {
    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(LucideIcons.activity, size: 48, color: AppColors.textPlaceholder.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('No recent activities.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isCheckIn = activity.type.toLowerCase().contains('check-in') || activity.type.toLowerCase() == 'checkin';
        
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
                  if (index != activities.length - 1)
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isCheckIn ? 'Check-in Visit' : 'Visit Completed',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(activity.createdAt),
                            style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activity.notes ?? 'Regular client visit and follow-up.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(activity.createdAt),
                        style: const TextStyle(
                          color: AppColors.textPlaceholder,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDealsList(List<Deal> deals) {
    if (deals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(LucideIcons.briefcase, size: 48, color: AppColors.textPlaceholder.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('No active deals found.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final deal = deals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.dollarSign, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deal.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(deal.stage.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp${NumberFormat("#,###", "id_ID").format(deal.amount ?? 0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text('Expected', style: TextStyle(color: AppColors.textPlaceholder, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisitHistory(List<VisitSchedule> schedules) {
    if (schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(LucideIcons.calendarDays, size: 48, color: AppColors.textPlaceholder.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('No visit schedules.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final isUpcoming = schedule.date.isAfter(DateTime.now());
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUpcoming ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.calendar,
                  color: isUpcoming ? const Color(0xFF3B82F6) : AppColors.textPlaceholder,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy').format(schedule.date),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: schedule.status == 'completed' ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  schedule.status.toUpperCase(),
                  style: TextStyle(
                    color: schedule.status == 'completed' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
