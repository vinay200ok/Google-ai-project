import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/queue_entity.dart';
import '../../../../services/mock/mock_data_service.dart';

final queuesStreamProvider = StreamProvider<List<QueueEntity>>((ref) {
  return MockDataService.queuesStream().map(
    (list) => list.map((m) => QueueEntity.fromMap(m)).toList(),
  );
});

// Filter type: 'all', 'food', 'restroom', 'merchandise', 'entry'
final queueFilterProvider = StateProvider<String>((ref) => 'all');

final filteredQueuesProvider = Provider<AsyncValue<List<QueueEntity>>>((ref) {
  final queues = ref.watch(queuesStreamProvider);
  final filter = ref.watch(queueFilterProvider);
  return queues.when(
    data: (list) {
      if (filter == 'all') return AsyncValue.data(list);
      return AsyncValue.data(list.where((q) => q.type == filter).toList());
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
