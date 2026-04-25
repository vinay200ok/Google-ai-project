import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../event/presentation/providers/event_provider.dart';
import '../../../stadium_intelligence/presentation/widgets/live_data_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final zonesAsync = ref.watch(zonesStreamProvider);
    final stats = ref.watch(stadiumStatsProvider);
    final unread = ref.watch(unreadCountProvider);
    final eventAsync = ref.watch(liveEventStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                  ),
                  child: const Icon(Icons.stadium_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.stadiumName, style: AppTextStyles.headlineSmall.copyWith(fontSize: 14)),
                    Text('${AppConstants.homeTeamShort} vs ${AppConstants.awayTeamShort} • IPL 2026',
                        style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
            actions: [
              const LiveDataBadge(label: 'LIVE', compact: true),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                    onPressed: () => context.push(RouteNames.notifications),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
                onPressed: () => context.push(RouteNames.profile),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hey, ${user?.name.split(' ').first ?? 'Fan'} 🏏', style: AppTextStyles.displayMedium)
                      .animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text('Welcome to ${AppConstants.stadiumCity} • Your AI stadium guide is active',
                      style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),

                  // Mini live score
                  eventAsync.when(
                    loading: () => const ShimmerCard(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (event) => _LiveScoreCard(event: event).animate().fadeIn(delay: 120.ms),
                  ),
                  const SizedBox(height: 16),

                  _StatsRow(stats: stats).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 20),
                  _AIInsightCard(userZone: user?.currentZone ?? 'zone_pavilion').animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),
                  Text('Quick Actions', style: AppTextStyles.headlineSmall).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 12),
                  _QuickActionsGrid().animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Zone Status', style: AppTextStyles.headlineSmall),
                      TextButton(
                        onPressed: () => context.push(RouteNames.map),
                        child: Text('View Map', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                  zonesAsync.when(
                    loading: () => const ShimmerList(count: 3),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (zones) => Column(
                      children: zones.take(5).map((z) => _ZoneCard(
                        name: z.name, icon: z.icon,
                        densityLevel: z.densityLevel,
                        densityPercent: z.densityPercent,
                        occ: z.currentOccupancy, cap: z.capacity,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveScoreCard extends StatelessWidget {
  final dynamic event;
  const _LiveScoreCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.event),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0D1F3C), Color(0xFF1A2436)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Text(event.homeLogo, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${event.homeTeamShort.isEmpty ? "RCB" : event.homeTeamShort}', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              Text(event.homeScore.display, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('🏏 LIVE', style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.w800)),
            ),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${event.awayTeamShort.isEmpty ? "GT" : event.awayTeamShort}', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              Text(event.awayScore.display, style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
            ]),
            const SizedBox(width: 8),
            Text(event.awayLogo, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsRow({required this.stats});
  @override
  Widget build(BuildContext context) {
    final pct = ((stats['occupancyPercent'] as double) * 100).toInt();
    final critical = stats['criticalZones'] as int;
    final clear = stats['clearZones'] as int;
    return Row(children: [
      Expanded(child: GlassCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Capacity', style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text('$pct%', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary)),
        Text('${stats['totalOccupancy']} fans', style: AppTextStyles.bodySmall),
      ]))),
      const SizedBox(width: 10),
      Expanded(child: GlassCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Critical', style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text('$critical', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.error)),
        Text('$clear clear', style: AppTextStyles.bodySmall),
      ]))),
      const SizedBox(width: 10),
      Expanded(child: GlassCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Match', style: AppTextStyles.caption),
        const SizedBox(height: 4),
        const Text('🏏', style: TextStyle(fontSize: 22)),
        Row(children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('Live', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
        ]),
      ]))),
    ]);
  }
}

class _AIInsightCard extends ConsumerWidget {
  final String userZone;
  const _AIInsightCard({required this.userZone});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(aiTipsProvider(userZone));
    return GlowCard(
      glowColor: AppColors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.purpleGradient),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text('AI Insights', style: AppTextStyles.caption.copyWith(color: Colors.white)),
              ]),
            ),
            const SizedBox(width: 8),
            Text('Powered by Gemini', style: AppTextStyles.caption),
          ]),
          const SizedBox(height: 14),
          tips.when(
            loading: () => Column(children: List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShimmerBox(width: double.infinity, height: 20),
            ))),
            error: (_, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🗺️ Head to P Stand — only 45% full right now.', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Text('⏱️ Dosa Corner queue is ~6 mins. Good time to grab food.', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Text('🏏 Innings break coming — washrooms will fill soon!', style: AppTextStyles.bodyMedium),
            ]),
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(t, style: AppTextStyles.bodyMedium),
              )).toList(),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.push(RouteNames.aiChat),
            child: Row(children: [
              Text('Ask AI Assistant', style: AppTextStyles.labelMedium.copyWith(color: AppColors.purple)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.purple),
            ]),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'AI Map', 'icon': Icons.map_outlined, 'route': RouteNames.map, 'color': AppColors.primary},
      {'label': 'Stadium AI', 'icon': Icons.insights_rounded, 'route': RouteNames.stadiumIntelligence, 'color': AppColors.secondary},
      {'label': 'Food', 'icon': Icons.restaurant_menu, 'route': RouteNames.food, 'color': AppColors.accent},
      {'label': 'AI Chat', 'icon': Icons.smart_toy_outlined, 'route': RouteNames.aiChat, 'color': AppColors.purple},
      {'label': 'Live Match', 'icon': Icons.sports_cricket, 'route': RouteNames.event, 'color': AppColors.accentOrange},
      {'label': 'Fan Zone', 'icon': Icons.forum_outlined, 'route': RouteNames.fanZone, 'color': AppColors.primaryLight},
    ];
    return GridView.count(
      crossAxisCount: 3, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1,
      children: actions.map((a) {
        final color = a['color'] as Color;
        return GestureDetector(
          onTap: () => context.push(a['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(a['icon'] as IconData, color: color, size: 26),
              const SizedBox(height: 8),
              Text(a['label'] as String, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String name, icon, densityLevel;
  final double densityPercent;
  final int occ, cap;
  const _ZoneCard({required this.name, required this.icon, required this.densityLevel, required this.densityPercent, required this.occ, required this.cap});

  @override
  Widget build(BuildContext context) {
    final color = switch (densityLevel) {
      'low' => AppColors.densityLow,
      'medium' => AppColors.densityMedium,
      'high' => AppColors.densityHigh,
      _ => AppColors.densityCritical,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: densityPercent, backgroundColor: AppColors.border, color: color, minHeight: 5),
          ),
          const SizedBox(height: 4),
          Text('$occ / $cap', style: AppTextStyles.bodySmall),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${(densityPercent * 100).toInt()}%', style: AppTextStyles.headlineSmall.copyWith(color: color)),
          const SizedBox(height: 4),
          StatusBadge.density(densityLevel),
        ]),
      ]),
    );
  }
}
