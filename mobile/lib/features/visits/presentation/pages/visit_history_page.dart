import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_state.dart';
import '../../../../core/router/route_constants.dart';

class VisitHistoryPage extends StatefulWidget {
  const VisitHistoryPage({super.key});

  @override
  State<VisitHistoryPage> createState() => _VisitHistoryPageState();
}

class _VisitHistoryPageState extends State<VisitHistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  static const Color _orange = Color(0xFFEA580C);
  static const Color _lightOrangeBtn = Color(0xFFFFF7ED);
  static const Color _bg = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  // Mock data representing the UI design
  final List<Map<String, dynamic>> _mockVisitsToday = [
    {
      'company': 'TechCorp Solutions',
      'contact': 'John Doe',
      'purpose': 'Quarterly Review',
      'time': '10:30 AM',
      'status': 'COMPLETED',
      'imageUrl': 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=120&h=120&fit=crop',
    },
    {
      'company': 'Green Valley Grocers',
      'contact': 'Sarah Miller',
      'purpose': 'Site Inspection',
      'time': '02:15 PM',
      'status': 'FOLLOW-UP SET',
      'imageUrl': 'https://images.unsplash.com/photo-1497215848143-df9c16b25206?w=120&h=120&fit=crop',
    },
  ];

  final List<Map<String, dynamic>> _mockVisitsYesterday = [
    {
      'company': 'Apex Manufacturing',
      'contact': 'Robert Chen',
      'purpose': 'Equipment Demo',
      'time': '11:00 AM',
      'status': 'COMPLETED',
      'imageUrl': 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=120&h=120&fit=crop',
    },
    {
      'company': 'Blue Harbor Logistics',
      'contact': 'Jessica Hunt',
      'purpose': 'Contract Signing',
      'time': '04:45 PM',
      'status': 'ON HOLD',
      'imageUrl': 'https://images.unsplash.com/photo-1586528116311-ad8ed7c663e0?w=120&h=120&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    // In a real implementation: context.read<VisitBloc>().add(FetchVisits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          // Replace with real logic: if (state is VisitsLoading) ...
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80), // For FAB
                  children: [
                    _buildSectionHeader('TODAY, OCT 24'),
                    ..._mockVisitsToday.map((v) => _buildVisitItem(v)).toList(),
                    _buildSectionHeader('YESTERDAY, OCT 23'),
                    ..._mockVisitsYesterday.map((v) => _buildVisitItem(v)).toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic for scheduling a new visit
        },
        backgroundColor: _orange,
        elevation: 4,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            decoration: const BoxDecoration(
              color: _lightOrangeBtn,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.arrowLeft, color: _orange, size: 20),
          ),
        ),
      ),
      title: const Text(
        'Visit History',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.calendar, color: _textSecondary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by customer name',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            prefixIcon: Icon(LucideIcons.search, color: Color(0xFF9CA3AF), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (val) {
            // Backend logic for search
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildVisitItem(Map<String, dynamic> visit) {
    Color badgeColor;
    Color badgeBgColor;
    Color badgeTextColor;

    switch (visit['status']) {
      case 'COMPLETED':
        badgeColor = const Color(0xFF22C55E);      // Green
        badgeBgColor = const Color(0xFFDCFCE7);    // Light Green
        badgeTextColor = const Color(0xFF166534);  // Dark Green Text
        break;
      case 'FOLLOW-UP SET':
        badgeColor = const Color(0xFFEA580C);      // Orange
        badgeBgColor = const Color(0xFFFFF7ED);    // Light Orange
        badgeTextColor = const Color(0xFFC2410C);  // Dark Orange Text
        break;
      case 'ON HOLD':
      default:
        badgeColor = const Color(0xFF6B7280);      // Gray
        badgeBgColor = const Color(0xFFF3F4F6);    // Light Gray
        badgeTextColor = const Color(0xFF374151);  // Dark Gray Text
        break;
    }

    return GestureDetector(
      onTap: () {
        // Navigation route to Visit Detail Page parameterized by visit ID.
        // E.g., context.pushNamed(kRouteVisitDetail, pathParameters: {'id': visit['id']});
        context.pushNamed(kRouteVisitDetail, pathParameters: {'id': '123'});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(visit['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        visit['company'],
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      visit['time'],
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${visit['contact']} - ${visit['purpose']}',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    visit['status'],
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.home, 'Home', false, onTap: () => context.goNamed(kRouteDashboard)),
          _buildNavItem(LucideIcons.history, 'Visits', true), // Visits is active with History style icon
          _buildNavItem(LucideIcons.users, 'Customers', false, onTap: () => context.goNamed(kRouteCustomers)),
          _buildNavItem(LucideIcons.settings, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _orange : const Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _orange : const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
