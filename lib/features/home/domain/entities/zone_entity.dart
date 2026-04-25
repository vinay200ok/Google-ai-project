import 'package:equatable/equatable.dart';

class ZoneEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int capacity;
  final int currentOccupancy;
  final double densityPercent;
  final String densityLevel;
  final DateTime updatedAt;

  const ZoneEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.capacity,
    required this.currentOccupancy,
    required this.densityPercent,
    required this.densityLevel,
    required this.updatedAt,
  });

  factory ZoneEntity.fromMap(Map<String, dynamic> map) {
    return ZoneEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String? ?? '🏟️',
      capacity: map['capacity'] as int,
      currentOccupancy: map['currentOccupancy'] as int,
      densityPercent: (map['densityPercent'] as num).toDouble(),
      densityLevel: map['densityLevel'] as String,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool get isCritical => densityLevel == 'critical';
  bool get isHigh => densityLevel == 'high' || densityLevel == 'critical';
  int get availableSpots => capacity - currentOccupancy;

  @override
  List<Object?> get props => [id, currentOccupancy, densityLevel];
}
