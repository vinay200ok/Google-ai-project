import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/zone_entity.dart';
import 'live_data_badge.dart';

/// Cricket stadium oval heatmap with pulsing red zones and LIVE badge.
class CricketHeatmap extends StatelessWidget {
  final List<ZoneEntity> zones;
  final String? selectedZoneId;
  final ValueChanged<String>? onZoneTap;

  const CricketHeatmap({
    super.key,
    required this.zones,
    this.selectedZoneId,
    this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    final zoneMap = {for (final z in zones) z.id: z};

    // Cricket stadium positions (oval layout)
    final positions = <Map<String, dynamic>>[
      {'id': 'zone_pavilion', 'label': 'Pavilion\nEnd', 'x': 0.30, 'y': 0.02, 'w': 0.40, 'h': 0.18},
      {'id': 'zone_bbmp', 'label': 'BBMP\nStand', 'x': 0.30, 'y': 0.80, 'w': 0.40, 'h': 0.18},
      {'id': 'zone_p_stand', 'label': 'P\nStand', 'x': 0.72, 'y': 0.25, 'w': 0.26, 'h': 0.50},
      {'id': 'zone_corporate', 'label': 'Corporate\nBox', 'x': 0.02, 'y': 0.25, 'w': 0.24, 'h': 0.50},
      {'id': 'zone_food_court', 'label': 'Food\nCourt', 'x': 0.35, 'y': 0.58, 'w': 0.30, 'h': 0.15},
      {'id': 'zone_washroom', 'label': 'Wash\nRoom', 'x': 0.02, 'y': 0.78, 'w': 0.22, 'h': 0.12},
      {'id': 'zone_parking', 'label': 'Parking', 'x': 0.76, 'y': 0.78, 'w': 0.22, 'h': 0.12},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with LIVE badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.map_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Stadium Heatmap', style: AppTextStyles.headlineSmall),
                const Spacer(),
                const LiveDataBadge(label: 'LIVE', compact: true),
              ],
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.densityLow, label: 'Low'),
                const SizedBox(width: 14),
                _LegendDot(color: AppColors.densityMedium, label: 'Medium'),
                const SizedBox(width: 14),
                _LegendDot(color: AppColors.densityHigh, label: 'High'),
                const SizedBox(width: 14),
                _LegendDot(color: AppColors.densityCritical, label: 'Critical'),
              ],
            ),
          ),
          // Heatmap
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    // Cricket pitch in center
                    Positioned(
                      left: w * 0.32,
                      top: h * 0.25,
                      width: w * 0.36,
                      height: h * 0.45,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A472A), Color(0xFF2D5A3F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(color: Colors.white24, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A472A).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🏏', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              'PITCH',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white54,
                                fontSize: 8,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Zone overlays
                    ...positions.map((pos) {
                      final id = pos['id'] as String;
                      final zone = zoneMap[id];
                      final level = zone?.densityLevel ?? 'low';
                      final selected = id == selectedZoneId;
                      final pct = zone?.densityPercent ?? 0.0;
                      return _HeatmapZone(
                        x: w * (pos['x'] as double),
                        y: h * (pos['y'] as double),
                        width: w * (pos['w'] as double),
                        height: h * (pos['h'] as double),
                        label: pos['label'] as String,
                        densityLevel: level,
                        densityPercent: pct,
                        isSelected: selected,
                        onTap: () => onZoneTap?.call(id),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HeatmapZone extends StatefulWidget {
  final double x, y, width, height;
  final String label, densityLevel;
  final double densityPercent;
  final bool isSelected;
  final VoidCallback? onTap;

  const _HeatmapZone({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
    required this.densityLevel,
    required this.densityPercent,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<_HeatmapZone> createState() => _HeatmapZoneState();
}

class _HeatmapZoneState extends State<_HeatmapZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updatePulse();
  }

  @override
  void didUpdateWidget(covariant _HeatmapZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    final isHigh = widget.densityLevel == 'high' || widget.densityLevel == 'critical';
    if (isHigh) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _zoneColor(String level) {
    return switch (level) {
      'low' => AppColors.densityLow,
      'medium' => AppColors.densityMedium,
      'high' => AppColors.densityHigh,
      _ => AppColors.densityCritical,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _zoneColor(widget.densityLevel);
    final isHigh = widget.densityLevel == 'high' || widget.densityLevel == 'critical';

    return Positioned(
      left: widget.x,
      top: widget.y,
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final opacity = isHigh ? _pulseAnimation.value : 0.55;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: color.withOpacity(widget.isSelected ? 0.8 : opacity),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isSelected ? Colors.white : color.withOpacity(0.7),
                  width: widget.isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected || isHigh)
                    BoxShadow(
                      color: color.withOpacity(isHigh ? _pulseAnimation.value * 0.5 : 0.3),
                      blurRadius: isHigh ? 16 : 10,
                      spreadRadius: isHigh ? 2 : 0,
                    ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(widget.densityPercent * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// AnimatedBuilder helper
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
      ],
    );
  }
}
