import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/api_service.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorage _secureStorage;
  final ApiService _apiService;

  AuthBloc(this._secureStorage, this._apiService) : super(AuthInitial()) {
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
      final response = await _apiService.login(event.username, event.password);
      
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        await _secureStorage.saveToken(user.accessToken);
        emit(Authenticated(user.accessToken));
      } else {
        emit(AuthError('invalid_auth'));
      }
    } catch (e) {
      // Dio error or parsing error
      emit(AuthError('invalid_auth'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _secureStorage.deleteToken();
    emit(Unauthenticated());
  }
}
