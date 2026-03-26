import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? entityType;
  final String? entityId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.entityType,
    this.entityId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, title, body, entityType, entityId, isRead, readAt, createdAt];
}
