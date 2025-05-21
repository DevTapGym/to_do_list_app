import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/Repositories/Team/teamTaskRepository.dart';
import 'package:to_do_list_app/bloc/Team/teamTask_bloc.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/screens/team/group_QR_Share.dart';
import 'package:to_do_list_app/screens/team/group_create_task.dart';
import 'package:to_do_list_app/screens/team/group_listMember.dart';
import 'package:to_do_list_app/services/api_service.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/Dialog_Confirmation.dart';
import 'package:to_do_list_app/widgets/Dialog_OneTextField.dart';
import 'package:to_do_list_app/widgets/to_do_card_Team.dart';

class GroupDetail extends StatefulWidget {
  int? LeaderId;
  bool isLeader = false;

  final Team team;
  GroupDetail({super.key, required this.team, this.LeaderId});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  TeamTaskBloc teamTaskBloc = getIt<TeamTaskBloc>();
  TeamService teamService = getIt.get<TeamService>();
  User user = getIt.get<User>();
  late TeamMember? teamMember;

  @override
  void initState() {
    super.initState();
    if (widget.LeaderId == -1) {
      var Leader = widget.team.teamMembers.where(
        (member) => member.role == Role.LEADER,
      );
      if (Leader.isNotEmpty) {
        widget.LeaderId = Leader.first.userId;
      }
    }
    widget.isLeader = widget.LeaderId == user.id;
    teamMember = widget.team.teamMembers.firstWhere(
      (member) => member.userId == user.id,
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.team.name,
          style: TextStyle(color: colors.textColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop('refresh'),
        ),
        backgroundColor: colors.bgColor,
        iconTheme: IconThemeData(color: colors.textColor),
        actions: [
          Row(
            children: [
              // Nút Member
              IconButton(
                icon: Icon(Icons.group, color: colors.textColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GroupListmember(
                            team: widget.team,
                            LeaderId: widget.LeaderId!,
                          ),
                    ),
                  );
                },
              ),
              // Nút Setting
              widget.isLeader
                  ? PopupMenuButton<String>(
                    icon: Icon(Icons.settings, color: colors.textColor),
                    color: colors.bgColor,
                    onSelected: (value) {
                      if (value == 'Rename') {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return OneTextFieldDialog(
                              title: 'Rename Team',
                              hintText: 'Enter new name',
                              buttonText: 'Change',
                              cancelText: 'Cancel',
                              onFunction: onRename,
                              colors: colors,
                            );
                          },
                        );
                      } else if (value == 'Disband') {
                        _showConfirmationDisbandDialog(widget.team);
                      } else if (value == 'Share') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRPage(team: widget.team),
                          ),
                        );
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'Share',
                            child: Text('Chia sẻ nhóm'),
                          ),
                          const PopupMenuItem(
                            value: 'Rename',
                            child: Text('Đổi tên'),
                          ),
                          const PopupMenuItem(
                            value: 'Disband',
                            child: Text('Giải tán nhóm'),
                          ),
                        ],
                  )
                  : PopupMenuButton<String>(
                    icon: Icon(Icons.settings, color: colors.textColor),
                    color: colors.bgColor,
                    onSelected: (value) {
                      if (value == 'Leave') {
                        _showConfirmationLeaveDialog(widget.team);
                      } else if (value == 'Share') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRPage(team: widget.team),
                          ),
                        );
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'Share',
                            child: Text('Chia sẻ nhóm'),
                          ),
                          const PopupMenuItem(
                            value: 'Leave',
                            child: Text('Rời nhóm'),
                          ),
                        ],
                  ),
            ],
          ),
        ],
      ),
      body: Container(
        color: colors.bgColor,
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<TeamTaskBloc, TeamTaskState>(
                  bloc: teamTaskBloc,
                  builder: (context, state) {
                    if (state is TeamTaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TeamTaskLoaded) {
                      final tasks = state.tasks;

                      final myTasks =
                          tasks
                              .where((t) => t.teamMemberId == teamMember?.id)
                              .toList();
                      final otherTasks =
                          tasks
                              .where((t) => t.teamMemberId != teamMember?.id)
                              .toList();

                      sortTasks(myTasks);
                      sortTasks(otherTasks);
                      return ListView(
                        children: [
                          if (myTasks.isNotEmpty) ...[
                            Text(
                              'Your tasks',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...myTasks.map(
                              (g) => TodoCardTeam(
                                task: g,
                                onChanged: onChanged,
                                canEdit:
                                    widget.isLeader ||
                                    g.teamMemberId == teamMember?.id,
                                isLeader: widget.isLeader,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (otherTasks.isNotEmpty) ...[
                            Text(
                              'Other tasks',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...otherTasks.map(
                              (g) => TodoCardTeam(
                                task: g,
                                onChanged: onChanged,
                                canEdit:
                                    widget.isLeader ||
                                    g.teamMemberId == teamMember?.id,
                                isLeader: widget.isLeader,
                              ),
                            ),
                          ],
                        ],
                      );
                    } else {
                      return const Center(child: Text('No data available'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          widget.isLeader
              ? FloatingActionButton(
                backgroundColor: colors.primaryColor,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCreateTask(team: widget.team),
                    ),
                  );
                  if (result == 'refresh') {
                    onChanged();
                  }
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  void onChanged() {
    setState(() {
      teamTaskBloc.add(LoadTeamTasksByTeamId(widget.team.id));
    });
  }

  void sortTasks(List list) {
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return a.priority.index.compareTo(b.priority.index);
      }
      return a.deadline.compareTo(b.deadline);
    });
  }

  

  void onDisband(int teamId) async {
    await teamService.DisbandTeam(teamId);
    Navigator.of(context).pop('refresh');
  }

  void _showConfirmationDisbandDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Confirmation',
          content: 'Are you sure you want to disband team "${team.name}"?',
          confirmText: 'Confirm',
          cancelText: 'Cancel',
          onConfirm: ()=>onDisband(team.id),
        );
      },
    );
  }

  void onLeave(int teamId, int userId) async {
    await teamService.DeleteMember(teamId, userId);
    Navigator.of(context).pop('refresh');
  }

  void onRename(String newname) async {
    await teamService.ChangeTeamName(widget.team.id, newname);
    setState(() {
      widget.team.name = newname;
      Navigator.of(context).pop();
    });
  }

  void _showConfirmationLeaveDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Confirmation',
          content: 'Are you sure you want to leave team "${team.name}"?',
          confirmText: 'Confirm',
          cancelText: 'Cancel',
          onConfirm: ()=>onLeave(team.id, user.id),
        );
      },
    );
  }
}
