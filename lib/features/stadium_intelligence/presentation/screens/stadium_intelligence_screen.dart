import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../event/presentation/providers/event_provider.dart';
import '../providers/stadium_intelligence_provider.dart';
import '../widgets/live_data_badge.dart';
import '../widgets/cricket_heatmap.dart';
import '../widgets/go_wait_card.dart';
import '../widgets/gate_suggestion_card.dart';

class StadiumIntelligenceScreen extends ConsumerWidget {
  const StadiumIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesStreamProvider);
    final gatesAsync = ref.watch(gatesStreamProvider);
    final stallsAsync = ref.watch(stallsStreamProvider);
    final bestGateAsync = ref.watch(bestGateProvider);
    final selectedIdx = ref.watch(selectedStallIndexProvider);
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
                  width: 34, height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                  ),
                  child: const Icon(Icons.insights_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Stadium Intelligence', style: AppTextStyles.headlineMedium),
              ],
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: LiveDataBadge(label: 'LIVE', compact: true),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini scoreboard
                  eventAsync.when(
                    loading: () => const ShimmerCard(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (event) => _MiniScoreboard(event: event).animate().fadeIn(),
                  ),
                  const SizedBox(height: 16),

                  // Section 1: Heatmap
                  Text('🗺️  Crowd Heatmap', style: AppTextStyles.headlineSmall)
                      .animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 4),
                  Text('Real-time crowd density across stadium zones',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 320,
                    child: zonesAsync.when(
                      loading: () => const ShimmerCard(),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (zones) => CricketHeatmap(zones: zones)
                          .animate().fadeIn(delay: 150.ms),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 2: GO NOW / WAIT
                  Text('⚡  Go Now or Wait?', style: AppTextStyles.headlineSmall)
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  Text('AI-powered queue prediction for food stalls',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 10),
                  stallsAsync.when(
                    loading: () => const ShimmerCard(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (stalls) {
                      if (stalls.isEmpty) return const Text('No stalls available');
                      final idx = selectedIdx.clamp(0, stalls.length - 1);
                      return GoWaitCard(
                        stall: stalls[idx],
                        allStalls: stalls,
                        selectedIndex: idx,
                        onStallChanged: (i) =>
                            ref.read(selectedStallIndexProvider.notifier).state = i,
                      ).animate().fadeIn(delay: 250.ms);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section 3: Gate Suggestion
                  Text('🚪  Smart Gate Entry', style: AppTextStyles.headlineSmall)
                      .animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 4),
                  Text('Find the fastest gate to enter or exit',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 10),
                  gatesAsync.when(
                    loading: () => const ShimmerCard(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (gates) {
                      final best = bestGateAsync.valueOrNull;
                      return GateSuggestionCard(gates: gates, bestGate: best)
                          .animate().fadeIn(delay: 350.ms);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Updating indicator
                  Center(
                    child: _UpdatingIndicator().animate().fadeIn(delay: 400.ms),
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

class _MiniScoreboard extends StatelessWidget {
  final dynamic event;
  const _MiniScoreboard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1F3C), Color(0xFF1A2436)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Home team
          Text(event.homeLogo, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.homeTeamShort.isEmpty ? 'RCB' : event.homeTeamShort,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              Text(event.homeScore.display, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
          const Spacer(),
          // VS
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(event.isLive ? 'LIVE' : event.status,
                    style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.w800, fontSize: 8)),
              ),
              const SizedBox(height: 2),
              Text('vs', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
            ],
          ),
          const Spacer(),
          // Away team
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(event.awayTeamShort.isEmpty ? 'GT' : event.awayTeamShort,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              Text(event.awayScore.display, style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
            ],
          ),
          const SizedBox(width: 8),
          Text(event.awayLogo, style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

class _UpdatingIndicator extends StatefulWidget {
  @override
  State<_UpdatingIndicator> createState() => _UpdatingIndicatorState();
}

class _UpdatingIndicatorState extends State<_UpdatingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Opacity(
          opacity: 0.4 + (_ctrl.value * 0.6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 6),
              Text('Updating live data…',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;
  const AnimatedBuilder({super.key, required Animation<double> animation, required this.builder, this.child})
      : super(listenable: animation);
  @override
  Widget build(BuildContext context) => builder(context, child);
}
