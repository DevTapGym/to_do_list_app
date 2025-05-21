import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc({required this.apiService}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    AuthResponse? authResponse = await apiService.login(event.email, event.password);

    if (authResponse != null) {
      emit(AuthAuthenticated(authResponse: authResponse));
    } else {
      emit(AuthError(message: "Đăng nhập thất bại"));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    emit(AuthUnauthenticated());
  }
}
