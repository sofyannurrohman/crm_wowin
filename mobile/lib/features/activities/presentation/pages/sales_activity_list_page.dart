import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../bloc/sales_activity_bloc.dart';
import '../bloc/sales_activity_event.dart';
import '../bloc/sales_activity_state.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class SalesActivityListPage extends StatefulWidget {
  const SalesActivityListPage({super.key});

  @override
  State<SalesActivityListPage> createState() => _SalesActivityListPageState();
}

class _SalesActivityListPageState extends State<SalesActivityListPage> {
  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() {
    context.read<SalesActivityBloc>().add(const FetchSalesActivities());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Aktivitas Sales', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 20),
            onPressed: _fetchActivities,
          ),
        ],
      ),
      body: BlocBuilder<SalesActivityBloc, SalesActivityState>(
        builder: (context, state) {
          if (state is SalesActivityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesActivityError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is SalesActivityLoaded) {
            if (state.activities.isEmpty) {
              return const EmptyStateWidget(
                icon: LucideIcons.calendarX,
                title: 'Belum Ada Aktivitas',
                message: 'Catat aktivitas harianmu untuk melacak perkembangan hubungan dengan klien.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _fetchActivities(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.activities.length,
                itemBuilder: (context, index) {
                  final activity = state.activities[index];
                  return _buildActivityCard(activity);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/activities/add');
          if (result == true) {
            _fetchActivities();
          }
        },
        backgroundColor: const Color(0xFFE8622A),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildActivityCard(dynamic activity) {
    // Assuming activity is SalesActivity entity
    final date = activity.createdAt != null 
        ? DateFormat('dd MMM yyyy, HH:mm').format(activity.createdAt!) 
        : 'Unknown Date';
    
    IconData icon;
    Color iconColor;
    
    switch (activity.activityType.toLowerCase()) {
      case 'visit':
        icon = LucideIcons.mapPin;
        iconColor = Colors.blue;
        break;
      case 'negotiation':
        icon = LucideIcons.messageSquare;
        iconColor = Colors.orange;
        break;
      case 'deal':
        icon = LucideIcons.users;
        iconColor = Colors.green;
        break;
      case 'follow_up':
        icon = LucideIcons.phoneCall;
        iconColor = Colors.purple;
        break;
      default:
        icon = LucideIcons.activity;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.activityType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: iconColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (activity.notes != null && activity.notes!.isNotEmpty)
                        Text(
                          activity.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
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
                Icon(LucideIcons.calendar, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),
                if (activity.lead != null) ...[
                  _buildTag(LucideIcons.user, activity.lead!.name, Colors.blueGrey),
                ] else if (activity.customer != null) ...[
                  _buildTag(LucideIcons.building, activity.customer!.name, Colors.teal),
                ] else if (activity.deal != null) ...[
                  _buildTag(LucideIcons.briefcase, activity.deal!.title, Colors.indigo),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
