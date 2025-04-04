class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json["accessToken"],
      user: User.fromJson(json["user"]),
    );
  }
}

class User {
  final int id;
  final String email;
  final String name;
  final String phone;
  final String? avatar;

  User({required this.id, required this.email, required this.name, required this.phone, this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      email: json["email"],
      name: json["name"],
      phone: json["phone"],
      avatar: json["avatar"],
    );
  }
}
