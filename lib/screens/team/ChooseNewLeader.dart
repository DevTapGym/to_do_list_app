import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class ChooseNewLeaderScreen extends StatefulWidget {
  final Team team;
  final User currentUser;
  final AppColors colors;

  const ChooseNewLeaderScreen({
    super.key,
    required this.team,
    required this.currentUser,
    required this.colors,
  });

  @override
  State<ChooseNewLeaderScreen> createState() => _ChooseNewLeaderScreenState();
}

class _ChooseNewLeaderScreenState extends State<ChooseNewLeaderScreen> {
  TeamMember? _selectedNewLeader;
  late List<TeamMember> _eligibleMembers;

  @override
  void initState() {
    super.initState();
    _eligibleMembers =
        widget.team.teamMembers
            .where((member) => member.userId != widget.currentUser.id)
            .toList();

    if (_eligibleMembers.isNotEmpty) {
      _selectedNewLeader = _eligibleMembers.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'choose_new_leader'.tr(),
          style: TextStyle(color: widget.colors.textColor),
        ),
        backgroundColor: widget.colors.bgColor,
        iconTheme: IconThemeData(color: widget.colors.textColor),
      ),
      backgroundColor: widget.colors.bgColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _eligibleMembers.isEmpty
                ? Text(
                  'no_other_members_available'.tr(),
                  style: TextStyle(color: widget.colors.textColor),
                )
                : DropdownButtonFormField<TeamMember>(
                  value: _selectedNewLeader,
                  dropdownColor: widget.colors.bgColor,
                  style: TextStyle(color: widget.colors.textColor),
                  decoration: InputDecoration(
                    labelText: 'choose_new_leader'.tr(),
                    labelStyle: TextStyle(color: widget.colors.subtitleColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: widget.colors.itemBgColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: widget.colors.itemBgColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: widget.colors.itemBgColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  items:
                      _eligibleMembers.map((member) {
                        return DropdownMenuItem<TeamMember>(
                          value: member,
                          child: Text(
                            member.user?.name ?? 'unknown'.tr(),
                            style: TextStyle(color: widget.colors.textColor),
                          ),
                        );
                      }).toList(),
                  onChanged: (TeamMember? newMember) {
                    setState(() {
                      _selectedNewLeader = newMember;
                    });
                  },
                ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'cancel'.tr(),
                      style: TextStyle(color: widget.colors.textColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed:
                        _selectedNewLeader == null
                            ? null
                            : () {
                              Navigator.of(
                                context,
                              ).pop(_selectedNewLeader!.userId);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.colors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'confirm'.tr(),
                      style: TextStyle(
                        color:
                            _selectedNewLeader == null
                                ? widget.colors.subtitleColor
                                : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
