import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/notification_provider.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.background,
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationProvider.notifier).markAllRead(),
            child: Text('Mark all read', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🔔', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('No notifications', style: AppTextStyles.headlineMedium),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: notifications.length,
              itemBuilder: (_, i) => _NotificationTile(
                notification: notifications[i],
                onTap: () => ref.read(notificationProvider.notifier).markRead(notifications[i].id),
              ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.05, end: 0),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  Color get _typeColor => switch (notification.type) {
        'crowd_alert' => AppColors.error,
        'order_update' => AppColors.secondary,
        'ai_tip' => AppColors.purple,
        'event_update' => AppColors.primary,
        _ => AppColors.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read ? AppColors.card : AppColors.cardHighlight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.read ? AppColors.border : _typeColor.withOpacity(0.4),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(_typeIcon, color: _typeColor, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(notification.title, style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
            )),
            const SizedBox(height: 4),
            Text(notification.body, style: AppTextStyles.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(DateFormatter.timeAgo(notification.createdAt), style: AppTextStyles.caption),
          ])),
          if (!notification.read)
            Container(
              width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(color: _typeColor, shape: BoxShape.circle),
            ),
        ]),
      ),
    );
  }

  IconData get _typeIcon => switch (notification.type) {
        'crowd_alert' => Icons.warning_amber_rounded,
        'order_update' => Icons.restaurant,
        'ai_tip' => Icons.auto_awesome,
        'event_update' => Icons.sports_soccer,
        _ => Icons.notifications_outlined,
      };
}
