import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event_entity.dart';
import '../../../../services/mock/mock_data_service.dart';
import '../../../../services/gemini/gemini_service.dart';

final liveEventStreamProvider = StreamProvider<EventEntity>((ref) {
  return MockDataService.liveEventStream().map((m) => EventEntity.fromMap(m));
});

final eventAiSummaryProvider = FutureProvider.family<String, EventEntity>((ref, event) async {
  return GeminiService.instance.generateEventSummary(
    homeTeam: '${event.homeTeamShort} (${event.homeScore.display})',
    awayTeam: '${event.awayTeamShort} (${event.awayScore.display})',
    homeScore: event.homeScore.runs,
    awayScore: event.awayScore.runs,
    minute: (event.homeScore.overs * 6).round(),
    highlights: event.highlights,
  );
});
