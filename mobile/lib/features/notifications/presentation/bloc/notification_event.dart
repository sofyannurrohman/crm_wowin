import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class FetchNotifications extends NotificationEvent {
  final bool refresh;
  const FetchNotifications({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String id;
  const MarkNotificationAsRead(this.id);

  @override
  List<Object> get props => [id];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}
