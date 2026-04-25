import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/food_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../services/mock/mock_data_service.dart';

const _uuid = Uuid();

// Menu
final foodMenuProvider = Provider<List<FoodItemEntity>>((ref) {
  return MockDataService.getFoodMenu()
      .map((m) => FoodItemEntity.fromMap(m))
      .toList();
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredMenuProvider = Provider<List<FoodItemEntity>>((ref) {
  final menu = ref.watch(foodMenuProvider);
  final cat = ref.watch(selectedCategoryProvider);
  if (cat == 'All') return menu;
  return menu.where((item) => item.category == cat).toList();
});

final menuCategoriesProvider = Provider<List<String>>((ref) {
  final menu = ref.watch(foodMenuProvider);
  final cats = menu.map((i) => i.category).toSet().toList();
  return ['All', ...cats];
});

// Cart
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(FoodItemEntity item) {
    final idx = state.indexWhere((c) => c.item.id == item.id);
    if (idx >= 0) {
      state = [
        ...state.sublist(0, idx),
        state[idx].copyWith(quantity: state[idx].quantity + 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, CartItem(item: item, quantity: 1)];
    }
  }

  void removeItem(String itemId) {
    final idx = state.indexWhere((c) => c.item.id == itemId);
    if (idx < 0) return;
    if (state[idx].quantity > 1) {
      state = [
        ...state.sublist(0, idx),
        state[idx].copyWith(quantity: state[idx].quantity - 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = state.where((c) => c.item.id != itemId).toList();
    }
  }

  void clear() => state = [];

  double get totalAmount =>
      state.fold(0, (sum, c) => sum + c.totalPrice);

  int get totalItems => state.fold(0, (sum, c) => sum + c.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).totalAmount;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider.notifier).totalItems;
});

// Orders
class OrderNotifier extends StateNotifier<List<OrderEntity>> {
  OrderNotifier() : super([]);

  Future<OrderEntity> placeOrder({
    required List<CartItem> items,
    required double total,
    required String userId,
    required String zoneId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = OrderEntity(
      id: _uuid.v4(),
      userId: userId,
      items: items,
      totalAmount: total,
      status: 'confirmed',
      zoneId: zoneId,
      counterNumber: 'Counter ${(items.length % 5) + 1}',
      createdAt: DateTime.now(),
      estimatedReadyAt: DateTime.now().add(
        Duration(minutes: items.fold(0, (s, c) => s + c.item.prepMins)),
      ),
    );
    state = [order, ...state];
    _simulateOrderProgression(order.id);
    return order;
  }

  void _simulateOrderProgression(String orderId) async {
    final stages = ['preparing', 'ready'];
    for (final stage in stages) {
      await Future.delayed(const Duration(seconds: 8));
      state = state.map((o) {
        if (o.id == orderId) {
          return OrderEntity(
            id: o.id, userId: o.userId, items: o.items,
            totalAmount: o.totalAmount, status: stage,
            zoneId: o.zoneId, counterNumber: o.counterNumber,
            createdAt: o.createdAt, estimatedReadyAt: o.estimatedReadyAt,
          );
        }
        return o;
      }).toList();
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderEntity>>((ref) {
  return OrderNotifier();
});

final activeOrderProvider = Provider<OrderEntity?>((ref) {
  final orders = ref.watch(orderProvider);
  try {
    return orders.firstWhere((o) => o.isActive);
  } catch (_) {
    return null;
  }
});
