import 'package:intl/intl.dart';
import 'package:to_do_list_app/models/auth_response.dart';

enum Role { LEADER, MEMBER }

enum Priority { HIGH, MEDIUM, LOW }

class Team {
  int id;
  String name;
  List<TeamMember> teamMembers;

  Team({required this.id, required this.name, required this.teamMembers});

  factory Team.fromJson(Map<String, dynamic> json) {
    var memberList = json['teamMembers'] as List?;
    List<TeamMember> members =
        memberList != null
            ? memberList
                .map((i) => TeamMember.fromJson(i as Map<String, dynamic>))
                .toList()
            : [];

    return Team(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      teamMembers: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teamMembers': teamMembers.map((m) => m.toJson()).toList(),
    };
  }
}

class TeamMember {
  int? id;
  Role role;
  int userId;
  int teamId;
  User? user;
  TeamMember({
    required this.id,
    required this.role,
    required this.userId,
    required this.teamId,
    this.user,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    Role memberRole = Role.values.firstWhere(
      (e) => e.toString().split('.').last == json['role'],
      orElse: () => Role.MEMBER,
    );
    User? user;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      user = User.fromJson(json['user'] as Map<String, dynamic>);
    }
    return TeamMember(
      id: json['id'] as int,
      role: memberRole,
      userId: json['userId'] as int? ?? json['user']?['id'] as int? ?? 0,
      teamId: json['teamId'] as int? ?? json['team']?['id'] as int? ?? 0,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toString().split('.').last,
      'userId': userId,
      'teamId': teamId,
      'user': user?.toJson(),
    };
  }
}

class TeamTask {
  int? id;
  String title;
  String? description;
  DateTime deadline;
  Priority priority;
  bool isCompleted;
  int teamMemberId;
  User? user;
  TeamTask({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.priority,
    required this.isCompleted,
    required this.teamMemberId,
    this.user,
  });
  factory TeamTask.fromJson(Map<String, dynamic> json) {
    Priority taskPriority = Priority.values.firstWhere(
      (e) => e.toString().split('.').last == json['priority'],
      orElse: () => Priority.LOW,
    );

    DateTime taskDeadline;
    try {
      taskDeadline = DateTime.parse(json['deadline'] as String);
    } catch (e) {
      try {
        taskDeadline = DateFormat(
          "dd/MM/yyyy HH:mm",
        ).parse(json['deadline'] as String);
      } catch (e2) {
        print("Error parsing date in both formats: ${json['deadline']} - $e2");
        taskDeadline = DateTime.now();
      }
    }

    return TeamTask(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String?,
      deadline: taskDeadline,
      priority: taskPriority,
      isCompleted: json['completed'] as bool? ?? false,
      teamMemberId:
          json['teamMemberId'] as int? ??
          json['teamMember']?['id'] as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    String formattedDeadline = DateFormat("dd/MM/yyyy HH:mm").format(deadline);

    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': formattedDeadline,
      'priority': priority.toString().split('.').last,
      'completed': isCompleted,
      'teamMemberId': teamMemberId,
    };
  }
}
