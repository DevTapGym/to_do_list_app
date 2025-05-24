import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class TeamMemberTile extends StatelessWidget {
  final User member;
  final bool isLeader;
  final void Function()? onRemove;

  const TeamMemberTile({
    super.key,
    required this.member,
    required this.isLeader,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Card(
      color: colors.itemBgColor,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.account_circle, color: colors.textColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name ?? 'Unknown',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.email ?? ''} | ID: ${member.id ?? ''}',
                    style: TextStyle(color: colors.subtitleColor, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (!isLeader)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}
