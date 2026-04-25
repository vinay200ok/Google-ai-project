import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/gemini/gemini_service.dart';
import '../../../home/domain/entities/zone_entity.dart';

class MapState {
  final String selectedZoneId;
  final String? navigationAdvice;
  final bool isLoadingNav;
  final List<ZoneEntity> zones;

  const MapState({
    this.selectedZoneId = 'zone_pavilion',
    this.navigationAdvice,
    this.isLoadingNav = false,
    this.zones = const [],
  });

  MapState copyWith({
    String? selectedZoneId,
    String? navigationAdvice,
    bool? isLoadingNav,
    List<ZoneEntity>? zones,
  }) =>
      MapState(
        selectedZoneId: selectedZoneId ?? this.selectedZoneId,
        navigationAdvice: navigationAdvice ?? this.navigationAdvice,
        isLoadingNav: isLoadingNav ?? this.isLoadingNav,
        zones: zones ?? this.zones,
      );
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(const MapState());

  void updateZones(List<ZoneEntity> zones) {
    state = state.copyWith(zones: zones);
  }

  void selectZone(String zoneId) {
    state = state.copyWith(selectedZoneId: zoneId, navigationAdvice: null);
  }

  Future<void> getNavigation(String destination) async {
    state = state.copyWith(isLoadingNav: true);

    final crowded = state.zones
        .where((z) => z.isHigh)
        .map((z) => z.name)
        .toList();
    final clear = state.zones
        .where((z) => z.densityLevel == 'low')
        .map((z) => z.name)
        .toList();

    final advice = await GeminiService.instance.getNavigationAdvice(
      userZone: state.selectedZoneId,
      destination: destination,
      crowdedZones: crowded,
      clearZones: clear,
    );

    state = state.copyWith(navigationAdvice: advice, isLoadingNav: false);
  }

  void clearNavigation() {
    state = state.copyWith(navigationAdvice: null);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
