import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../../../services/gemini/gemini_service.dart';

const _uuid = Uuid();

class AIChatNotifier extends StateNotifier<List<ChatMessageEntity>> {
  AIChatNotifier() : super([]) {
    _init();
  }

  void _init() {
    GeminiService.instance.initChat(
      userZone: 'North Stand',
      eventName: 'Champions League Final',
      eventStatus: 'live',
      crowdPercent: 72,
    );
    // Welcome message
    state = [
      ChatMessageEntity(
        id: _uuid.v4(),
        text: '👋 Hi! I\'m your SmartStadium AI assistant for Nexus Arena.\n\nI can help you with:\n• 🗺️ Navigation & routing\n• ⏱️ Queue wait times\n• 🍔 Food & ordering\n• ⚽ Live event updates\n\nWhat do you need?',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageEntity(
      id: _uuid.v4(),
      text: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final loadingMsg = ChatMessageEntity(
      id: 'loading',
      text: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = [...state, userMsg, loadingMsg];

    try {
      final recentContext = state
          .where((m) => !m.isLoading)
          .take(6)
          .map((m) => '${m.isUser ? "User" : "AI"}: ${m.text}')
          .toList();

      final response = await GeminiService.instance.sendChatMessage(
        text,
        context: recentContext,
      );

      final aiMsg = ChatMessageEntity(
        id: _uuid.v4(),
        text: response,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      state = state.where((m) => m.id != 'loading').toList();
      state = [...state, aiMsg];
    } catch (e) {
      state = state.where((m) => m.id != 'loading').toList();
      state = [
        ...state,
        ChatMessageEntity(
          id: _uuid.v4(),
          text: 'Sorry, I had trouble responding. Please try again.',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  void clearChat() {
    state = [];
    _init();
  }
}

final aiChatProvider =
    StateNotifierProvider<AIChatNotifier, List<ChatMessageEntity>>((ref) {
  return AIChatNotifier();
});

// Quick suggestion chips
final chatSuggestionsProvider = Provider<List<String>>((ref) {
  return [
    'Where should I go for food?',
    'Which queue is shortest?',
    'What\'s the current score?',
    'How do I get to my seat?',
    'Where are the restrooms?',
    'Is parking full?',
  ];
});
