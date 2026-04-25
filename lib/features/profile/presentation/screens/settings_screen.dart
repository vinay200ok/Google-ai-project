import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('Notifications'),
            GlassCard(
              child: Column(children: [
                _ToggleTile(
                  icon: Icons.notifications_outlined,
                  label: 'Push Notifications',
                  sub: 'Crowd alerts, order updates, event highlights',
                  value: settings.notificationsEnabled,
                  onToggle: () => ref.read(settingsProvider.notifier).toggle('notifications'),
                ),
                _Divider(),
                _ToggleTile(
                  icon: Icons.warning_amber_outlined,
                  label: 'Crowd Alerts',
                  sub: 'Get notified when zones reach critical capacity',
                  value: settings.crowdAlertsEnabled,
                  onToggle: () => ref.read(settingsProvider.notifier).toggle('crowdAlerts'),
                  color: AppColors.warning,
                ),
                _Divider(),
                _ToggleTile(
                  icon: Icons.sports_soccer,
                  label: 'Event Updates',
                  sub: 'Goals, cards, and key match moments',
                  value: settings.eventUpdatesEnabled,
                  onToggle: () => ref.read(settingsProvider.notifier).toggle('eventUpdates'),
                  color: AppColors.secondary,
                ),
              ]),
            ),

            const SizedBox(height: 20),
            _SectionHeader('My Zone'),
            GlassCard(
              child: Column(children: [
                ...AppConstants.zoneIds.map((zoneId) {
                  final name = AppConstants.zoneNames[zoneId] ?? zoneId;
                  final selected = settings.selectedZone == zoneId;
                  return GestureDetector(
                    onTap: () => ref.read(settingsProvider.notifier).setZone(zoneId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
                      ),
                      child: Row(children: [
                        Icon(Icons.location_on_outlined,
                            color: selected ? AppColors.primary : AppColors.textTertiary, size: 18),
                        const SizedBox(width: 12),
                        Text(name, style: AppTextStyles.bodyLarge.copyWith(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                        )),
                        const Spacer(),
                        if (selected)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                      ]),
                    ),
                  );
                }),
              ]),
            ),

            const SizedBox(height: 20),
            _SectionHeader('About'),
            GlassCard(
              child: Column(children: [
                _InfoTile(label: 'App Version', value: AppConstants.appVersion),
                _Divider(),
                _InfoTile(label: 'Stadium', value: AppConstants.stadiumName),
                _Divider(),
                _InfoTile(label: 'AI Engine', value: 'Gemini 1.5 Flash'),
                _Divider(),
                _InfoTile(label: 'Mode', value: AppConstants.isDemoMode ? 'Demo' : 'Live'),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppColors.border, height: 1);
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final bool value;
  final VoidCallback onToggle;
  final Color color;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.onToggle,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.bodyLarge),
          Text(sub, style: AppTextStyles.bodySmall),
        ])),
        Switch(
          value: value,
          onChanged: (_) => onToggle(),
          activeColor: color,
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? color.withOpacity(0.3) : AppColors.border),
        ),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Text(label, style: AppTextStyles.bodyLarge),
        const Spacer(),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
      ]),
    );
  }
}
