import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/api_service.dart';

class TeamMemberRepository{
  final ApiService apiService;
  TeamMemberRepository(this.apiService);
  String path='/api/v1/member';
  
  Future<List<TeamMember>> getMembersByUserId(int user_id) async {
    final response = await apiService.get('$path/$user_id');
    if (response.statusCode == 200 && response.data['status']==200) {
      List<dynamic> data = response.data['data'];
      return data.map((team) => TeamMember.fromJson(team)).toList();
    } else {
      throw Exception('Lỗi khi tải thành viên nhóm');
    }
  }
  Future<List<User>> getMembersByTeamId(int team_id) async {
    final response = await apiService.get('$path/by-team/$team_id');
    if (response.statusCode == 200 && response.data['status']==200) {
      List<dynamic> data = response.data['data'];
      return data.map((team) => User.fromJson(team)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách thành viên nhóm');
    }
  }
  Future<TeamMember> getMemberByTeamAndUserId(int team_id,int user_id) async {
    final response = await apiService.get('$path/$team_id/$user_id');
    if (response.statusCode == 200 && response.data['status']==200) {
      final data = response.data['data'];
      return TeamMember.fromJson(data);
    } else {
      throw Exception('Lỗi khi tải thành viên nhóm');
    }
  }
  Future<void> createTeamMember(TeamMember reqTeamMemberDTO) async {
    final response = await apiService.post('$path', reqTeamMemberDTO.toJson());
    if (response.data['status']!=201 && response.statusCode != 200) {
      throw Exception('Lỗi khi thêm thanh viên vào nhóm');
    }
  }

  Future<void> updateMember(TeamMember reqTeamMemberDTO) async {
    final response = await apiService.put('$path',  reqTeamMemberDTO.toJson());
    if (response.statusCode != 200 || response.data['status']!=200) {
      throw Exception('Lỗi khi cập nhật thành viên nhóm');
    }
  }

  Future<void> deleteMember(int id) async {
    final response = await apiService.delete('$path/$id');
    if (response.statusCode != 200 || response.data['status']!=200) {
      throw Exception('Lỗi khi xóa thành viên nhóm');
    }
  }
  Future<void> deleteMemberAndTask(int teamId,int userId) async {
    final response = await apiService.delete('$path/tasks/$teamId/$userId');
    if (response.statusCode != 200 || response.data['status']!=200) {
      throw Exception('Lỗi khi xóa thành vien nhóm');
    }
  }
}