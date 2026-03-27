import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<NotificationBloc>()
        .add(const FetchNotifications(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context
                  .read<NotificationBloc>()
                  .add(MarkAllNotificationsAsRead());
            },
            icon: const Icon(Icons.person, size: 20),
            tooltip: 'Tandai semua dibaca',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<NotificationBloc>()
              .add(const FetchNotifications(refresh: true));
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami akan memberi tahu Anda di sini',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade100, indent: 72),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Material(
          color: notif.isRead
              ? Colors.transparent
              : AppColors.primary.withOpacity(0.03),
          child: InkWell(
            onTap: () {
              if (!notif.isRead) {
                context
                    .read<NotificationBloc>()
                    .add(MarkNotificationAsRead(notif.id));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getNotifColor(notif.type).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getNotifIcon(notif.type),
                          color: _getNotifColor(notif.type),
                          size: 20,
                        ),
                      ),
                      if (!notif.isRead)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
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
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            fontSize: 15,
                            color: notif.isRead
                                ? AppColors.textPrimary
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.body,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMM, HH:mm').format(notif.createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'visit_reminder':
        return Icons.person;
      case 'follow_up':
        return Icons.person;
      case 'deal_update':
        return Icons.person;
      case 'approval':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'visit_reminder':
        return AppColors.primary;
      case 'follow_up':
        return AppColors.accent;
      case 'deal_update':
        return AppColors.success;
      case 'approval':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
