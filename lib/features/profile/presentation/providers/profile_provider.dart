import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileNotifier extends StateNotifier<UserEntity?> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(null) {
    state = ref.read(authProvider).user;
  }

  void updateZone(String zone) {
    if (state != null) {
      state = state!.copyWith(currentZone: zone);
    }
  }

  void updateName(String name) {
    if (state != null) state = state!.copyWith(name: name);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserEntity?>((ref) {
  return ProfileNotifier(ref);
});

// Settings
class SettingsState {
  final bool notificationsEnabled;
  final bool crowdAlertsEnabled;
  final bool eventUpdatesEnabled;
  final String selectedZone;

  const SettingsState({
    this.notificationsEnabled = true,
    this.crowdAlertsEnabled = true,
    this.eventUpdatesEnabled = true,
    this.selectedZone = 'zone_pavilion',
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? crowdAlertsEnabled,
    bool? eventUpdatesEnabled,
    String? selectedZone,
  }) =>
      SettingsState(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        crowdAlertsEnabled: crowdAlertsEnabled ?? this.crowdAlertsEnabled,
        eventUpdatesEnabled: eventUpdatesEnabled ?? this.eventUpdatesEnabled,
        selectedZone: selectedZone ?? this.selectedZone,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggle(String key) {
    switch (key) {
      case 'notifications':
        state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
      case 'crowdAlerts':
        state = state.copyWith(crowdAlertsEnabled: !state.crowdAlertsEnabled);
      case 'eventUpdates':
        state = state.copyWith(eventUpdatesEnabled: !state.eventUpdatesEnabled);
    }
  }

  void setZone(String zone) => state = state.copyWith(selectedZone: zone);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
