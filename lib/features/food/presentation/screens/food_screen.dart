import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/food_provider.dart';

class FoodScreen extends ConsumerWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(filteredMenuProvider);
    final categories = ref.watch(menuCategoriesProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Food & Drinks', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
                onPressed: () => context.push(RouteNames.cart),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: Center(child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: categories.map((cat) {
                final active = cat == selectedCat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? AppColors.accent : AppColors.border),
                      ),
                      child: Text(cat, style: AppTextStyles.labelMedium.copyWith(
                          color: active ? Colors.white : AppColors.textSecondary)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: menu.length,
              itemBuilder: (_, i) => _FoodCard(item: menu[i])
                  .animate(delay: Duration(milliseconds: i * 40))
                  .fadeIn()
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
            ),
          ),
        ],
      ),
      floatingActionButton: cartCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.cart),
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text('View Cart ($cartCount)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }
}

class _FoodCard extends ConsumerWidget {
  final dynamic item;
  const _FoodCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final inCart = cart.where((c) => c.item.id == item.id).fold(0, (s, c) => s + c.quantity);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji area
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(child: Text(item.emoji as String, style: const TextStyle(fontSize: 44))),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name as String, style: AppTextStyles.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.description as String, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.accent, size: 12),
                  const SizedBox(width: 2),
                  Text(item.rating.toString(), style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
                  const SizedBox(width: 6),
                  const Icon(Icons.timer_outlined, color: AppColors.textTertiary, size: 12),
                  const SizedBox(width: 2),
                  Text('${item.prepMins}m', style: AppTextStyles.caption),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$${item.price.toStringAsFixed(2)}',
                      style: AppTextStyles.headlineSmall.copyWith(color: AppColors.accent)),
                  inCart > 0
                      ? Row(children: [
                          _CountBtn(icon: Icons.remove, onTap: () => ref.read(cartProvider.notifier).removeItem(item.id as String)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('$inCart', style: AppTextStyles.labelLarge),
                          ),
                          _CountBtn(icon: Icons.add, onTap: () => ref.read(cartProvider.notifier).addItem(item), isAdd: true),
                        ])
                      : GestureDetector(
                          onTap: () => ref.read(cartProvider.notifier).addItem(item),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;
  const _CountBtn({required this.icon, required this.onTap, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isAdd ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16, color: isAdd ? Colors.white : AppColors.textPrimary),
      ),
    );
  }
}
