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
import '../../../../core/theme/app_colors.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Prospects', 'Active', 'Inactive'];

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
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.pushNamed(kRouteAddCustomer),
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
        label: const Text(
          'Add Customer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Stack(
        children: [
          // Premium Background Element
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),
          SafeArea(
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
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      } else if (state is CustomersLoaded) {
                        if (state.customers.isEmpty) {
                          return EmptyStateWidget(
                            title: 'No Customers Found',
                            message: 'Try adjusting your search or filters.',
                            icon: LucideIcons.users,
                            onRetry: () {
                              _searchController.clear();
                              setState(() {
                                _selectedFilter = 'All';
                              });
                              _fetchCustomers();
                            },
                            retryLabel: 'Clear Filters',
                          );
                        }
                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async => _fetchCustomers(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: state.customers.length,
                            itemBuilder: (context, index) {
                              return _CustomerCard(
                                customer: state.customers[index],
                                onWA: () => _launchWA(state.customers[index].phone),
                                onMaps: () => _launchMaps(state.customers[index].latitude, state.customers[index].longitude),
                              ).animateEntrance(
                                delay: Duration(milliseconds: index * 50),
                                offset: const Offset(0, 20),
                              );
                            },
                          ),
                        );
                      } else if (state is CustomerError) {
                        return EmptyStateWidget(
                          title: 'Failed to Load Customers',
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
        ],
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
                'Customers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Professional Network',
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
            hintText: 'Search by name or company...',
            hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.normal),
            prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            suffixIcon: _searchController.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _fetchCustomers();
                  },
                )
              : null,
          ),
          onSubmitted: (_) => _fetchCustomers(),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                _fetchCustomers();
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
                  filter,
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
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onWA;
  final VoidCallback onMaps;
  const _CustomerCard({required this.customer, required this.onWA, required this.onMaps});

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
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => context.pushNamed(
        kRouteCustomerDetail,
        pathParameters: {'id': customer.id},
      ),
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
                      customer.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (customer.status ?? 'Prospect').toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                customer.industry ?? 'General Sector',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(LucideIcons.mapPin, color: AppColors.textPlaceholder, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.address ?? 'Location not specified',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      _buildActionBtn(LucideIcons.messageSquare, const Color(0xFF25D366), onWA),
                      const SizedBox(width: 10),
                      _buildActionBtn(LucideIcons.map, const Color(0xFF4285F4), onMaps),
                    ],
                  ),
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
