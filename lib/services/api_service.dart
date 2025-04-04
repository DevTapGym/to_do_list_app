import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));

  Future<AuthResponse?> login(String email, String password) async {
    try {
      Response response = await dio.post("/api/v1/auth/login", data: {
        "username": email,
        "password": password,
      });

      print( response.data);

      if (response.statusCode == 200) {
        final data = response.data["data"];
        AuthResponse authResponse = AuthResponse.fromJson(data);

        // Lưu accessToken vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", authResponse.accessToken);

        print("Đăng nhập thành công!");
        return authResponse;
      }
    } catch (e) {
      print("Lỗi đăng nhập: $e");
    }
    return null;
  }
}
