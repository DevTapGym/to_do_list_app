import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/register_response.dart';
import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc({required this.apiService}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RegisterEvent>(_onRegister);
    on<CheckCodeEvent>(_onCheckCode);
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    AuthResponse? authResponse = await apiService.login(
      event.email,
      event.password,
    );

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

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    RegisterResponse? registerResponse = await apiService.register(
      event.name,
      event.email,
      event.password,
      event.phone,
    );

    if (registerResponse != null) {
      emit(AuthRegister(registerResponse: registerResponse));
    } else {
      emit(AuthError(message: "Đăng ký thất bại"));
    }
  }

  void _onCheckCode(CheckCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    String? res = await apiService.checkCode(
      event.email,
      event.code
    );

    if (res != null) {
      emit(AuthCheckCode(code: res));
    } else {
      emit(AuthError(message: "Đăng ký thất bại"));
    }
  }
}
