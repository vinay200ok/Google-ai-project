import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.dot = true,
  });

  factory StatusBadge.density(String level) {
    final color = switch (level.toLowerCase()) {
      'low' => AppColors.densityLow,
      'medium' => AppColors.densityMedium,
      'high' => AppColors.densityHigh,
      'critical' => AppColors.densityCritical,
      _ => AppColors.textTertiary,
    };
    return StatusBadge(label: level.toUpperCase(), color: color);
  }

  factory StatusBadge.orderStatus(String status) {
    final color = switch (status.toLowerCase()) {
      'pending' => AppColors.warning,
      'confirmed' => AppColors.info,
      'preparing' => AppColors.accent,
      'ready' => AppColors.secondary,
      'delivered' => AppColors.success,
      _ => AppColors.textTertiary,
    };
    return StatusBadge(label: status.toUpperCase(), color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
