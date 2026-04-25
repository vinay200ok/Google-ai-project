import 'package:equatable/equatable.dart';

class GateEntity extends Equatable {
  final String id;
  final String name;
  final double crowd; // 0.0 - 1.0
  final String direction;
  final int estimatedTimeSavedMins;
  final DateTime updatedAt;

  const GateEntity({
    required this.id,
    required this.name,
    required this.crowd,
    required this.direction,
    required this.estimatedTimeSavedMins,
    required this.updatedAt,
  });

  factory GateEntity.fromMap(Map<String, dynamic> map) {
    return GateEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      crowd: (map['crowd'] as num).toDouble(),
      direction: map['direction'] as String? ?? 'North',
      estimatedTimeSavedMins: map['estimatedTimeSavedMins'] as int? ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get crowdLevel {
    if (crowd < 0.3) return 'low';
    if (crowd < 0.7) return 'medium';
    return 'high';
  }

  bool get isRecommended => crowd < 0.4;

  @override
  List<Object?> get props => [id, crowd];
}
