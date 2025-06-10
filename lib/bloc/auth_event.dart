abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });
}


class CheckCodeEvent extends AuthEvent {
  final String email;
  final String code;

  CheckCodeEvent({required this.email,required this.code});
}

class LogoutEvent extends AuthEvent {}
