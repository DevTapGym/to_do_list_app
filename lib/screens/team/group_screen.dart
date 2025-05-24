import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/bloc/Team/team_bloc.dart';
import 'package:to_do_list_app/widgets/Team_wg.dart';

class GroupsScreen extends StatefulWidget {
  GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final int _userId = getIt.get<User>().id;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Container(
      color: colors.bgColor,
      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Builder(
                  builder:
                      (context) => IconButton(
                        icon: Icon(Icons.menu, color: colors.textColor),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi there,',
                      style: TextStyle(fontSize: 16, color: colors.textColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your groups',
                      style: TextStyle(
                        fontSize: 26,
                        color: colors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<TeamBloc, TeamState>(
                builder: (context, state) {
                  if (state is TeamInitial) {
                    context.read<TeamBloc>().add(LoadTeamsByUserId(_userId));
                    return Center(child: CircularProgressIndicator());
                  } else if (state is TeamLoaded) {
                    final groups = state.teams;

                    final leaderGroups =
                        groups
                            .where(
                              (g) => g.teamMembers.any(
                                (m) =>
                                    m.userId == _userId &&
                                    m.role == Role.LEADER,
                              ),
                            )
                            .toList();

                    final memberGroups =
                        groups
                            .where(
                              (g) => g.teamMembers.any(
                                (m) =>
                                    m.userId == _userId &&
                                    m.role != Role.LEADER,
                              ),
                            )
                            .toList();

                    return ListView(
                      children: [
                        if (leaderGroups.isNotEmpty) ...[
                          Text(
                            'Leader of Teams',
                            style: TextStyle(
                              color: colors.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...leaderGroups.map(
                            (g) => TeamWidget(
                              team: g,
                              LeaderId: _userId,
                              isLeader: true,
                              onRefresh: () {
                                context.read<TeamBloc>().add(
                                  LoadTeamsByUserId(getIt.get<User>().id),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (memberGroups.isNotEmpty) ...[
                          Text(
                            'Member of Teams',
                            style: TextStyle(
                              color: colors.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...memberGroups.map(
                            (g) => TeamWidget(
                              team: g,
                              onRefresh: () {
                                context.read<TeamBloc>().add(
                                  LoadTeamsByUserId(getIt.get<User>().id),
                                );
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
    );
  }
}
