import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    LoginResult response = await authService.login(event.email, event.password);

    if (response.authResponse != null) {
      emit(
        AuthAuthenticated(authResponse: response.authResponse!, isActive: true),
      );
    } else if (response.isActive) {
      // Tài khoản đúng nhưng chưa active
      emit(AuthAuthenticated(authResponse: null, isActive: false));
    } else {
      emit(AuthError(message: response.error ?? "Đăng nhập thất bại"));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    emit(AuthUnauthenticated());
  }
}
