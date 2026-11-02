import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorage _secureStorage;
  // Note: ApiService is needed for login, but for simplicity in this step
  // I'll focus on the session management.

  AuthBloc(this._secureStorage) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final token = await _secureStorage.getToken();
    if (token != null) {
      emit(Authenticated(token));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // In a real app, call ApiService.login(event.username, event.password)
      // For now, simulating a successful login with dummyjson logic
      if (event.username == 'emilys' && event.password == 'emilyspass') {
        const token = 'dummy_token'; // Should come from API
        await _secureStorage.saveToken(token);
        emit(Authenticated(token));
      } else {
        emit(AuthError('Invalid username or password'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _secureStorage.deleteToken();
    emit(Unauthenticated());
  }
}
