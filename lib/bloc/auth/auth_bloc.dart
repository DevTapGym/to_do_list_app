import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<VerifyTokenEvent>(_onVerifyToken);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    LoginResult response = await authService.login(event.email, event.password);

    if (response.authResponse != null) {
      // if (getIt.isRegistered<User>()) {
      //   getIt.unregister<User>();
      // }
      // getIt.registerSingleton<User>(response.authResponse!.user);

      emit(
        AuthAuthenticated(authResponse: response.authResponse!, isActive: true),
      );
    } else {
      if (!response.isActive && response.status == 400) {
        emit(AuthAuthenticated(authResponse: null, isActive: false));
      } else if (response.status == 500 &&
          response.error == "Bad credentials") {
        emit(AuthError(message: "Sai tên đăng nhập hoặc mật khẩu"));
      } else {
        emit(AuthError(message: "Đăng nhập thất bại"));
      }
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    emit(AuthUnauthenticated());
  }

  Future<void> _onVerifyToken(
    VerifyTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    LoginResult response = await authService.verifyToken();

    if (response.authResponse != null) {
      // if (getIt.isRegistered<User>()) {
      //   getIt.unregister<User>();
      // }
      // getIt.registerSingleton<User>(response.authResponse!.user);

      emit(
        AuthAuthenticated(authResponse: response.authResponse!, isActive: true),
      );
    } else {
      emit(AuthUnauthenticated());
      if (response.error != null) {
        emit(AuthError(message: response.error!));
      }
    }
  }
}
