import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/gate_entity.dart';

class GateSuggestionCard extends StatelessWidget {
  final List<GateEntity> gates;
  final GateEntity? bestGate;

  const GateSuggestionCard({
    super.key,
    required this.gates,
    this.bestGate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.door_front_door_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Smart Gate Suggestion', style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Choose the least crowded gate for fastest entry',
                style: AppTextStyles.bodySmall),
          ),
          const SizedBox(height: 12),
          ...gates.map((gate) {
            final isBest = bestGate != null && gate.id == bestGate!.id;
            return _GateTile(gate: gate, isBest: isBest);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GateTile extends StatefulWidget {
  final GateEntity gate;
  final bool isBest;
  const _GateTile({required this.gate, required this.isBest});

  @override
  State<_GateTile> createState() => _GateTileState();
}

class _GateTileState extends State<_GateTile> with SingleTickerProviderStateMixin {
  late AnimationController _arrowCtrl;

  @override
  void initState() {
    super.initState();
    _arrowCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    if (widget.isBest) _arrowCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _GateTile old) {
    super.didUpdateWidget(old);
    if (widget.isBest && !_arrowCtrl.isAnimating) {
      _arrowCtrl.repeat(reverse: true);
    } else if (!widget.isBest) {
      _arrowCtrl.stop();
      _arrowCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    super.dispose();
  }

  Color _crowdColor(String level) => switch (level) {
    'low' => AppColors.densityLow,
    'medium' => AppColors.densityMedium,
    _ => AppColors.densityCritical,
  };

  @override
  Widget build(BuildContext context) {
    final gate = widget.gate;
    final color = _crowdColor(gate.crowdLevel);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isBest ? AppColors.secondary.withOpacity(0.08) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isBest ? AppColors.secondary.withOpacity(0.5) : AppColors.border,
          width: widget.isBest ? 1.5 : 1,
        ),
        boxShadow: widget.isBest
            ? [BoxShadow(color: AppColors.secondary.withOpacity(0.15), blurRadius: 12)]
            : [],
      ),
      child: Row(
        children: [
          // Direction arrow (animated for best gate)
          AnimatedBuilder(
            animation: _arrowCtrl,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(widget.isBest ? _arrowCtrl.value * 6 : 0, 0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.isBest ? AppColors.secondary : AppColors.textTertiary,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          // Gate info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(gate.name, style: AppTextStyles.headlineSmall.copyWith(fontSize: 13)),
                    ),
                    if (widget.isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                        ),
                        child: Text('✅ RECOMMENDED',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondary, fontWeight: FontWeight.w800, fontSize: 8)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Crowd bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: gate.crowd,
                          backgroundColor: AppColors.border,
                          color: color,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(gate.crowd * 100).toInt()}%',
                        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Time saved
          if (widget.isBest)
            Column(
              children: [
                Text('⏱️', style: const TextStyle(fontSize: 14)),
                Text('${gate.estimatedTimeSavedMins}m',
                    style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w800)),
                Text('saved', style: AppTextStyles.caption.copyWith(fontSize: 8)),
              ],
            ),
        ],
      ),
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
