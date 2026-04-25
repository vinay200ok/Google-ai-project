import 'dart:async';
import 'dart:math';

/// Simulates real-time Firebase/Firestore data streams for demo mode.
/// Replace with actual Firebase calls when ready.
class MockDataService {
  static final _rng = Random();

  // ── Zone / Crowd ──────────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> zonesStream() async* {
    while (true) {
      yield _generateZones();
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  static List<Map<String, dynamic>> _generateZones() {
    final zones = [
      {'id': 'zone_pavilion', 'name': 'Pavilion End', 'capacity': 8000, 'icon': '🏟️'},
      {'id': 'zone_bbmp', 'name': 'BBMP Stand', 'capacity': 7000, 'icon': '🏟️'},
      {'id': 'zone_p_stand', 'name': 'P Stand', 'capacity': 7000, 'icon': '🏟️'},
      {'id': 'zone_corporate', 'name': 'Corporate Box', 'capacity': 3000, 'icon': '⭐'},
      {'id': 'zone_food_court', 'name': 'Food Court', 'capacity': 4000, 'icon': '🍛'},
      {'id': 'zone_washroom', 'name': 'Washroom Block', 'capacity': 2000, 'icon': '🚻'},
      {'id': 'zone_parking', 'name': 'Parking Area', 'capacity': 9000, 'icon': '🚗'},
    ];
    return zones.map((z) {
      final cap = z['capacity'] as int;
      final occ = _rng.nextInt((cap * 0.95).toInt()) + (cap * 0.3).toInt();
      final pct = occ / cap;
      return {
        ...z,
        'currentOccupancy': occ.clamp(0, cap),
        'densityPercent': pct.clamp(0.0, 1.0),
        'densityLevel': pct < 0.5 ? 'low' : pct < 0.75 ? 'medium' : pct < 0.9 ? 'high' : 'critical',
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  // ── Gates ─────────────────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> gatesStream() async* {
    while (true) {
      yield _generateGates();
      await Future.delayed(const Duration(seconds: 6));
    }
  }

  static List<Map<String, dynamic>> _generateGates() {
    final gates = [
      {'id': 'gate_1', 'name': 'Gate 1 — MG Road', 'direction': 'North', 'baseCrowd': 0.7},
      {'id': 'gate_2', 'name': 'Gate 2 — Church St', 'direction': 'East', 'baseCrowd': 0.3},
      {'id': 'gate_3', 'name': 'Gate 3 — Cubbon Park', 'direction': 'South', 'baseCrowd': 0.5},
      {'id': 'gate_4', 'name': 'Gate 4 — VIP Entry', 'direction': 'West', 'baseCrowd': 0.8},
      {'id': 'gate_5', 'name': 'Gate 5 — BMTC Side', 'direction': 'South-East', 'baseCrowd': 0.4},
    ];
    return gates.map((g) {
      final base = g['baseCrowd'] as double;
      final crowd = (base + (_rng.nextDouble() * 0.3 - 0.15)).clamp(0.05, 0.98);
      final timeSaved = ((1.0 - crowd) * 12).round().clamp(0, 15);
      return {
        'id': g['id'],
        'name': g['name'],
        'direction': g['direction'],
        'crowd': crowd,
        'estimatedTimeSavedMins': timeSaved,
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  // ── Food Stalls (GO NOW / WAIT) ───────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> stallsStream() async* {
    while (true) {
      yield _generateStalls();
      await Future.delayed(const Duration(seconds: 7));
    }
  }

  static List<Map<String, dynamic>> _generateStalls() {
    final stalls = [
      {'id': 'stall_a', 'name': 'Dosa Corner', 'emoji': '🥘', 'baseWait': 6},
      {'id': 'stall_b', 'name': 'Biryani House', 'emoji': '🍛', 'baseWait': 10},
      {'id': 'stall_c', 'name': 'Drinks Counter', 'emoji': '🥤', 'baseWait': 3},
      {'id': 'stall_d', 'name': 'Vada Pav Stall', 'emoji': '🍔', 'baseWait': 5},
      {'id': 'stall_e', 'name': 'Chai & Samosa', 'emoji': '☕', 'baseWait': 4},
    ];
    return stalls.map((s) {
      final base = s['baseWait'] as int;
      final currentWait = (base + _rng.nextInt(8) - 3).clamp(1, 25);
      // Predicted wait has a bias to be sometimes higher, sometimes lower
      final predicted = (base + _rng.nextInt(12) - 2).clamp(2, 30);
      return {
        'id': s['id'],
        'name': s['name'],
        'emoji': s['emoji'],
        'current_wait': currentWait,
        'predicted_wait': predicted,
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  // ── Queues ────────────────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> queuesStream() async* {
    while (true) {
      yield _generateQueues();
      await Future.delayed(const Duration(seconds: 8));
    }
  }

  static List<Map<String, dynamic>> _generateQueues() {
    return [
      _makeQueue('q1', 'zone_pavilion', 'food', 'Pavilion Dosa Stall', 1, 25),
      _makeQueue('q2', 'zone_bbmp', 'food', 'BBMP Biryani Counter', 2, 40),
      _makeQueue('q3', 'zone_p_stand', 'restroom', 'P Stand Restrooms', 1, 15),
      _makeQueue('q4', 'zone_corporate', 'food', 'Corporate Lounge Café', 2, 10),
      _makeQueue('q5', 'zone_food_court', 'food', 'Main Food Court', 1, 60),
      _makeQueue('q6', 'zone_pavilion', 'merchandise', 'RCB Fan Store', 2, 20),
      _makeQueue('q7', 'zone_washroom', 'restroom', 'Central Washrooms', 1, 18),
      _makeQueue('q8', 'zone_parking', 'entry', 'Parking Gate A', 1, 35),
    ];
  }

  static Map<String, dynamic> _makeQueue(
      String id, String zoneId, String type, String name, int level, int baseLen) {
    final length = baseLen + _rng.nextInt(20) - 10;
    final wait = (length * 0.4).round() + _rng.nextInt(5);
    final aiWait = (wait * (0.8 + _rng.nextDouble() * 0.3)).round();
    return {
      'id': id,
      'zoneId': zoneId,
      'type': type,
      'name': name,
      'congestionLevel': level,
      'currentLength': length.clamp(0, 200),
      'estimatedWaitMins': wait.clamp(1, 60),
      'aiPredictedWaitMins': aiWait.clamp(1, 60),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // ── Live Cricket Match ────────────────────────────────────────────────────

  static Stream<Map<String, dynamic>> liveEventStream() async* {
    // GT has already batted — scored 152/6 in 20 overs
    double rcbOvers = 14.2;
    int rcbRuns = 118;
    int rcbWickets = 3;
    const int gtRuns = 178;
    const int gtWickets = 6;
    const double gtOvers = 20.0;
    final int target = gtRuns + 1; // 179

    while (true) {
      // Simulate ball-by-ball progression
      final ballOutcome = _rng.nextInt(10);
      if (ballOutcome < 3) {
        rcbRuns += 4; // boundary
      } else if (ballOutcome == 3) {
        rcbRuns += 6; // six
      } else if (ballOutcome < 7) {
        rcbRuns += _rng.nextInt(3); // 0, 1, or 2
      } else if (ballOutcome == 7 && rcbWickets < 9) {
        rcbWickets += 1; // wicket
        rcbRuns += _rng.nextInt(2);
      } else {
        rcbRuns += 1;
      }

      // Advance overs
      rcbOvers += 0.1;
      if ((rcbOvers * 10).round() % 10 == 7) {
        rcbOvers = (rcbOvers.floor() + 1).toDouble();
      }
      if (rcbOvers > 20.0) rcbOvers = 20.0;

      final isFinished = rcbOvers >= 20.0 || rcbRuns >= target || rcbWickets >= 10;
      final currentRR = rcbOvers > 0 ? rcbRuns / rcbOvers : 0.0;
      final remainingOvers = 20.0 - rcbOvers;
      final reqRR = remainingOvers > 0 ? (target - rcbRuns) / remainingOvers : 0.0;

      String matchStatus;
      if (isFinished) {
        if (rcbRuns >= target) {
          matchStatus = 'RCB won by ${10 - rcbWickets} wickets!';
        } else if (rcbRuns == gtRuns) {
          matchStatus = 'Match Tied!';
        } else {
          matchStatus = 'GT won by ${gtRuns - rcbRuns} runs!';
        }
      } else {
        matchStatus = 'live';
      }

      final highlights = <String>[
        if (ballOutcome == 3) '🏏 SIX! Massive hit over long-on! (${rcbOvers.toStringAsFixed(1)} ov)',
        if (ballOutcome < 3) '🏏 FOUR! Driven through covers! (${rcbOvers.toStringAsFixed(1)} ov)',
        if (ballOutcome == 7 && rcbWickets > 3) '❌ WICKET! RCB lose their ${rcbWickets}th! (${rcbOvers.toStringAsFixed(1)} ov)',
        '🏏 Partnership: ${30 + _rng.nextInt(40)} runs off ${20 + _rng.nextInt(25)} balls',
        '📊 Required: ${target - rcbRuns} runs off ${((20.0 - rcbOvers) * 6).round()} balls',
        '🔥 Kohli on ${35 + _rng.nextInt(30)}* off ${28 + _rng.nextInt(15)} balls',
      ];

      yield {
        'id': 'event_001',
        'name': 'IPL 2026 — Match 42',
        'sport': 'cricket',
        'homeTeam': 'Royal Challengers Bengaluru',
        'awayTeam': 'Gujarat Titans',
        'homeTeamShort': 'RCB',
        'awayTeamShort': 'GT',
        'homeLogo': '🔴',
        'awayLogo': '🟡',
        'homeScore': {'runs': rcbRuns, 'wickets': rcbWickets, 'overs': double.parse(rcbOvers.toStringAsFixed(1))},
        'awayScore': {'runs': gtRuns, 'wickets': gtWickets, 'overs': gtOvers},
        'status': matchStatus,
        'battingTeam': 'RCB',
        'currentInnings': 2,
        'runRate': double.parse(currentRR.toStringAsFixed(2)),
        'requiredRunRate': double.parse(reqRR.toStringAsFixed(2)),
        'target': target,
        'partnership': '${30 + _rng.nextInt(40)} (${20 + _rng.nextInt(25)})',
        'highlights': highlights,
        'attendance': 38472,
        'venue': 'M. Chinnaswamy Stadium, Bangalore',
        'aiSummary':
            'RCB are chasing ${target} in the 2nd innings. ${rcbRuns}/${rcbWickets} after ${rcbOvers.toStringAsFixed(1)} overs. '
            'The required run rate is ${reqRR.toStringAsFixed(2)}. '
            'Kohli is anchoring the chase with a composed knock. '
            'The Chinnaswamy crowd is electric — expect fireworks in the death overs!',
        'startTime': DateTime.now()
            .subtract(Duration(minutes: (rcbOvers * 4).toInt() + 45))
            .toIso8601String(),
      };
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> getNotifications() {
    return [
      {
        'id': 'n1',
        'title': '🚨 Crowd Alert — Pavilion End',
        'body': 'Pavilion End is at 92% capacity. Consider moving to P Stand.',
        'type': 'crowd_alert',
        'read': false,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 3)).toIso8601String(),
      },
      {
        'id': 'n2',
        'title': '✅ Order Ready!',
        'body': 'Your Biryani order is ready at Counter 2, Food Court.',
        'type': 'order_update',
        'read': false,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 8)).toIso8601String(),
      },
      {
        'id': 'n3',
        'title': '⭐ AI Tip',
        'body': 'Gate 2 (Church St) has the shortest entry queue — only 2 min wait!',
        'type': 'ai_tip',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 22)).toIso8601String(),
      },
      {
        'id': 'n4',
        'title': '🏏 WICKET! GT 152/6',
        'body': 'Shubman Gill caught at deep mid-wicket! GT struggling at 152/6.',
        'type': 'event_update',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      },
      {
        'id': 'n5',
        'title': '🏏 SIX! Kohli smashes it!',
        'body': 'Virat Kohli hits a massive six over long-on! RCB crowd goes wild!',
        'type': 'event_update',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      },
    ];
  }

  // ── Fan Messages ─────────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> fanMessagesStream() async* {
    final messages = <Map<String, dynamic>>[
      _fanMsg('u1', 'Rahul M.', 'What an atmosphere at Chinnaswamy! 🔥🏏', 5),
      _fanMsg('u2', 'Sneha R.', 'Pavilion End is PACKED! RCB! RCB! 🔴', 4),
      _fanMsg('u3', 'Arjun K.', 'Anyone at the Food Court? Biryani worth the queue?', 3),
      _fanMsg('u4', 'Priya S.', 'AI suggested Gate 2 — no queue at all! 🙌', 2),
      _fanMsg('u5', 'Vikram T.', 'COME ON RCB! Chase this down! 💪🔴', 1),
    ];
    int count = 0;
    while (true) {
      if (count > 0) {
        messages.insert(
          0,
          _fanMsg('u${count + 5}', _randomName(), _randomMessage(), 0),
        );
        if (messages.length > 30) messages.removeLast();
      }
      yield List.from(messages);
      count++;
      await Future.delayed(const Duration(seconds: 6));
    }
  }

  static Map<String, dynamic> _fanMsg(
      String uid, String name, String text, int minsAgo) {
    return {
      'id': 'msg_${uid}_$minsAgo',
      'userId': uid,
      'userName': name,
      'text': text,
      'zoneId': 'zone_pavilion',
      'createdAt': DateTime.now()
          .subtract(Duration(minutes: minsAgo))
          .toIso8601String(),
    };
  }

  static final _names = ['Karan', 'Meera', 'Rohan', 'Ananya', 'Dev', 'Neha', 'Aditya', 'Isha'];
  static final _msgs = [
    'RCB! RCB! 🔴🏏',
    'What a shot by Kohli! 🏏🔥',
    'Chinnaswamy is on fire! ⚡',
    'Corporate Box vibes are premium! ⭐',
    'Grabbing chai — brb! ☕',
    'This chase is THRILLING! 🏏',
    'SmartStadium AI is clutch — saved me 10 min! 🤖',
    'GT bowlers under pressure! 💪',
  ];

  static String _randomName() => _names[_rng.nextInt(_names.length)];
  static String _randomMessage() => _msgs[_rng.nextInt(_msgs.length)];

  // ── Food Menu ─────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> getFoodMenu() {
    return [
      {'id': 'f1', 'name': 'Masala Dosa', 'price': 120.0, 'category': 'South Indian', 'emoji': '🥘', 'desc': 'Crispy dosa with potato masala & chutneys', 'rating': 4.7, 'prepMins': 6},
      {'id': 'f2', 'name': 'Chicken Biryani', 'price': 220.0, 'category': 'Biryani', 'emoji': '🍛', 'desc': 'Hyderabadi style dum biryani with raita', 'rating': 4.8, 'prepMins': 8},
      {'id': 'f3', 'name': 'Vada Pav', 'price': 60.0, 'category': 'Snacks', 'emoji': '🍔', 'desc': 'Mumbai style vada pav with chutneys', 'rating': 4.5, 'prepMins': 3},
      {'id': 'f4', 'name': 'Samosa', 'price': 40.0, 'category': 'Snacks', 'emoji': '🥟', 'desc': 'Crispy samosa with mint & tamarind chutney', 'rating': 4.4, 'prepMins': 4},
      {'id': 'f5', 'name': 'Paneer Tikka', 'price': 180.0, 'category': 'Starters', 'emoji': '🧀', 'desc': 'Tandoor grilled paneer with mint sauce', 'rating': 4.6, 'prepMins': 10},
      {'id': 'f6', 'name': 'Masala Chai', 'price': 30.0, 'category': 'Drinks', 'emoji': '☕', 'desc': 'Piping hot masala tea with ginger', 'rating': 4.9, 'prepMins': 2},
      {'id': 'f7', 'name': 'Cold Coffee', 'price': 80.0, 'category': 'Drinks', 'emoji': '🥤', 'desc': 'Iced coffee blended with cream', 'rating': 4.6, 'prepMins': 3},
      {'id': 'f8', 'name': 'Butter Naan & Dal', 'price': 150.0, 'category': 'North Indian', 'emoji': '🫓', 'desc': 'Soft naan with dal makhani', 'rating': 4.5, 'prepMins': 7},
      {'id': 'f9', 'name': 'Fresh Lime Soda', 'price': 50.0, 'category': 'Drinks', 'emoji': '🍋', 'desc': 'Sweet or salted lime soda', 'rating': 4.7, 'prepMins': 2},
      {'id': 'f10', 'name': 'Kulfi', 'price': 70.0, 'category': 'Desserts', 'emoji': '🍦', 'desc': 'Creamy malai kulfi on stick', 'rating': 4.9, 'prepMins': 1},
    ];
  }

  // ── AI Navigation Suggestions ─────────────────────────────────────────────

  static Map<String, dynamic> getNavigationSuggestion(String fromZone) {
    const suggestions = {
      'zone_pavilion': {
        'route': 'Pavilion End → Corridor B → P Stand',
        'alternateRoute': 'Pavilion End → Main Concourse → BBMP Stand',
        'reason': 'P Stand is at 45% capacity right now — shortest path with least congestion.',
        'estimatedWalkMins': 4,
        'avoidZones': ['zone_food_court'],
      },
      'zone_bbmp': {
        'route': 'BBMP Stand → Gate 3 → Corporate Box',
        'alternateRoute': 'BBMP Stand → Tunnel C → Main Concourse',
        'reason': 'Corporate Box restrooms have zero queue. Ideal window now.',
        'estimatedWalkMins': 3,
        'avoidZones': ['zone_pavilion'],
      },
    };
    return suggestions[fromZone] ??
        {
          'route': 'Current Zone → Corridor A → Main Concourse',
          'alternateRoute': 'Current Zone → Gate 2 → Outer Ring',
          'reason': 'Main Concourse is flowing well. This route avoids the Food Court peak.',
          'estimatedWalkMins': 5,
          'avoidZones': ['zone_food_court'],
        };
  }
}
