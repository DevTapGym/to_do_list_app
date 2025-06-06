import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<LogoutEvent>(_onLogout);
    on<VerifyTokenEvent>(_onVerifyToken);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    LoginResult response = await authService.login(event.email, event.password);

    if (response.authResponse != null) {
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

  Future<void> _onGoogleLogin(
    GoogleLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final response = await authService.loginWithGoogle();

    if (response.authResponse != null) {
      emit(
        AuthAuthenticated(authResponse: response.authResponse!, isActive: true),
      );
    } else {
      if (!response.isActive && response.status == 400) {
        emit(AuthAuthenticated(authResponse: null, isActive: false));
      } else if (response.status == 500 && response.error == "User not found") {
        emit(AuthError(message: "Người dùng không tồn tại"));
      } else {
        emit(AuthError(message: response.error ?? "Đăng nhập Google thất bại"));
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

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      if (currentState.authResponse != null) {
        final updatedUser = User(
          id: currentState.authResponse!.user.id,
          email: currentState.authResponse!.user.email,
          name: event.name,
          phone: event.phone,
          avatar: event.avatar ?? currentState.authResponse!.user.avatar,
        );
        final updatedAuthResponse = AuthResponse(
          accessToken: currentState.authResponse!.accessToken,
          user: updatedUser,
        );
        emit(
          AuthAuthenticated(
            authResponse: updatedAuthResponse,
            isActive: currentState.isActive,
          ),
        );
      }
    }
  }
}
