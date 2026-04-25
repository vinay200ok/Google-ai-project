import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../providers/queue_provider.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queuesAsync = ref.watch(filteredQueuesProvider);
    final filter = ref.watch(queueFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Live Queues', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['all', 'food', 'restroom', 'merchandise', 'entry'].map((f) {
                final active = filter == f;
                final label = f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref.read(queueFilterProvider.notifier).state = f,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: active ? Colors.white : AppColors.textSecondary,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // AI tip banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GlowCard(
              glowColor: AppColors.secondary,
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Tip: West Wing restrooms have the shortest wait right now!',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary),
                  ),
                ),
              ]),
            ).animate().fadeIn(),
          ),

          const SizedBox(height: 8),

          // Queue list
          Expanded(
            child: queuesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerList(count: 5),
              ),
              error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
              data: (queues) => queues.isEmpty
                  ? Center(child: Text('No queues found', style: AppTextStyles.bodyMedium))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: queues.length,
                      itemBuilder: (_, i) => _QueueCard(queue: queues[i])
                          .animate(delay: Duration(milliseconds: i * 60))
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final dynamic queue;
  const _QueueCard({required this.queue});

  @override
  Widget build(BuildContext context) {
    final aiSaving = queue.isAiSaving as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(queue.typeIcon as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(queue.name as String, style: AppTextStyles.headlineSmall),
              Text(queue.zoneId.toString().replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' '),
                  style: AppTextStyles.bodySmall),
            ])),
            _WaitIndicator(mins: queue.estimatedWaitMins as int),
          ]),
          const SizedBox(height: 12),
          // Progress bar showing congestion
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (queue.congestionLevel as int) / 3.0,
              backgroundColor: AppColors.border,
              color: switch (queue.congestionLevel as int) {
                1 => AppColors.densityLow,
                2 => AppColors.densityMedium,
                _ => AppColors.densityHigh,
              },
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            // People count
            const Icon(Icons.people_outline, color: AppColors.textTertiary, size: 14),
            const SizedBox(width: 4),
            Text('${queue.currentLength} people', style: AppTextStyles.bodySmall),
            const SizedBox(width: 12),
            // AI prediction
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: aiSaving ? AppColors.secondary.withOpacity(0.1) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: aiSaving ? AppColors.secondary.withOpacity(0.4) : AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.auto_awesome, size: 10,
                    color: aiSaving ? AppColors.secondary : AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'AI: ${queue.aiPredictedWaitMins} min',
                  style: AppTextStyles.caption.copyWith(
                    color: aiSaving ? AppColors.secondary : AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (aiSaving) ...[
                  const SizedBox(width: 4),
                  Text('(saves ${queue.estimatedWaitMins - queue.aiPredictedWaitMins}m)',
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
                ],
              ]),
            ),
          ]),
        ],
      ),
    );
  }
}

class _WaitIndicator extends StatelessWidget {
  final int mins;
  const _WaitIndicator({required this.mins});

  @override
  Widget build(BuildContext context) {
    final color = mins < 5 ? AppColors.success : mins < 15 ? AppColors.warning : AppColors.error;
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text('$mins', style: AppTextStyles.displayMedium.copyWith(color: color, fontSize: 28)),
      Text('min wait', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}
