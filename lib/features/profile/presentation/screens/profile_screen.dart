import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
        actions: [
          TextButton(
            onPressed: () => context.push(RouteNames.settings),
            child: Text('Settings', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24)],
                  ),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'F',
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                const SizedBox(height: 14),
                Text(user?.name ?? 'Stadium Fan', style: AppTextStyles.headlineLarge).animate().fadeIn(delay: 100.ms),
                Text(user?.email ?? '', style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 150.ms),
              ]),
            ),
            const SizedBox(height: 24),

            // Seat info
            GlassCard(
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_seat, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Seat', style: AppTextStyles.bodyMedium),
                  Text(user?.seatNumber ?? 'N/A', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Row N', style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary)),
                ),
              ]),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Current zone
            GlassCard(
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Current Zone', style: AppTextStyles.bodyMedium),
                  Text(
                    AppConstants.zoneNames[user?.currentZone] ?? 'North Stand',
                    style: AppTextStyles.headlineMedium.copyWith(color: AppColors.accent),
                  ),
                ]),
              ]),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 24),

            // Stats
            Text('Your Session', style: AppTextStyles.headlineSmall).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatCard(emoji: '🍔', label: 'Orders', value: '2').animate().fadeIn(delay: 320.ms)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(emoji: '📍', label: 'Zones Visited', value: '3').animate().fadeIn(delay: 340.ms)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(emoji: '🤖', label: 'AI Tips Used', value: '7').animate().fadeIn(delay: 360.ms)),
            ]),

            const SizedBox(height: 24),

            // Sign out
            GestureDetector(
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go(RouteNames.login);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.logout, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text('Sign Out', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.error)),
                ]),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  const _StatCard({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ]),
    );
  }
}
