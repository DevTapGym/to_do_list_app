import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/services/auth_service.dart';

class UserRepository {
  final AuthService apiService;
  UserRepository(this.apiService);
  String path = '/api/v1';

  Future<User> getUserbyEmail(String Email) async {
    final response = await apiService.get('$path/$Email');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      return User.fromJson(data);
    } else {
      throw Exception('Lỗi khi tải người dùng email: $Email');
    }
  }
}
