class RegisterResponse {
  final int id;
  final String email;
  final String name;
  final String phone;
  final String? avatar;

  RegisterResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.avatar,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json["id"],
      email: json["email"],
      name: json["name"],
      phone: json["phone"],
      avatar: json["avatar"],
    );
  }
}
