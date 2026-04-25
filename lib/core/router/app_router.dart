import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_names.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/queue/presentation/screens/queue_screen.dart';
import '../../features/food/presentation/screens/food_screen.dart';
import '../../features/food/presentation/screens/cart_screen.dart';
import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/event/presentation/screens/event_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/fan_zone/presentation/screens/fan_zone_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/stadium_intelligence/presentation/screens/stadium_intelligence_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Main shell with bottom nav
class _MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  static const _tabs = [
    RouteNames.home,
    RouteNames.stadiumIntelligence,
    RouteNames.event,
    RouteNames.map,
    RouteNames.fanZone,
  ];

  int _indexOf(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _indexOf(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => context.go(_tabs[i]),
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: const Color(0xFF475569),
        backgroundColor: const Color(0xFF0D1424),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights), label: 'Stadium'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_cricket_outlined), activeIcon: Icon(Icons.sports_cricket), label: 'Live Match'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), activeIcon: Icon(Icons.forum), label: 'Fan Zone'),
        ],
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loc = state.matchedLocation;

      // Don't redirect during loading or on auth screens
      if (authState.status == AuthStatus.loading) return null;

      final isAuthRoute = loc == RouteNames.login ||
          loc == RouteNames.signup ||
          loc == RouteNames.onboarding ||
          loc == RouteNames.splash;

      if (authState.status == AuthStatus.unauthenticated && !isAuthRoute) {
        return RouteNames.login;
      }

      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.signup, builder: (_, __) => const SignupScreen()),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: RouteNames.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: RouteNames.stadiumIntelligence, builder: (_, __) => const StadiumIntelligenceScreen()),
          GoRoute(path: RouteNames.event, builder: (_, __) => const EventScreen()),
          GoRoute(path: RouteNames.map, builder: (_, __) => const MapScreen()),
          GoRoute(path: RouteNames.fanZone, builder: (_, __) => const FanZoneScreen()),
        ],
      ),

      // Stack routes (no bottom nav)
      GoRoute(path: RouteNames.queue, builder: (_, __) => const QueueScreen()),
      GoRoute(path: RouteNames.food, builder: (_, __) => const FoodScreen()),
      GoRoute(path: RouteNames.cart, builder: (_, __) => const CartScreen()),
      GoRoute(path: RouteNames.aiChat, builder: (_, __) => const AIChatScreen()),
      GoRoute(path: RouteNames.notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: RouteNames.profile, builder: (_, __) => const ProfileScreen()),
      GoRoute(path: RouteNames.settings, builder: (_, __) => const SettingsScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF060A14),
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}',
            style: const TextStyle(color: Colors.white70)),
      ),
    ),
  );
});
