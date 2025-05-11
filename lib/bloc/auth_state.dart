import 'package:to_do_list_app/models/auth_response.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthResponse? authResponse;
  final bool isActive;

  AuthAuthenticated({required this.authResponse, required this.isActive});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
