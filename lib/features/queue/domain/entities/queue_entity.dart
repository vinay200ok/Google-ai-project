import 'package:equatable/equatable.dart';

class QueueEntity extends Equatable {
  final String id;
  final String zoneId;
  final String type;
  final String name;
  final int congestionLevel;
  final int currentLength;
  final int estimatedWaitMins;
  final int aiPredictedWaitMins;
  final DateTime updatedAt;

  const QueueEntity({
    required this.id,
    required this.zoneId,
    required this.type,
    required this.name,
    required this.congestionLevel,
    required this.currentLength,
    required this.estimatedWaitMins,
    required this.aiPredictedWaitMins,
    required this.updatedAt,
  });

  factory QueueEntity.fromMap(Map<String, dynamic> map) {
    return QueueEntity(
      id: map['id'] as String,
      zoneId: map['zoneId'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      congestionLevel: map['congestionLevel'] as int,
      currentLength: map['currentLength'] as int,
      estimatedWaitMins: map['estimatedWaitMins'] as int,
      aiPredictedWaitMins: map['aiPredictedWaitMins'] as int,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get typeIcon => switch (type) {
        'food' => '🍔',
        'restroom' => '🚻',
        'merchandise' => '👕',
        'entry' => '🎫',
        _ => '📍',
      };

  bool get isAiSaving => aiPredictedWaitMins < estimatedWaitMins;

  @override
  List<Object?> get props => [id, currentLength, estimatedWaitMins];
}
