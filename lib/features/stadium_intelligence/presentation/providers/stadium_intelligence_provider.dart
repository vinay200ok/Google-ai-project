import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gate_entity.dart';
import '../../domain/entities/stall_entity.dart';
import '../../../../services/mock/mock_data_service.dart';

// ── Gates stream provider ───────────────────────────────────────────────────
final gatesStreamProvider = StreamProvider<List<GateEntity>>((ref) {
  return MockDataService.gatesStream().map(
    (list) => list.map((m) => GateEntity.fromMap(m)).toList(),
  );
});

// ── Stalls stream provider ──────────────────────────────────────────────────
final stallsStreamProvider = StreamProvider<List<StallEntity>>((ref) {
  return MockDataService.stallsStream().map(
    (list) => list.map((m) => StallEntity.fromMap(m)).toList(),
  );
});

// ── Best gate (lowest crowd) ────────────────────────────────────────────────
final bestGateProvider = Provider<AsyncValue<GateEntity?>>((ref) {
  final gatesAsync = ref.watch(gatesStreamProvider);
  return gatesAsync.whenData((gates) {
    if (gates.isEmpty) return null;
    final sorted = [...gates]..sort((a, b) => a.crowd.compareTo(b.crowd));
    return sorted.first;
  });
});

// ── Selected stall for GO/WAIT ──────────────────────────────────────────────
final selectedStallIndexProvider = StateProvider<int>((ref) => 0);

final selectedStallProvider = Provider<AsyncValue<StallEntity?>>((ref) {
  final stallsAsync = ref.watch(stallsStreamProvider);
  final idx = ref.watch(selectedStallIndexProvider);
  return stallsAsync.whenData((stalls) {
    if (stalls.isEmpty) return null;
    return stalls[idx.clamp(0, stalls.length - 1)];
  });
});
