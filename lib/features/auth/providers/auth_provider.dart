import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/auth_service.dart';
import '../../../config/client_config.dart';
import '../../../shared/providers/app_providers.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final ClientCredentials? credentials;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.credentials,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    ClientCredentials? credentials,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        credentials: credentials ?? this.credentials,
        error: error,
      );
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> checkSavedLogin() async {
    final authService = _ref.read(authServiceProvider);
    final saved = await authService.getSavedCredentials();
    if (saved != null) {
      _applyCredentials(saved);
      state = AuthState(
        status: AuthStatus.authenticated,
        credentials: saved,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final authService = _ref.read(authServiceProvider);
      final creds = await authService.login(email, password);
      _applyCredentials(creds);
      state = AuthState(
        status: AuthStatus.authenticated,
        credentials: creds,
      );
      return true;
    } catch (e) {
      String message = 'Login failed';
      if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }
      state = state.copyWith(status: AuthStatus.error, error: message);
      return false;
    }
  }

  Future<void> logout() async {
    final authService = _ref.read(authServiceProvider);
    await authService.logout();
    _ref.read(clientConfigProvider.notifier).state = null;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Load client config by lead ID (for PWA via ?client= URL param).
  Future<bool> loadClientById(int leadId) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final authService = _ref.read(authServiceProvider);
      final creds = await authService.fetchClientById(leadId);
      _applyCredentials(creds);
      state = AuthState(
        status: AuthStatus.authenticated,
        credentials: creds,
      );
      return true;
    } catch (e) {
      String message = 'Failed to load client configuration';
      if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }
      state = state.copyWith(status: AuthStatus.error, error: message);
      return false;
    }
  }

  void _applyCredentials(ClientCredentials creds) {
    final config = ClientConfig.fromCredentials(creds);
    _ref.read(clientConfigProvider.notifier).state = config;
  }
}
