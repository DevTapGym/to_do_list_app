import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/register_response.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthResponse authResponse;
  AuthAuthenticated({required this.authResponse});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class AuthRegister extends AuthState {
  final RegisterResponse registerResponse;
  AuthRegister({required this.registerResponse});
}

class AuthCheckCode extends AuthState {
  final String code;
  AuthCheckCode({required this.code});
}
