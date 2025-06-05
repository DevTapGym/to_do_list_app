import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
      validateStatus: (status) {
        return true;
      },
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No access token found');
    }
    return {'Authorization': 'Bearer $token'};
  }

  // uploadFile vẫn cần FormData vì xử lý file
  Future<String> uploadFile(Map<String, dynamic> params) async {
    final filePath = params['filePath'] as String?;
    final folder = params['folder'] as String?;

    if (filePath == null || folder == null) {
      throw Exception('Missing required parameters: filePath or folder');
    }

    final headers = await _getAuthHeaders();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'folder': folder,
    });

    try {
      final response = await dio.post(
        '/api/v1/files',
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        print(
          'File uploaded successfully: ${response.data['data']['fileName']}',
        );
        return response.data['data']['fileName'] as String;
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // updateProfile sử dụng JSON thay vì FormData
  Future<void> updateProfile(Map<String, dynamic> params) async {
    final name = params['name'] as String?;
    final phone = params['phone'] as String?;
    final avatarImagePath = params['avatarImagePath'] as String?;
    final userId = params['userId'] as int?;

    if (name == null || phone == null || userId == null) {
      throw Exception('Missing required parameters: name, phone, or userId');
    }

    final headers = await _getAuthHeaders();
    final data = {
      'name': name,
      'phone': phone,
      if (avatarImagePath != null) 'avatar': avatarImagePath,
    };

    try {
      final response = await dio.put(
        '/api/v1/user/$userId',
        data: data,
        options: Options(headers: headers, contentType: 'application/json'),
      );

      print('Update profile response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // changePassWord sử dụng JSON thay vì FormData
  Future<void> changePassWord(Map<String, dynamic> params) async {
    final userId = params['userId'] as int?;
    final newPassword = params['newPassword'] as String?;
    final oldPassword = params['oldPassword'] as String?;

    if (userId == null || newPassword == null || oldPassword == null) {
      throw Exception(
        'Missing required parameters: userId, newPassword, or oldPassword',
      );
    }

    final headers = await _getAuthHeaders();
    final data = {'oldPassword': oldPassword, 'newPassword': newPassword};

    try {
      final response = await dio.put(
        '/api/v1/user/change-password/$userId',
        data: data,
        options: Options(headers: headers, contentType: 'application/json'),
      );

      print('Change password response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
