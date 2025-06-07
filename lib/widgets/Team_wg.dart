import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/screens/team/group_detail.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class TeamWidget extends StatelessWidget {
  final Team team;
  final bool isLeader;
  final int LeaderId;
  final VoidCallback onRefresh;
  const TeamWidget({
    super.key,
    required this.team,
    this.LeaderId = -1,
    this.isLeader = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    final User? Leader=team.teamMembers.firstWhere((member)=> member.role==Role.LEADER).user;
    final int finalLeaderId =
        (LeaderId == Leader?.id) ? LeaderId : -1;
    return Card(
      color: colors.itemBgColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetail(team: team, LeaderId:finalLeaderId),
            ),
          );
          if (result == 'refresh') {
            onRefresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                isLeader == true ? Icons.manage_accounts : Icons.group,
                color: colors.textColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: TextStyle(
                        color: colors.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Leader?.name}',
                      style: TextStyle(color: colors.subtitleColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: colors.textColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}