import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/models/task.dart';

class TaskService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
      validateStatus: (status) {
        return true;
      },
    ),
  );

  Future<List<Task>> getTasks({required int userId, DateTime? dueDate}) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception('No access token found');
    }

    String url = '/api/v1/task/$userId';
    if (dueDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
      url += '?dueDate=$formattedDate';
    }

    final response = await dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<Task> getTaskById(int taskId) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await dio.get(
      '/api/v1/task/byId/$taskId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load task: ${response.statusCode}');
    }
  }

  Future<bool> addTask(Task task) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await dio.post(
      '/api/v1/task',
      data: task.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await dio.put(
      '/api/v1/task',
      data: task.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await dio.delete(
      '/api/v1/task/$taskId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
