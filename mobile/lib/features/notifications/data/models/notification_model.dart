import '../../domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required String id,
    required String type,
    required String title,
    required String body,
    String? entityType,
    String? entityId,
    required bool isRead,
    DateTime? readAt,
    required DateTime createdAt,
  }) : super(
          id: id,
          type: type,
          title: title,
          body: body,
          entityType: entityType,
          entityId: entityId,
          isRead: isRead,
          readAt: readAt,
          createdAt: createdAt,
        );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
