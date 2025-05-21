import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));
  //Lấy token
  Future<String?> _getToken() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // return prefs.getString("access_token");
    return  'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJxdWFuZzE1OTI1OEBnbWFpbC5jb20iLCJwZXJtaXNzaW9uIjpbIlJPTEVfVVNFUl9DUkVBVEUiLCJST0xFX1VTRVJfVVBEQVRFIl0sImV4cCI6MTc0NzUwMjQ5NSwiaWF0IjoxNzQ3NDE2MDk1LCJ1c2VyIjp7ImlkIjoxLCJlbWFpbCI6InF1YW5nMTU5MjU4QGdtYWlsLmNvbSIsIm5hbWUiOiJRdWFuZyIsInBob25lIjoiMDM5NzEyNTA0NCIsImF2YXRhciI6bnVsbH19.SJO9oEqw0BuNHEAC9zPrVssIxHuFS4fEWHQtbGnVqT26C6SKwBWd59_qczdfz66ztTTIdS2C0eafnUs-ipnYqA';

  }
  Future<Options> _getOptionsWithToken() async {
    final token = await _getToken();
    return Options(
      headers: {
        "Authorization": "Bearer $token",
      },
      validateStatus: (status) {return true;}
    );
  }
  
  Future<AuthResponse?> login(String email, String password) async {
    try {
      Response response = await dio.post("/api/v1/auth/login", data: {
        "username": email,
        "password": password,
      });

      print(response.data);

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
}