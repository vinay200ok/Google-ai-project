import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/fan_zone_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/fan_message_entity.dart';

class FanZoneScreen extends ConsumerStatefulWidget {
  const FanZoneScreen({super.key});

  @override
  ConsumerState<FanZoneScreen> createState() => _FanZoneScreenState();
}

class _FanZoneScreenState extends ConsumerState<FanZoneScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    ref.read(sendFanMessageProvider)(text, ref);
    Future.delayed(const Duration(milliseconds: 100), _scrollToTop);
  }

  void _scrollToTop() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamAsync = ref.watch(fanMessagesStreamProvider);
    final localMsgs = ref.watch(localMessagesProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fan Zone', style: AppTextStyles.headlineMedium),
          Text('North Stand • Live Chat', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
        ]),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Online banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Live fan chat • 1,247 fans online', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
            ]),
          ),

          Expanded(
            child: streamAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (streamMsgs) {
                final all = [...localMsgs, ...streamMsgs];
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: all.length,
                  itemBuilder: (_, i) => _FanMessageBubble(
                    message: all[i],
                    isMe: all[i].userId == user?.uid,
                  ).animate(delay: Duration(milliseconds: i < 5 ? i * 40 : 0)).fadeIn(),
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cheer with the crowd...',
                    filled: true, fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.greenGradient),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FanMessageBubble extends StatelessWidget {
  final FanMessageEntity message;
  final bool isMe;
  const _FanMessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceVariant),
              child: Center(child: Text(message.userName[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(message.userName, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMe ? const LinearGradient(colors: AppColors.greenGradient) : null,
                  color: isMe ? null : AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isMe ? null : Border.all(color: AppColors.border),
                ),
                child: Text(message.text, style: AppTextStyles.bodyMedium.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                )),
              ),
              const SizedBox(height: 3),
              Text(DateFormatter.timeAgo(message.createdAt), style: AppTextStyles.caption),
            ],
          )),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
