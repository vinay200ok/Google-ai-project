import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String seatNumber;
  final String currentZone;
  final bool notificationsEnabled;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.seatNumber = 'N/A',
    this.currentZone = 'zone_pavilion',
    this.notificationsEnabled = true,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? name,
    String? photoUrl,
    String? seatNumber,
    String? currentZone,
    bool? notificationsEnabled,
  }) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      seatNumber: seatNumber ?? this.seatNumber,
      currentZone: currentZone ?? this.currentZone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, email, photoUrl, seatNumber, currentZone, notificationsEnabled];
}
