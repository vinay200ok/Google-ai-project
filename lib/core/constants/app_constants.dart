class AppConstants {
  static const String appName = 'SmartStadium AI';
  static const String appVersion = '1.0.0';
  static const String stadiumName = 'M. Chinnaswamy Stadium';
  static const String stadiumCity = 'Bangalore';
  static const int stadiumCapacity = 40000;

  // Match info
  static const String matchTitle = 'IPL 2026';
  static const String homeTeam = 'Royal Challengers Bengaluru';
  static const String homeTeamShort = 'RCB';
  static const String awayTeam = 'Gujarat Titans';
  static const String awayTeamShort = 'GT';

  // Demo mode — set false when real Firebase is connected
  static const bool isDemoMode = true;

  // Refresh intervals (seconds)
  static const int crowdRefreshSeconds = 5;
  static const int queueRefreshSeconds = 8;
  static const int eventRefreshSeconds = 10;
  static const int gateRefreshSeconds = 6;
  static const int stallRefreshSeconds = 7;
  static const int chatRefreshSeconds = 3;

  static const List<String> zoneIds = [
    'zone_pavilion',
    'zone_bbmp',
    'zone_p_stand',
    'zone_corporate',
    'zone_food_court',
    'zone_washroom',
    'zone_parking',
  ];

  static const Map<String, String> zoneNames = {
    'zone_pavilion': 'Pavilion End',
    'zone_bbmp': 'BBMP Stand',
    'zone_p_stand': 'P Stand',
    'zone_corporate': 'Corporate Box',
    'zone_food_court': 'Food Court',
    'zone_washroom': 'Washroom Block',
    'zone_parking': 'Parking Area',
  };

  static const List<String> gateIds = [
    'gate_1',
    'gate_2',
    'gate_3',
    'gate_4',
    'gate_5',
  ];

  static const Map<String, String> gateNames = {
    'gate_1': 'Gate 1 — MG Road',
    'gate_2': 'Gate 2 — Church St',
    'gate_3': 'Gate 3 — Cubbon Park',
    'gate_4': 'Gate 4 — VIP Entry',
    'gate_5': 'Gate 5 — BMTC Side',
  };
}
