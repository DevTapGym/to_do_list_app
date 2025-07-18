import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/Dialog_OneTextField.dart';
import 'package:to_do_list_app/widgets/team_member_card.dart';

class GroupCreate extends StatefulWidget {
  const GroupCreate({super.key});
  @override
  State<GroupCreate> createState() => _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  final TextEditingController _nameController = TextEditingController();
  final List<TeamMember> _members = [];
  User user = getIt.get<User>();
  TeamService _teamService = getIt.get<TeamService>();
  @override
  void initState() {
    super.initState();
    _members.add(
      TeamMember(
        id: 0,
        role: Role.LEADER,
        userId: user.id,
        teamId: 0,
        user: user,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('create_team'.tr()),
        backgroundColor: colors.bgColor,
      ),
      body: Container(
        decoration: BoxDecoration(color: colors.bgColor),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(height: 50),
              TextField(
                style: TextStyle(color: colors.textColor),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'name'.tr(),
                  labelStyle: TextStyle(color: colors.textColor),
                  filled: true,
                  fillColor: colors.itemBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.textColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.textColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.textColor),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'members'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      color: colors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildAddMemberIcon(),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return TeamMemberTile(
                      member:
                          member.user ??
                          User(
                            id: -9,
                            name: 'unknown'.tr(),
                            email: 'unknown@example.com',
                            phone: '0000000000',
                          ),
                      isLeader: member.role == Role.LEADER,
                      onRemove: () {
                        setState(() {
                          _members.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _createGroup();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'create_group'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddMemberIcon() {
    final colors = AppThemeConfig.getColors(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: colors.bgColor,
        foregroundColor: colors.textColor,
        child: IconButton(
          icon: Icon(Icons.add, size: 28, color: colors.textColor),
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
        ),
      ),
    );
  }

  void _addMember(User user) {
    setState(() {
      _members.add(
        TeamMember(
          id: 0,
          role: Role.MEMBER,
          userId: user.id,
          teamId: 0,
          user: user,
        ),
      );
    });
  }

  void _createGroup() {
    final team = Team(
      id: 0,
      name: _nameController.text.trim(),
      teamMembers: _members,
    );
    Navigator.pop(context, team);
  }

  void onAddMember(String email) async {
    try {
      User user = await _teamService.getUserbyEmail(email);
      _addMember(user);
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user_with_email_not_found'.tr(args: [email]))),
      );
    }
  }
}
