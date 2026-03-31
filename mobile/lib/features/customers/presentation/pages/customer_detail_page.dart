import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
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
        body: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            if (state is CustomerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CustomerDetailLoaded) {
              final customer = state.customer;
              return Scaffold(
                backgroundColor: const Color(0xFFF9FAFB),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: const Text(
                    'Customer Details',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
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
                      icon: const Icon(LucideIcons.moreVertical,
                          color: AppColors.textPrimary),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(LucideIcons.edit2, size: 18),
                              SizedBox(width: 8),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                body: BlocListener<CustomerBloc, CustomerState>(
                  listener: (context, state) {
                    if (state is CustomerOperationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green),
                      );
                      if (state.message.contains('hapus')) {
                        Navigator.of(context).pop(); // Back to list on delete
                      }
                    }
                  },
                  child: _buildContent(customer),
                ),
              );
            } else if (state is CustomerError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text(
            'Apakah Anda yakin ingin menghapus ${customer.companyName ?? customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<CustomerBloc>()
                  .add(DeleteCustomerSubmitted(customer.id));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Customer customer) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 20),
        _buildProfileHeader(customer),
        const SizedBox(height: 24),
        _buildContactInfoCard(customer),
        const SizedBox(height: 24),
        _buildMapSection(customer),
        const SizedBox(height: 32),
        _buildTabs(),
        const SizedBox(height: 16),
        _buildTabContent(customer),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProfileHeader(Customer customer) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              LucideIcons.building2,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          customer.companyName ?? customer.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTag(
              customer.industry ?? 'Food',
              const Color(0xFFFFF7ED),
              const Color(0xFFF97316),
            ),
            const SizedBox(width: 8),
            _buildTag(
              customer.status ?? 'Active Client',
              const Color(0xFFF0FDF4),
              const Color(0xFF22C55E),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            LucideIcons.user,
            'Contact Person',
            customer.name,
            iconColor: const Color(0xFFF97316),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          _buildInfoRow(
            LucideIcons.phone,
            'Phone',
            customer.phone ?? '-',
            iconColor: const Color(0xFFF97316),
            valueColor: const Color(0xFFF97316),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          _buildInfoRow(
            LucideIcons.mail,
            'Email',
            customer.email ?? '-',
            iconColor: const Color(0xFFF97316),
            valueColor: const Color(0xFFF97316),
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
        Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection(Customer customer) {
    final lat = customer.latitude ?? -6.200000;
    final lng = customer.longitude ?? 106.816666;

    return Container(
      clipBehavior: Clip.antiAlias,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lat, lng),
              initialZoom: 14.0,
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
                    child: const Icon(Icons.location_on, color: Color(0xFFF97316), size: 30),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 16, color: Color(0xFFF97316)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.address ?? 'San José, Costa Rica',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                      maxLines: 1,
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
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFF97316),
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: const Color(0xFFF97316),
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'Activity Log'),
          Tab(text: 'Deals'),
          Tab(text: 'Visit History'),
        ],
        onTap: (index) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildTabContent(Customer customer) {
    switch (_tabController.index) {
      case 0:
        return _buildActivityLog();
      case 1:
        return _buildDealsList(customer);
      case 2:
        return _buildVisitHistory(customer);
      default:
        return const SizedBox();
    }
  }

  Widget _buildActivityLog() {
    final activities = [
      {
        'type': 'call',
        'title': 'Outgoing Call',
        'description': 'Discussed annual maintenance contract renewal. Follow up next Tuesday.',
        'time': 'TODAY, 10:30 AM',
        'icon': LucideIcons.phone,
        'iconBg': const Color(0xFFFFF7ED),
        'iconColor': const Color(0xFFF97316),
      },
      {
        'type': 'email',
        'title': 'Email Received',
        'description': 'Requested quotation for new assembly line components.',
        'time': 'YESTERDAY, 4:15 PM',
        'icon': LucideIcons.mail,
        'iconBg': const Color(0xFFEFF6FF),
        'iconColor': const Color(0xFF3B82F6),
      },
      {
        'type': 'deal',
        'title': 'Deal Won: Q3 Supplies',
        'description': 'Contract signed for \$12,400. Delivery scheduled for Oct 1st.',
        'time': 'SEP 12, 2023',
        'icon': LucideIcons.badgeCheck,
        'iconBg': const Color(0xFFF0FDF4),
        'iconColor': const Color(0xFF22C55E),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: activity['iconBg'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      size: 18,
                      color: activity['iconColor'] as Color,
                    ),
                  ),
                  if (index != activities.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: const Color(0xFFFFE4D6),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['description'] as String,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity['time'] as String,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDealsList(Customer customer) {
    // This should ideally use a Bloc to fetch deals for this customer
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'No active deals found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildVisitHistory(Customer customer) {
    // This should ideally use a Bloc to fetch visit history
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'No visit history available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
