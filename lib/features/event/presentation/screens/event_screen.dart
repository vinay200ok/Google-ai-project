import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/event_entity.dart';
import '../../../stadium_intelligence/presentation/widgets/live_data_badge.dart';

class EventScreen extends ConsumerWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(liveEventStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Live Match', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LiveDataBadge(label: 'LIVE', compact: true),
          ),
        ],
      ),
      body: eventAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: ShimmerList(count: 4)),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
        data: (event) => _EventContent(event: event),
      ),
    );
  }
}

class _EventContent extends ConsumerWidget {
  final EventEntity event;
  const _EventContent({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSummaryAsync = ref.watch(eventAiSummaryProvider(event));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CricketScoreboard(event: event).animate().fadeIn(),
          const SizedBox(height: 16),

          // AI Summary
          GlowCard(
            glowColor: AppColors.purple,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    Text('AI Match Analysis', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              aiSummaryAsync.when(
                loading: () => Column(children: [
                  ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 200, height: 14),
                ]),
                error: (_, __) => Text(event.aiSummary, style: AppTextStyles.aiText),
                data: (summary) => Text(summary, style: AppTextStyles.aiText),
              ),
            ]),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Match stats
          Row(children: [
            Expanded(child: _StatCard(label: 'Attendance', value: _formatNumber(event.attendance), icon: '👥')),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Run Rate', value: event.runRate.toStringAsFixed(2), icon: '📊')),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              label: 'Req. RR',
              value: event.isSecondInnings ? event.requiredRunRate.toStringAsFixed(2) : '—',
              icon: '🎯',
            )),
          ]).animate().fadeIn(delay: 150.ms),

          if (event.isSecondInnings) ...[
            const SizedBox(height: 12),
            _TargetCard(event: event).animate().fadeIn(delay: 180.ms),
          ],

          const SizedBox(height: 20),
          Text('Ball-by-ball Highlights', style: AppTextStyles.headlineSmall)
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),

          ...event.highlights.asMap().entries.map((e) => _HighlightTile(text: e.value)
              .animate(delay: Duration(milliseconds: 250 + e.key * 80))
              .fadeIn()
              .slideX(begin: -0.1, end: 0)),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }
}

class _CricketScoreboard extends StatelessWidget {
  final EventEntity event;
  const _CricketScoreboard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1F3C), Color(0xFF1A2436)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text(event.name, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        Text(event.venue, style: AppTextStyles.caption),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // Home (RCB)
          Expanded(child: Column(children: [
            Text(event.homeLogo, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(event.homeTeamShort.isEmpty ? event.homeTeam : event.homeTeamShort,
                style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(event.homeScore.display,
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary)),
          ])),
          // VS
          Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                event.isLive ? 'LIVE' : event.status,
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 8),
            Text('vs', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 4),
            if (event.battingTeam.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('🏏 ${event.battingTeam} batting',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontSize: 8)),
              ),
          ]),
          // Away (GT)
          Expanded(child: Column(children: [
            Text(event.awayLogo, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(event.awayTeamShort.isEmpty ? event.awayTeam : event.awayTeamShort,
                style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(event.awayScore.display,
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.accent)),
          ])),
        ]),
      ]),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final EventEntity event;
  const _TargetCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(children: [
            Text('Target', style: AppTextStyles.caption),
            Text('${event.target}', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
          ]),
          Container(width: 1, height: 30, color: AppColors.border),
          Column(children: [
            Text('Need', style: AppTextStyles.caption),
            Text('${event.runsNeeded}', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.accent)),
          ]),
          Container(width: 1, height: 30, color: AppColors.border),
          Column(children: [
            Text('Balls', style: AppTextStyles.caption),
            Text('${event.ballsRemaining}', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.accentOrange)),
          ]),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary), textAlign: TextAlign.center),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ]),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final String text;
  const _HighlightTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: AppTextStyles.bodyMedium),
    );
  }
}
