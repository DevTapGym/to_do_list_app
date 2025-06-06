abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class LogoutEvent extends AuthEvent {}

class VerifyTokenEvent extends AuthEvent {}

class GoogleLoginEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String name;
  final String phone;
  final String? avatar;

  UpdateProfileEvent({required this.name, required this.phone, this.avatar});
}
