import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/router/route_constants.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Calls', 'Emails', 'Meetings'];

  // Mock Backend State
  bool _isLoading = false;
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isLoading = false;
      _activities = [
        {
          'group': 'TODAY',
          'items': [
            {
              'title': 'Call with Acme Corp',
              'desc': 'Discussed Q4 projections and budget approvals for the upcoming product launch.',
              'time': '10:30 AM',
              'type': 'call',
            },
            {
              'title': 'Email sent to John Doe',
              'desc': 'Sent follow-up proposal with adjusted pricing tiers as requested during the demo.',
              'time': '09:15 AM',
              'type': 'email',
            },
          ]
        },
        {
          'group': 'YESTERDAY',
          'items': [
            {
              'title': 'Meeting at TechCorp',
              'desc': 'Initial project kickoff. Met with the engineering lead and defined technical constraints.',
              'time': '02:00 PM',
              'type': 'meeting',
            },
            {
              'title': 'Note added to Leads',
              'desc': 'Customer expressed high interest in the enterprise dashboard feature.',
              'time': '11:45 AM',
              'type': 'note',
            },
          ]
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: _orange))
          : _buildActivityList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _orange,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF4B5563)),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Activity Log',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.search, color: Color(0xFF4B5563), size: 22),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTab == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? _orange : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? _orange : _textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: _activities.length,
      itemBuilder: (context, groupIndex) {
        final group = _activities[groupIndex];
        final items = group['items'] as List;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                group['group'],
                style: TextStyle(
                  color: _textSecondary.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ...List.generate(items.length, (index) {
              final item = items[index];
              return _buildActivityNode(item, isLast: index == items.length - 1 && groupIndex == _activities.length - 1);
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildActivityNode(Map<String, dynamic> item, {required bool isLast}) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (item['type']) {
      case 'call':
        icon = LucideIcons.phone;
        iconColor = _orange;
        iconBgColor = const Color(0xFFFFF7ED);
        break;
      case 'email':
        icon = LucideIcons.mail;
        iconColor = const Color(0xFF3B82F6); // Blue
        iconBgColor = const Color(0xFFEFF6FF);
        break;
      case 'meeting':
        icon = LucideIcons.users;
        iconColor = const Color(0xFF10B981); // Green
        iconBgColor = const Color(0xFFF0FDF4);
        break;
      case 'note':
      default:
        icon = LucideIcons.fileText;
        iconColor = const Color(0xFF4B5563); // Gray
        iconBgColor = const Color(0xFFF3F4F6);
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item['time'],
                        style: TextStyle(
                          color: _textSecondary.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['desc'],
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 14,
                      height: 1.5,
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
          _buildNavItem(LucideIcons.history, 'Activities', true, () {}), // Activities active
          _buildNavItem(LucideIcons.checkSquare, 'Tasks', false, () => context.goNamed(kRouteTasks)),
          _buildNavItem(Icons.more_horiz, 'More', false, () {}),
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
