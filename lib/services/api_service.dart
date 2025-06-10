import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/models/register_response.dart';
import '../models/auth_response.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
      validateStatus: (status) {
        return status! < 500; // Chỉ ném ngoại lệ khi lỗi server (500+)
      },
    ),
  );

  Future<AuthResponse?> login(String email, String password) async {
    try {
      Response response = await dio.post(
        "/api/v1/auth/login",
        data: {"username": email, "password": password},
      );

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

  Future<RegisterResponse?> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    print(
      "Dữ liệu gửi đi: name=$name, email=$email, password=$password, phone=$phone",
    );
    try {
      Response response = await dio.post(
        "/api/v1/auth/register",
        data: {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
        },
      );

      print("response data >>>" + response.data.toString());
      print("response >>" + response.toString());

      if (response.data["status"] == 200) {
        final data = response.data["data"];
        RegisterResponse registerResponse = RegisterResponse.fromJson(data);

        print("Đăng ký thành công!");
        return registerResponse;
      }
    } catch (e) {
      print("Lỗi đăng ký: $e");
    }
    return null;
  }

  Future<String?> checkCode(
      String email,
      String code,
      ) async {
    print(
      "Dữ liệu gửi đi:  email=$email, code=$code",
    );
    try {
      Response response = await dio.post(
        "/api/v1/auth/check-code",
        data: {
          "email": email,
          "code": code,
        },
      );

      print("response data >>>" + response.data.toString());
      print("response >>" + response.toString());

      if (response.data["status"] == 200) {
        final data = response.data["data"];
        String res =  data;

        print("Verify thành công!");
        return res;
      }
    } catch (e) {
      print("Lỗi Verify: $e");
    }
    return null;
  }


}
