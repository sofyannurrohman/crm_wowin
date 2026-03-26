import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const FetchNotifications(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NotificationBloc>().add(MarkAllNotificationsAsRead());
            },
            icon: const Icon(Icons.done_all),
            tooltip: 'Tandai semua dibaca',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<NotificationBloc>().add(const FetchNotifications(refresh: true));
        },
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState();
              }
              return _buildNotificationList(state.notifications);
            } else if (state is NotificationError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Belum ada notifikasi untuk Anda'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Container(
          color: notif.isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotifColor(notif.type).withOpacity(0.1),
              child: Icon(_getNotifIcon(notif.type), color: _getNotifColor(notif.type)),
            ),
            title: Text(
              notif.title,
              style: TextStyle(
                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.body),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM, HH:mm').format(notif.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            onTap: () {
              if (!notif.isRead) {
                context.read<NotificationBloc>().add(MarkNotificationAsRead(notif.id));
              }
              // Handle redirection based on entity_type if needed
            },
          ),
        );
      },
    );
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'visit_reminder': return Icons.calendar_today;
      case 'follow_up': return Icons.reply;
      case 'deal_update': return Icons.assignment_turned_in;
      case 'approval': return Icons.verified_user;
      default: return Icons.notifications;
    }
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'visit_reminder': return Colors.blue;
      case 'follow_up': return Colors.orange;
      case 'deal_update': return Colors.green;
      case 'approval': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
