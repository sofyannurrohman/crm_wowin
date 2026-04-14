import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../domain/entities/customer.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/animation_extensions.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Prospects', 'Active', 'Inactive'];

  static const Color _primaryGreen = Color(0xFF0D8549);
  static const Color _navy = Color(0xFF1A237E);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _chipBg = Color(0xFFE8EEF6);

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
    _fetchCustomers();
  }

  void _fetchCustomers() {
    String? status;
    if (_selectedFilter == 'Prospects') {
      status = 'prospect';
    } else if (_selectedFilter == 'Active') {
      status = 'active';
    } else if (_selectedFilter == 'Inactive') {
      status = 'inactive';
    }

    final authState = context.read<AuthBloc>().state;
    String? salesId;
    if (authState is Authenticated && authState.user.role == 'sales') {
      salesId = authState.user.id;
    }

    context.read<CustomerBloc>().add(
          FetchCustomers(
            query: _searchController.text,
            status: status,
            salesId: salesId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryGreen,
        onPressed: () => context.pushNamed(kRouteAddCustomer),
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text(
          'Tambah Pelanggan Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primaryGreen),
                    );
                  } else if (state is CustomersLoaded) {
                    if (state.customers.isEmpty) {
                      return EmptyStateWidget(
                        title: 'Pelanggan Tidak Ditemukan',
                        message: 'Coba ubah kata kunci pencarian atau filter status Anda.',
                        icon: LucideIcons.users,
                        onRetry: () {
                          _searchController.clear();
                          setState(() {
                            _selectedFilter = 'All';
                          });
                          _fetchCustomers();
                        },
                        retryLabel: 'Bersihkan Filter',
                      );
                    }
                    return RefreshIndicator(
                      color: _primaryGreen,
                      onRefresh: () async => _fetchCustomers(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.customers.length,
                        itemBuilder: (context, index) {
                          return _CustomerCard(
                            customer: state.customers[index],
                            onWA: () => _launchWA(state.customers[index].phone),
                            onMaps: () => _launchMaps(state.customers[index].latitude, state.customers[index].longitude),
                          ).animateEntrance(
                            delay: Duration(milliseconds: index * 50),
                            offset: const Offset(0, 10),
                          );
                        },
                      ),
                    );
                  } else if (state is CustomerError) {
                    return EmptyStateWidget(
                      title: 'Gagal Memuat Pelanggan',
                      message: state.message,
                      icon: LucideIcons.alertCircle,
                      onRetry: () => _fetchCustomers(),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.menu, color: _primaryGreen, size: 22),
              ),
            ),
          ),
          const Text(
            'Customers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 40), // Spacing instead of button
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search customers...',
            hintStyle: TextStyle(color: Color(0xFF8E8E93)),
            prefixIcon: Icon(LucideIcons.search, color: Color(0xFF8E8E93), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          onSubmitted: (_) => _fetchCustomers(),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                _fetchCustomers();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryGreen : _chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
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


}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onWA;
  final VoidCallback onMaps;
  const _CustomerCard({required this.customer, required this.onWA, required this.onMaps});

  static const Color _primaryGreen = Color(0xFF0D8549);
  static const Color _navy = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch ((customer.status ?? '').toUpperCase()) {
      case 'ACTIVE':
        statusColor = const Color(0xFF10B981);
        break;
      case 'PROSPECT':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'INACTIVE':
        statusColor = const Color(0xFF6B7280);
        break;
      default:
        statusColor = _navy;
    }

    return GestureDetector(
      onTap: () => context.pushNamed(
        kRouteCustomerDetail,
        pathParameters: {'id': customer.id},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      customer.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (customer.status ?? 'Prospect').toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${customer.industry ?? 'General Sector'}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons
                  Row(
                    children: [
                      _buildActionBtn(LucideIcons.messageCircle, Colors.green, onWA),
                      const SizedBox(width: 8),
                      _buildActionBtn(LucideIcons.map, Colors.blue, onMaps),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last interaction: Today', // Mocked as it's not in the entity yet
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, color: Colors.grey.shade400, size: 16),
                ],
              ),
            ),
          ],
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
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
