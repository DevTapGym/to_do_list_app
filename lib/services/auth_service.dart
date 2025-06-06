import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_response.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
      validateStatus: (status) {
        return true;
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<LoginResult> loginWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return LoginResult(error: "Người dùng huỷ đăng nhập");
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return LoginResult(error: "Không thể lấy thông tin xác thực từ Google");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        return LoginResult(error: "Không thể đăng nhập bằng Google");
      }

      if (user.email == null) {
        return LoginResult(error: "Email người dùng không khả dụng");
      }

      // Lấy thông tin người dùng
      final email = user.email!;
      final name = user.displayName ?? "";
      final avatar = user.photoURL ?? "";

      print("Đăng nhập thành công với Google: $email, $name, $avatar");

      // Gửi dữ liệu về backend
      final response = await dio.post(
        "/api/v1/auth/login-google",
        data: {"email": email, "displayName": name, "photoURL": avatar},
      );

      print("Response từ server: ${response.data}");

      final status = response.data["status"] as int?;
      final error = response.data["error"] as String?;
      final message = response.data["message"] as String?;

      if (response.statusCode == 200 && status == 200) {
        final data = response.data["data"];
        AuthResponse authResponse = AuthResponse.fromJson(data);

        final storage = FlutterSecureStorage();
        await storage.write(
          key: 'access_token',
          value: authResponse.accessToken,
        );

        return LoginResult(authResponse: authResponse);
      }

      if (status == 400 && error == "User is not active") {
        return LoginResult(isActive: false, status: 400, error: error);
      }

      if (status == 500 && error == "User not found") {
        return LoginResult(error: error, status: 500);
      }

      return LoginResult(error: message ?? "Lỗi không xác định từ server.");
    } catch (e) {
      final errorMessage = e.toString();
      print("Lỗi khi đăng nhập bằng Google: $errorMessage");
      return LoginResult(error: "Lỗi khi đăng nhập bằng Google: $errorMessage");
    }
  }

  Future<String?> _getToken() async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'access_token');
    return accessToken;
  }

  Future<Options> _getOptionsWithToken() async {
    final token = await _getToken();
    return Options(
      headers: {"Authorization": "Bearer $token"},
      validateStatus: (status) {
        return true;
      },
    );
  }

  Future<Response> get(String path) async {
    final options = await _getOptionsWithToken();
    return await dio.get(path, options: options);
  }

  Future<Response> post(String path, dynamic data) async {
    final options = await _getOptionsWithToken();
    return await dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, dynamic data) async {
    final options = await _getOptionsWithToken();
    return await dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path) async {
    final options = await _getOptionsWithToken();
    return await dio.delete(path, options: options);
  }

  Future<LoginResult> verifyToken() async {
    try {
      final storage = FlutterSecureStorage();
      String? accessToken = await storage.read(key: 'access_token');
      print('Access Token: $accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        return LoginResult(error: "No token found", status: 401);
      }

      Response response = await dio.get(
        "/api/v1/auth/profile",
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );
      print('Response Data: ${response.data}');
      print('Status: ${response.data["status"]}');
      print('Message: ${response.data["message"]}');
      print('Error: ${response.data["error"]}');
      print('Data: ${response.data["data"]}');

      final status = response.data["status"] as int? ?? 0;
      final error = response.data["error"] as String?;
      final message = response.data["message"] as String?;

      if (response.statusCode == 200 && status == 200) {
        final data = response.data["data"];
        if (data == null || data is! Map<String, dynamic>) {
          print('Invalid or missing data field');
          return LoginResult(error: "Invalid response data", status: 500);
        }
        print('Parsing data to AuthResponse: $data');
        AuthResponse authResponse = AuthResponse.fromRes(data);
        authResponse.accessToken = accessToken;
        print('Parsed AuthResponse: ${authResponse.user.email}');
        return LoginResult(authResponse: authResponse);
      }

      if (status == 401) {
        await storage.delete(key: 'access_token');
        return LoginResult(
          error: error ?? message ?? "Token expired or invalid",
          status: 401,
        );
      }

      return LoginResult(
        error: message ?? error ?? "Failed to verify token",
        status: status,
      );
    } catch (e, stackTrace) {
      print('Exception in verifyToken: $e');
      print('StackTrace: $stackTrace');
      return LoginResult(error: "Error verifying token: $e", status: 500);
    }
  }

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

        final storage = FlutterSecureStorage();
        await storage.write(
          key: 'access_token',
          value: authResponse.accessToken,
        );

        return LoginResult(authResponse: authResponse);
      }

      if (status == 400 && error == "User is not active") {
        return LoginResult(isActive: false, status: 400, error: error);
      }

      if (status == 500 && error == "Bad credentials") {
        return LoginResult(error: error, status: 500);
      }

      if (status == 500 && error == "User not found") {
        return LoginResult(error: error, status: 500);
      }
      return LoginResult(error: message ?? "Đã xảy ra lỗi không xác định.");
    } catch (e) {
      return LoginResult(error: "Lỗi khi gọi API: $e");
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      Response response = await dio.post(
        "/api/v1/auth/retry-password",
        queryParameters: {"email": email},
      );

      if (response.statusCode == 200 && response.data["status"] == 200) {
        return true;
      } else if (response.data["status"] == 400 &&
          response.data["error"] == "Email not found") {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print("Lỗi khi gửi yêu cầu quên mật khẩu: $e");
      return false;
    }
  }

  Future<bool> resetPassword(String email, String password, String code) async {
    try {
      Response response = await dio.post(
        "/api/v1/auth/change-password-retry",
        data: {"email": email, "password": password, "code": code},
      );
      print("Response: ${response.data}");

      if (response.statusCode == 200 && response.data["status"] == 200) {
        return true;
      } else if (response.data["status"] == 400 &&
          response.data["error"] == "Invalid code") {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print("Lỗi khi đặt lại mật khẩu: $e");
      return false;
    }
  }

  Future<String> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await dio.post(
        "/api/v1/auth/register",
        data: {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
        },
      );

      if (response.statusCode == 200 && response.data["status"] == 200) {
        return "success";
      } else if (response.data["status"] == 400 &&
          response.data["error"] == "Email already exists") {
        return "Email đã tồn tại";
      } else if (response.data["status"] == 400 &&
          response.data["error"] == "Passwords not strong") {
        return "Mật khẩu không đủ mạnh";
      } else {
        return response.data["message"] ?? "Đã xảy ra lỗi không xác định.";
      }
    } catch (e) {
      print("Lỗi khi đăng ký: $e");
      return "Lỗi máy chủ hoặc mất kết nối";
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
  final int status;
  final String? error;

  LoginResult({
    this.authResponse,
    this.isActive = true,
    this.status = 200,
    this.error,
  });
}
