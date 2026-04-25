import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/food_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final activeOrder = ref.watch(activeOrderProvider);

    if (activeOrder != null) {
      return _OrderTrackingView(order: activeOrder);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Your Cart', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: Text('Clear', style: AppTextStyles.labelMedium.copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: cart.length,
                    itemBuilder: (_, i) => _CartItemTile(item: cart[i])
                        .animate(delay: Duration(milliseconds: i * 50))
                        .fadeIn(),
                  ),
                ),
                _CheckoutBar(total: total, cart: cart),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final dynamic item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Text(item.item.emoji as String, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.item.name as String, style: AppTextStyles.headlineSmall),
          Text('\$${item.item.price.toStringAsFixed(2)} each', style: AppTextStyles.bodySmall),
        ])),
        Row(children: [
          _Btn(icon: Icons.remove, onTap: () => ref.read(cartProvider.notifier).removeItem(item.item.id as String)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${item.quantity}', style: AppTextStyles.headlineMedium)),
          _Btn(icon: Icons.add, onTap: () => ref.read(cartProvider.notifier).addItem(item.item), isAdd: true),
        ]),
        const SizedBox(width: 10),
        Text('\$${item.totalPrice.toStringAsFixed(2)}',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.accent)),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;
  const _Btn({required this.icon, required this.onTap, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: isAdd ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: isAdd ? Colors.white : AppColors.textPrimary),
      ),
    );
  }
}

class _CheckoutBar extends ConsumerWidget {
  final double total;
  final List<dynamic> cart;
  const _CheckoutBar({required this.total, required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOrdering = ref.watch(orderProvider).any((o) => o.isActive);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total', style: AppTextStyles.headlineMedium),
            Text('\$${total.toStringAsFixed(2)}',
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.accent)),
          ]),
          const SizedBox(height: 12),
          GradientButton(
            text: 'Place Order',
            colors: AppColors.fireGradient,
            isLoading: isOrdering,
            onTap: () async {
              final user = ref.read(authProvider).user;
              if (user == null) return;
              await ref.read(orderProvider.notifier).placeOrder(
                items: List.from(cart),
                total: total,
                userId: user.uid,
                zoneId: user.currentZone,
              );
              ref.read(cartProvider.notifier).clear();
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🛒', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text('Your cart is empty', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 8),
        Text('Browse the menu to add items', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Browse Menu'),
        ),
      ]),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  final dynamic order;
  const _OrderTrackingView({required this.order});

  @override
  Widget build(BuildContext context) {
    final stages = ['confirmed', 'preparing', 'ready'];
    final currentIdx = stages.indexOf(order.status as String);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order Tracking', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GlowCard(
              glowColor: AppColors.accent,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('🎫', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Order #${(order.id as String).substring(0, 8).toUpperCase()}',
                        style: AppTextStyles.headlineMedium),
                    Text(order.counterNumber as String, style: AppTextStyles.bodyMedium),
                  ]),
                  const Spacer(),
                  StatusBadge.orderStatus(order.status as String),
                ]),
                const SizedBox(height: 16),
                // Steps
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  ...stages.asMap().entries.map((e) {
                    final done = e.key <= currentIdx;
                    final active = e.key == currentIdx;
                    return Column(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? AppColors.accent : AppColors.surfaceVariant,
                          border: Border.all(color: active ? AppColors.accent : AppColors.border, width: active ? 3 : 1),
                        ),
                        child: Icon(
                          switch (e.value) {
                            'confirmed' => Icons.check_circle_outline,
                            'preparing' => Icons.local_fire_department_outlined,
                            _ => Icons.done_all,
                          },
                          color: done ? Colors.white : AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(e.value.capitalize(),
                          style: AppTextStyles.caption.copyWith(
                            color: done ? AppColors.accent : AppColors.textTertiary,
                          )),
                    ]);
                  }),
                ]),
              ]),
            ).animate().fadeIn(),
            const SizedBox(height: 24),
            Text('Estimated ready time', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              order.estimatedReadyAt != null
                  ? '${(order.estimatedReadyAt as DateTime).difference(DateTime.now()).inMinutes + 1} minutes'
                  : 'Calculating...',
              style: AppTextStyles.displayMedium.copyWith(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
