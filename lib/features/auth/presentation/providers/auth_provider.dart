import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';

// Auth state
enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserEntity? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(
          uid: 'demo_user_001',
          name: prefs.getString('user_name') ?? 'Stadium Fan',
          email: prefs.getString('user_email') ?? 'fan@nexusarena.com',
          seatNumber: 'N-47',
          currentZone: 'zone_pavilion',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );
    } else {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    await Future.delayed(const Duration(seconds: 1));

    // Demo: accept any non-empty email/password
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Please enter your email and password.',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Password must be at least 6 characters.',
      );
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', email);

    final name = prefs.getString('user_name') ?? email.split('@').first;
    state = AuthState(
      status: AuthStatus.authenticated,
      user: UserEntity(
        uid: 'demo_user_001',
        name: name,
        email: email,
        seatNumber: 'N-47',
        currentZone: 'zone_pavilion',
        createdAt: DateTime.now(),
      ),
    );
    return true;
  }

  Future<bool> signUp(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'All fields are required.',
      );
      return false;
    }

    if (!email.contains('@')) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Enter a valid email address.',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Password must be at least 6 characters.',
      );
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);

    state = AuthState(
      status: AuthStatus.authenticated,
      user: UserEntity(
        uid: 'demo_user_001',
        name: name,
        email: email,
        seatNumber: 'N-47',
        currentZone: 'zone_pavilion',
        createdAt: DateTime.now(),
      ),
    );
    return true;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_onboarded', true);
  }

  Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_onboarded') ?? false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
