import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
      validateStatus: (status) {
        return true;
      },
    ),
  );

  Future<LoginResult> login(String email, String password) async {
    try {
      Response response = await dio.post(
        "/api/v1/auth/login",
        data: {"username": email, "password": password},
      );

      final status = response.data["status"];
      final error = response.data["error"];
      final message = response.data["message"];

      if (response.statusCode == 200 && status == 200) {
        final data = response.data["data"];
        AuthResponse authResponse = AuthResponse.fromJson(data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", authResponse.accessToken);

        return LoginResult(authResponse: authResponse);
      }

      if (status == 400 && error == "User is not active") {
        return LoginResult(isActive: true);
      }

      if (status == 500 && error == "Bad credentials") {
        return LoginResult(error: "Sai tên đăng nhập hoặc mật khẩu");
      }

      return LoginResult(error: message ?? "Đã xảy ra lỗi không xác định.");
    } catch (e) {
      return LoginResult(error: "Lỗi khi gọi API: $e");
    }
  }

  Future<bool> checkCode(String email, String code) async {
    try {
      Response response = await dio.post(
        "/api/v1/auth/check-code",
        data: {"email": email, "code": code},
      );

      if (response.statusCode == 200 && response.data["status"] == 200) {
        print("Mã xác thực đúng.");
        return true;
      } else {
        print("Mã xác thực sai hoặc lỗi khác: ${response.data["message"]}");
      }
    } catch (e) {
      print("Lỗi khi kiểm tra mã: $e");
    }
    return false;
  }

  Future<bool> sendCode(String email) async {
    try {
      Response response = await dio.post(
        "/api/v1/auth/resend-code",
        data: {"email": email},
      );

      if (response.statusCode == 200 && response.data["status"] == 200) {
        print("Gửi lại mã thành công.");
        return true;
      } else {
        print("Gửi lại mã thất bại: ${response.data["message"]}");
      }
    } catch (e) {
      print("Lỗi khi gửi lại mã: $e");
    }
    return false;
  }
}

class LoginResult {
  final AuthResponse? authResponse;
  final bool isActive;
  final String? error;

  LoginResult({this.authResponse, this.isActive = false, this.error});
}
