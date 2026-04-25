import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_keys.dart';
import 'prompts.dart';

class GeminiService {
  static GeminiService? _instance;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  GeminiService._();

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  bool get isAvailable => ApiKeys.isGeminiConfigured;

  void _ensureModel() {
    if (_model == null && isAvailable) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: ApiKeys.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 512,
          topP: 0.9,
        ),
      );
    }
  }

  Future<String> _generate(String prompt, {String? fallback}) async {
    if (!isAvailable) return fallback ?? _mockResponse(prompt);
    try {
      _ensureModel();
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? (fallback ?? 'No response generated.');
    } catch (e) {
      return fallback ?? _mockResponse(prompt);
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────

  Future<String> getNavigationAdvice({
    required String userZone,
    required String destination,
    required List<String> crowdedZones,
    required List<String> clearZones,
  }) async {
    final prompt = GeminiPrompts.navigationPrompt(
      userZone: userZone,
      destination: destination,
      crowdedZones: crowdedZones,
      clearZones: clearZones,
    );
    return _generate(prompt, fallback: _mockNavigation(userZone, destination));
  }

  // ── Queue Prediction ───────────────────────────────────────────────────

  Future<String> predictQueueWait({
    required String queueName,
    required int currentLength,
    required int currentWaitMins,
    required String timeOfDay,
    required String eventStatus,
  }) async {
    final prompt = GeminiPrompts.queuePredictionPrompt(
      queueName: queueName,
      currentLength: currentLength,
      currentWaitMins: currentWaitMins,
      timeOfDay: timeOfDay,
      eventStatus: eventStatus,
    );
    return _generate(prompt, fallback: _mockQueuePrediction(queueName, currentWaitMins));
  }

  // ── Chat ───────────────────────────────────────────────────────────────

  void initChat({
    required String userZone,
    required String eventName,
    required String eventStatus,
    required int crowdPercent,
  }) {
    if (!isAvailable) return;
    _ensureModel();
    final systemPrompt = GeminiPrompts.chatSystemPrompt(
      userZone: userZone,
      eventName: eventName,
      eventStatus: eventStatus,
      crowdPercent: crowdPercent,
    );
    _chatSession = _model!.startChat(
      history: [
        Content.text(systemPrompt),
        Content.model([TextPart('Understood! I\'m ready to help fans at Nexus Arena. What do you need?')]),
      ],
    );
  }

  Future<String> sendChatMessage(String message, {List<String> context = const []}) async {
    if (!isAvailable || _chatSession == null) {
      return _mockChatResponse(message);
    }
    try {
      final response = await _chatSession!.sendMessage(
        Content.text(GeminiPrompts.chatUserPrompt(message, context)),
      );
      return response.text ?? 'Sorry, I couldn\'t process that. Try again!';
    } catch (e) {
      return _mockChatResponse(message);
    }
  }

  // ── Event Summary ──────────────────────────────────────────────────────

  Future<String> generateEventSummary({
    required String homeTeam,
    required String awayTeam,
    required int homeScore,
    required int awayScore,
    required int minute,
    required List<String> highlights,
  }) async {
    final prompt = GeminiPrompts.eventSummaryPrompt(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      minute: minute,
      highlights: highlights,
    );
    return _generate(
      prompt,
      fallback: '$homeTeam lead $homeScore–$awayScore at the $minute\' mark. '
          'The crowd is electric as both teams battle intensely. '
          'Watch for ${homeScore > awayScore ? homeTeam : awayTeam}\'s next move!',
    );
  }

  // ── Quick Tips ─────────────────────────────────────────────────────────

  Future<List<String>> getQuickTips({
    required String userZone,
    required int crowdPercent,
    required int nearestQueueMins,
  }) async {
    final prompt = GeminiPrompts.quickSuggestionsPrompt(
      userZone: userZone,
      crowdPercent: crowdPercent,
      nearestQueueMins: nearestQueueMins,
    );
    final raw = await _generate(prompt);
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.take(3).toList();
  }

  // ── Mock Fallbacks ─────────────────────────────────────────────────────

  String _mockResponse(String prompt) {
    if (prompt.contains('navigation') || prompt.contains('route')) {
      return _mockNavigation('your zone', 'destination');
    }
    if (prompt.contains('queue')) return _mockQueuePrediction('queue', 10);
    return 'AI service unavailable. Add your Gemini API key in api_keys.dart to enable live AI responses.';
  }

  String _mockNavigation(String from, String to) {
    return '📍 Best Route: $from → Corridor B → $to\n'
        '↩️ Alternate: Main Concourse → Gate 5 → $to\n'
        '🚶 Estimated walk: 4 minutes\n'
        '💡 Tip: Avoid the Food Court area — currently at high capacity.';
  }

  String _mockQueuePrediction(String name, int currentWait) {
    final predicted = (currentWait * 0.85).round();
    return '⏱️ In 15 mins: ~$predicted min wait\n'
        '✅ Best time: Next 10 minutes (before halftime rush)\n'
        '📊 Crowd trending down as event heads into final stages.';
  }

  String _mockChatResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('food') || lower.contains('eat') || lower.contains('hungry')) {
      return '🍔 The Food Court (Zone 6) has the widest selection! Currently ~12 min wait. Try North Food Stall for a shorter queue (~5 min right now).';
    }
    if (lower.contains('toilet') || lower.contains('restroom') || lower.contains('bathroom')) {
      return '🚻 West Wing restrooms have the shortest queue right now (~2 min). East Wing is also clear. Avoid South Stand restrooms — high wait currently.';
    }
    if (lower.contains('park') || lower.contains('car')) {
      return '🚗 Parking Area is at 65% capacity. Gates A and C have the shortest exit queues after the match. Plan to leave 10 mins early to beat the rush!';
    }
    if (lower.contains('score') || lower.contains('goal')) {
      return '⚽ FC Nexus lead 2–1 at the 67th minute! Marco Diaz scored a brilliant header. City United are pushing hard for an equaliser.';
    }
    if (lower.contains('seat') || lower.contains('where')) {
      return '📍 Check the Map screen for your seat location and real-time crowd heatmap. Your zone details are shown on your profile.';
    }
    return '👋 I\'m your SmartStadium AI assistant! I can help with navigation, queues, food ordering, and event info. Add your Gemini API key to enable full AI responses. What do you need?';
  }
}
