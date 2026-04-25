import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/fan_message_entity.dart';
import '../../../../services/mock/mock_data_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const _uuid = Uuid();

class FanZoneNotifier extends StateNotifier<List<FanMessageEntity>> {
  FanZoneNotifier() : super([]);
}

final fanMessagesStreamProvider = StreamProvider<List<FanMessageEntity>>((ref) {
  return MockDataService.fanMessagesStream().map(
    (list) => list.map((m) => FanMessageEntity.fromMap(m)).toList(),
  );
});

// Local messages sent by this user (prepended to stream)
final localMessagesProvider =
    StateProvider<List<FanMessageEntity>>((ref) => []);

final sendFanMessageProvider = Provider((ref) {
  return (String text, WidgetRef widgetRef) {
    final auth = widgetRef.read(authProvider);
    final user = auth.user;
    if (user == null || text.trim().isEmpty) return;
    final msg = FanMessageEntity(
      id: _uuid.v4(),
      userId: user.uid,
      userName: user.name,
      text: text.trim(),
      zoneId: user.currentZone,
      createdAt: DateTime.now(),
    );
    widgetRef.read(localMessagesProvider.notifier).update((msgs) => [msg, ...msgs]);
  };
});
