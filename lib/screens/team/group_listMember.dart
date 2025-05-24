import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/Repositories/UserRepository.dart';
import 'package:to_do_list_app/bloc/Team/teamMember_bloc.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/TeamMemberSearchDelegate.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/Dialog_Confirmation.dart';
import 'package:to_do_list_app/widgets/Dialog_OneTextField.dart';
import 'package:to_do_list_app/widgets/team_member_card.dart';

class GroupListmember extends StatefulWidget {
  final int LeaderId;
  bool isLeader = false;

  final Team team;
  GroupListmember({super.key, required this.team, required this.LeaderId});

  @override
  State<GroupListmember> createState() => _GroupListmemberState();
}

class _GroupListmemberState extends State<GroupListmember> {
  TeamMemberBloc teamMemberBloc = getIt<TeamMemberBloc>();
  TeamService teamService = getIt.get<TeamService>();

  final _userRepository = getIt.get<UserRepository>();
  final int _userId = getIt.get<User>().id;

  @override
  void initState() {
    super.initState();
    widget.isLeader = widget.LeaderId == _userId;
    teamMemberBloc.add(LoadTeamMembersByTeamId(widget.team.id));
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
        backgroundColor: colors.bgColor,
        iconTheme: IconThemeData(color: colors.textColor),
        leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.of(context).pop('refresh');
    },
  ),
        actions: [
          Row(
            children: [
              widget.isLeader
                  ? IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return OneTextFieldDialog(
                            onFunction: onAddMember,
                            colors: colors,
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.add, color: colors.textColor),
                  )
                  : Container(),
              IconButton(
                icon: Icon(Icons.search, color: colors.textColor),
                onPressed: () async {
                  if (teamMemberBloc.state is TeamMemberLoaded) {
                    final state = teamMemberBloc.state as TeamMemberLoaded;
                    final allMembers = state.members;

                    showSearch(
                      context: context,
                      delegate: TeamMemberSearchDelegate(
                        members: allMembers,
                        isLeader: widget.isLeader,
                        leaderId: widget.LeaderId,
                        onRemove: (user) => _showConfirmationDialog(user),
                      ),
                    );
                  }
                },
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
                child: BlocBuilder<TeamMemberBloc, TeamMemberState>(
                  bloc: teamMemberBloc,
                  builder: (context, state) {
                    if (state is TeamMemberLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TeamMemberLoaded) {
                      final members = state.members;
                      final leaderMember =
                          members
                              .where((m) => m.id == widget.LeaderId)
                              .toList();
                      final normalMembers =
                          members
                              .where((m) => m.id != widget.LeaderId)
                              .toList();
                      return ListView(
                        children: [
                          if (leaderMember.isNotEmpty) ...[
                            Text(
                              'Leader',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...leaderMember.map(
                              (member) => TeamMemberTile(
                                member: member,
                                isLeader: true,
                                onRemove: () {},
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (normalMembers.isNotEmpty) ...[
                            Text(
                              'Members',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...normalMembers.map(
                              (member) => TeamMemberTile(
                                member: member,
                                isLeader: false || !widget.isLeader,
                                onRemove: () {
                                  _showConfirmationDialog(member);
                                },
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
    );
  }

  void onAddMember(String email) async {
    try {
      User user = await _userRepository.getUserbyEmail(email);
      if (user != null) {
        await teamService.AddTeamMember(widget.team.id, user.id);
        Navigator.of(context).pop();
        teamMemberBloc.add(LoadTeamMembersByTeamId(widget.team.id));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không tìm thấy người dùng với email: $email"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
    }
  }

  void onRemoveMember(User user) async {
    await teamService.DeleteMember(widget.team.id, user.id);
    teamMemberBloc.add(LoadTeamMembersByTeamId(widget.team.id));
  }

  void _showConfirmationDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Confirmation',
          content: 'Are you sure you want to delete member "${user.name}"?',
          confirmText: 'Confirm',
          cancelText: 'Cancel',
          onConfirm: () => onRemoveMember(user),
        );
      },
    );
  }
}
