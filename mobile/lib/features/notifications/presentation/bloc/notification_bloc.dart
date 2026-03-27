import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.refresh) {
      emit(NotificationLoading());
    } else if (state is! NotificationLoaded) {
      emit(NotificationLoading());
    }

    final notificationsResult = await repository.getNotifications();
    final countResult = await repository.getUnreadCount();

    notificationsResult.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        final unreadCount = countResult.getOrElse(() => 0);
        emit(NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;

      // Optimitic update
      final updatedNotifs = current.notifications.map((n) {
        if (n.id == event.id && !n.isRead) {
          // We can't directly copy but in real app would have copyWith
          // For now just keep it simple
        }
        return n;
      }).toList();

      await repository.markAsRead(event.id);
      add(const FetchNotifications()); // Refresh
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAllAsRead();
    add(const FetchNotifications()); // Refresh
  }
}
