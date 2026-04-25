import 'package:equatable/equatable.dart';
import 'food_item_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final String zoneId;
  final String counterNumber;
  final DateTime createdAt;
  final DateTime? estimatedReadyAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.zoneId,
    required this.counterNumber,
    required this.createdAt,
    this.estimatedReadyAt,
  });

  bool get isActive =>
      status == 'pending' || status == 'confirmed' || status == 'preparing';

  @override
  List<Object?> get props => [id, status];
}
