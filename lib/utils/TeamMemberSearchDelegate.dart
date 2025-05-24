import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/widgets/team_member_card.dart';

class TeamMemberSearchDelegate extends SearchDelegate<User> {
  final List<User> members;
  final bool isLeader;
  final Function(User) onRemove;
  final int leaderId;

  TeamMemberSearchDelegate({
    required this.members,
    required this.isLeader,
    required this.onRemove,
    required this.leaderId,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        members
            .where(
              (member) =>
                  member.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView(
      children:
          results.map((member) {
            return TeamMemberTile(
              member: member,
              isLeader: member.id == leaderId,
              onRemove: () {
                if (member.id != leaderId) {
                  onRemove(member);
                }
              },
            );
          }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
