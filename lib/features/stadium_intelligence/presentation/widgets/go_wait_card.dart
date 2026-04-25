import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stall_entity.dart';

class GoWaitCard extends StatefulWidget {
  final StallEntity stall;
  final List<StallEntity> allStalls;
  final int selectedIndex;
  final ValueChanged<int> onStallChanged;

  const GoWaitCard({
    super.key,
    required this.stall,
    required this.allStalls,
    required this.selectedIndex,
    required this.onStallChanged,
  });

  @override
  State<GoWaitCard> createState() => _GoWaitCardState();
}

class _GoWaitCardState extends State<GoWaitCard> {
  Timer? _countdownTimer;
  int _countdownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant GoWaitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stall.id != widget.stall.id ||
        oldWidget.stall.currentWait != widget.stall.currentWait) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownSeconds = widget.stall.currentWait * 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final stall = widget.stall;
    final goNow = stall.shouldGoNow;
    final gradientColors = goNow
        ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
        : [const Color(0xFFF59E0B), const Color(0xFFF97316)];
    final accentColor = goNow ? AppColors.secondary : AppColors.accent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.card,
        border: Border.all(color: accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Text('Smart Decision', style: AppTextStyles.headlineSmall),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: widget.selectedIndex,
                      isDense: true,
                      dropdownColor: AppColors.card,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 16),
                      items: widget.allStalls.asMap().entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.value.emoji} ${e.value.name}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (i) { if (i != null) widget.onStallChanged(i); },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Big CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(goNow ? Icons.directions_run : Icons.hourglass_top, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(goNow ? 'GO NOW' : 'WAIT', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    Text(
                      goNow ? 'FASTEST OPTION — Save ${stall.timeDifference} min!' : 'Wait ${stall.timeDifference} min for shorter queue',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Comparison bars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              _CompBar(label: 'NOW', value: stall.currentWait, color: goNow ? AppColors.secondary : AppColors.error, highlight: goNow),
              const SizedBox(height: 8),
              _CompBar(label: 'LATER', value: stall.predictedWait, color: goNow ? AppColors.error : AppColors.secondary, highlight: !goNow),
            ]),
          ),
          const SizedBox(height: 14),
          // Countdown
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_outlined, color: accentColor, size: 16),
                const SizedBox(width: 6),
                Text('Est. wait: ${_formatTime(_countdownSeconds)}',
                    style: AppTextStyles.labelLarge.copyWith(color: accentColor)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _CompBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool highlight;
  const _CompBar({required this.label, required this.value, required this.color, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final frac = (value / 30).clamp(0.0, 1.0);
    return Row(children: [
      SizedBox(width: 44, child: Text(label, style: AppTextStyles.caption.copyWith(color: highlight ? color : AppColors.textTertiary, fontWeight: FontWeight.w800))),
      Expanded(
        child: Stack(children: [
          Container(height: 14, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(7))),
          FractionallySizedBox(
            widthFactor: frac,
            child: Container(height: 14, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(7),
              boxShadow: highlight ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)] : [],
            )),
          ),
        ]),
      ),
      const SizedBox(width: 8),
      SizedBox(width: 44, child: Text('$value min', style: AppTextStyles.caption.copyWith(color: highlight ? color : AppColors.textSecondary, fontWeight: FontWeight.w700))),
    ]);
  }
}
