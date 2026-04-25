import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/zone_entity.dart';
import '../../../../services/mock/mock_data_service.dart';
import '../../../../services/gemini/gemini_service.dart';

// Zones stream provider
final zonesStreamProvider = StreamProvider<List<ZoneEntity>>((ref) {
  return MockDataService.zonesStream().map(
    (list) => list.map((m) => ZoneEntity.fromMap(m)).toList(),
  );
});

// AI tips provider
final aiTipsProvider = FutureProvider.family<List<String>, String>((ref, zone) async {
  return GeminiService.instance.getQuickTips(
    userZone: zone,
    crowdPercent: 72,
    nearestQueueMins: 8,
  );
});

// Stadium summary stats
final stadiumStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final zonesAsync = ref.watch(zonesStreamProvider);
  return zonesAsync.when(
    data: (zones) {
      if (zones.isEmpty) return _defaultStats();
      final totalOcc = zones.fold<int>(0, (s, z) => s + z.currentOccupancy);
      final totalCap = zones.fold<int>(0, (s, z) => s + z.capacity);
      final critical = zones.where((z) => z.isCritical).length;
      return {
        'totalOccupancy': totalOcc,
        'totalCapacity': totalCap,
        'occupancyPercent': totalCap > 0 ? totalOcc / totalCap : 0.0,
        'criticalZones': critical,
        'clearZones': zones.where((z) => z.densityLevel == 'low').length,
      };
    },
    loading: _defaultStats,
    error: (_, __) => _defaultStats(),
  );
});

Map<String, dynamic> _defaultStats() => {
      'totalOccupancy': 0,
      'totalCapacity': 50000,
      'occupancyPercent': 0.0,
      'criticalZones': 0,
      'clearZones': 0,
    };
