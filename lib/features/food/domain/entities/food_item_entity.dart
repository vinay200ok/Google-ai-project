import 'package:equatable/equatable.dart';

class FoodItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String category;
  final String emoji;
  final String description;
  final double rating;
  final int prepMins;

  const FoodItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.emoji,
    required this.description,
    required this.rating,
    required this.prepMins,
  });

  factory FoodItemEntity.fromMap(Map<String, dynamic> map) {
    return FoodItemEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      emoji: map['emoji'] as String,
      description: map['desc'] as String,
      rating: (map['rating'] as num).toDouble(),
      prepMins: map['prepMins'] as int,
    );
  }

  @override
  List<Object?> get props => [id, price];
}

class CartItem extends Equatable {
  final FoodItemEntity item;
  final int quantity;

  const CartItem({required this.item, required this.quantity});

  double get totalPrice => item.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(item: item, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [item.id, quantity];
}
