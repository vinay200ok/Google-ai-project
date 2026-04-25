import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../../services/mock/mock_data_service.dart';

class NotificationNotifier extends StateNotifier<List<NotificationEntity>> {
  NotificationNotifier()
      : super(
          MockDataService.getNotifications()
              .map((m) => NotificationEntity.fromMap(m))
              .toList(),
        );

  void markRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(read: true)).toList();
  }

  int get unreadCount => state.where((n) => !n.read).length;
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationEntity>>((ref) {
  return NotificationNotifier();
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider.notifier).unreadCount;
});
