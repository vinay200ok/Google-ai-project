import 'package:equatable/equatable.dart';

class StallEntity extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final int currentWait;    // minutes
  final int predictedWait;  // minutes (future prediction)
  final DateTime updatedAt;

  const StallEntity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.currentWait,
    required this.predictedWait,
    required this.updatedAt,
  });

  factory StallEntity.fromMap(Map<String, dynamic> map) {
    return StallEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String? ?? '🍽️',
      currentWait: map['current_wait'] as int? ?? 0,
      predictedWait: map['predicted_wait'] as int? ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// If current wait is less than predicted, user should GO NOW
  bool get shouldGoNow => currentWait < predictedWait;

  /// Time saved if user goes now vs waits
  int get timeDifference => (predictedWait - currentWait).abs();

  String get recommendation => shouldGoNow ? 'GO NOW' : 'WAIT';

  @override
  List<Object?> get props => [id, currentWait, predictedWait];
}
