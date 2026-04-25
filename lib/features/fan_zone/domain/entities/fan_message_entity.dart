import 'package:equatable/equatable.dart';

class FanMessageEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String zoneId;
  final DateTime createdAt;

  const FanMessageEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.zoneId,
    required this.createdAt,
  });

  factory FanMessageEntity.fromMap(Map<String, dynamic> map) {
    return FanMessageEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      text: map['text'] as String,
      zoneId: map['zoneId'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id];
}
