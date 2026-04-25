import 'package:equatable/equatable.dart';

class CricketScore {
  final int runs;
  final int wickets;
  final double overs;

  const CricketScore({
    required this.runs,
    required this.wickets,
    required this.overs,
  });

  factory CricketScore.fromMap(Map<String, dynamic> map) {
    return CricketScore(
      runs: map['runs'] as int? ?? 0,
      wickets: map['wickets'] as int? ?? 0,
      overs: (map['overs'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get display => '$runs/$wickets ($overs)';
  String get shortDisplay => '$runs/$wickets';
}

class EventEntity extends Equatable {
  final String id;
  final String name;
  final String sport;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamShort;
  final String awayTeamShort;
  final String homeLogo;
  final String awayLogo;
  final CricketScore homeScore;
  final CricketScore awayScore;
  final String status;
  final String battingTeam;
  final int currentInnings;
  final double runRate;
  final double requiredRunRate;
  final int target;
  final String partnership;
  final List<String> highlights;
  final int attendance;
  final String aiSummary;
  final String venue;
  final DateTime startTime;

  const EventEntity({
    required this.id,
    required this.name,
    required this.sport,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamShort = '',
    this.awayTeamShort = '',
    required this.homeLogo,
    required this.awayLogo,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    this.battingTeam = '',
    this.currentInnings = 1,
    this.runRate = 0.0,
    this.requiredRunRate = 0.0,
    this.target = 0,
    this.partnership = '',
    required this.highlights,
    required this.attendance,
    required this.aiSummary,
    this.venue = '',
    required this.startTime,
  });

  factory EventEntity.fromMap(Map<String, dynamic> map) {
    final homeScoreMap = map['homeScore'] as Map<String, dynamic>? ?? {};
    final awayScoreMap = map['awayScore'] as Map<String, dynamic>? ?? {};

    return EventEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      sport: map['sport'] as String? ?? 'cricket',
      homeTeam: map['homeTeam'] as String,
      awayTeam: map['awayTeam'] as String,
      homeTeamShort: map['homeTeamShort'] as String? ?? '',
      awayTeamShort: map['awayTeamShort'] as String? ?? '',
      homeLogo: map['homeLogo'] as String? ?? '🔴',
      awayLogo: map['awayLogo'] as String? ?? '🟡',
      homeScore: CricketScore.fromMap(homeScoreMap),
      awayScore: CricketScore.fromMap(awayScoreMap),
      status: map['status'] as String,
      battingTeam: map['battingTeam'] as String? ?? '',
      currentInnings: map['currentInnings'] as int? ?? 1,
      runRate: (map['runRate'] as num?)?.toDouble() ?? 0.0,
      requiredRunRate: (map['requiredRunRate'] as num?)?.toDouble() ?? 0.0,
      target: map['target'] as int? ?? 0,
      partnership: map['partnership'] as String? ?? '',
      highlights: List<String>.from(map['highlights'] as List? ?? []),
      attendance: map['attendance'] as int? ?? 0,
      aiSummary: map['aiSummary'] as String? ?? '',
      venue: map['venue'] as String? ?? '',
      startTime: DateTime.tryParse(map['startTime'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool get isLive => status == 'live';
  bool get isSecondInnings => currentInnings == 2;
  int get runsNeeded => isSecondInnings ? target - homeScore.runs : 0;
  int get ballsRemaining => isSecondInnings ? ((20 - homeScore.overs) * 6).round() : 0;

  @override
  List<Object?> get props => [id, homeScore.runs, awayScore.runs, status, currentInnings];
}
