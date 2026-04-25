import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../providers/map_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/domain/entities/zone_entity.dart';
import '../../../stadium_intelligence/presentation/widgets/live_data_badge.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _destCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(zonesStreamProvider).whenData((zones) {
        ref.read(mapProvider.notifier).updateZones(zones);
      });
    });
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final zonesAsync = ref.watch(zonesStreamProvider);

    ref.listen(zonesStreamProvider, (_, next) {
      next.whenData((z) => ref.read(mapProvider.notifier).updateZones(z));
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('AI Stadium Map', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LiveDataBadge(label: 'LIVE', compact: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: zonesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (zones) => _CricketStadiumHeatmap(
                zones: zones,
                selectedZoneId: mapState.selectedZoneId,
                onZoneTap: (id) => ref.read(mapProvider.notifier).selectZone(id),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: AppColors.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Navigation', style: AppTextStyles.headlineMedium)
                        .animate().fadeIn(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _destCtrl,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Where do you want to go?',
                              prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GradientButton(
                          text: 'Navigate',
                          width: 100,
                          height: 48,
                          isLoading: mapState.isLoadingNav,
                          onTap: () {
                            final dest = _destCtrl.text.trim();
                            if (dest.isNotEmpty) {
                              ref.read(mapProvider.notifier).getNavigation(dest);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (mapState.navigationAdvice != null) ...[
                      GlowCard(
                        glowColor: AppColors.secondary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.assistant_direction, color: AppColors.secondary, size: 18),
                              const SizedBox(width: 8),
                              Text('AI Route', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.secondary)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => ref.read(mapProvider.notifier).clearNavigation(),
                                child: const Icon(Icons.close, color: AppColors.textTertiary, size: 18),
                              ),
                            ]),
                            const SizedBox(height: 10),
                            Text(mapState.navigationAdvice!, style: AppTextStyles.aiText),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 12),
                    ],
                    Text('Zone Legend', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _LegendItem(color: AppColors.densityLow, label: 'Low'),
                      _LegendItem(color: AppColors.densityMedium, label: 'Medium'),
                      _LegendItem(color: AppColors.densityHigh, label: 'High'),
                      _LegendItem(color: AppColors.densityCritical, label: 'Critical'),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CricketStadiumHeatmap extends StatelessWidget {
  final List<ZoneEntity> zones;
  final String selectedZoneId;
  final ValueChanged<String> onZoneTap;

  const _CricketStadiumHeatmap({
    required this.zones,
    required this.selectedZoneId,
    required this.onZoneTap,
  });

  Color _zoneColor(String level, bool selected) {
    final base = switch (level) {
      'low' => AppColors.densityLow,
      'medium' => AppColors.densityMedium,
      'high' => AppColors.densityHigh,
      _ => AppColors.densityCritical,
    };
    return selected ? base : base.withOpacity(0.6);
  }

  @override
  Widget build(BuildContext context) {
    final zoneMap = {for (final z in zones) z.id: z};

    final positions = <Map<String, dynamic>>[
      {'id': 'zone_pavilion', 'label': 'Pavilion', 'x': 0.30, 'y': 0.02, 'w': 0.40, 'h': 0.20},
      {'id': 'zone_bbmp', 'label': 'BBMP', 'x': 0.30, 'y': 0.78, 'w': 0.40, 'h': 0.20},
      {'id': 'zone_p_stand', 'label': 'P Stand', 'x': 0.74, 'y': 0.28, 'w': 0.24, 'h': 0.44},
      {'id': 'zone_corporate', 'label': 'Corporate', 'x': 0.02, 'y': 0.28, 'w': 0.24, 'h': 0.44},
      {'id': 'zone_food_court', 'label': 'Food Court', 'x': 0.35, 'y': 0.55, 'w': 0.30, 'h': 0.16},
      {'id': 'zone_washroom', 'label': 'WC', 'x': 0.02, 'y': 0.76, 'w': 0.20, 'h': 0.12},
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return Container(
        color: AppColors.surface,
        child: Stack(
          children: [
            // Cricket pitch (oval)
            Positioned(
              left: w * 0.32, top: h * 0.25, width: w * 0.36, height: h * 0.45,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A472A),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(child: Text('🏏', style: TextStyle(fontSize: 24))),
              ),
            ),
            // Zones
            ...positions.map((pos) {
              final id = pos['id'] as String;
              final zone = zoneMap[id];
              final level = zone?.densityLevel ?? 'low';
              final selected = id == selectedZoneId;
              final color = _zoneColor(level, selected);

              return Positioned(
                left: w * (pos['x'] as double),
                top: h * (pos['y'] as double),
                width: w * (pos['w'] as double),
                height: h * (pos['h'] as double),
                child: GestureDetector(
                  onTap: () => onZoneTap(id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: color.withOpacity(selected ? 0.75 : 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? Colors.white : color,
                        width: selected ? 2.5 : 1,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12)]
                          : [],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(pos['label'] as String,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
                          if (zone != null) ...[
                            const SizedBox(height: 2),
                            Text('${(zone.densityPercent * 100).toInt()}%',
                                style: const TextStyle(color: Colors.white, fontSize: 9)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.caption),
    ]);
  }
}
