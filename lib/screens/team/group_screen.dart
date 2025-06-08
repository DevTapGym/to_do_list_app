import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/bloc/Team/teamTask_bloc.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      color: colors.bgColor,
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDark
                        ? [Colors.deepPurpleAccent, Colors.deepPurple.shade700]
                        : [Colors.deepPurpleAccent.shade700, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    getIt.get<User>().name[0].toUpperCase(),
                    style: TextStyle(
                      color:
                          isDark
                              ? Colors.deepPurple.shade700
                              : Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi there, ${getIt.get<User>().name}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your groups',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Group list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<TeamBloc, TeamState>(
                builder: (context, state) {
                  if (state is TeamInitial) {
                    context.read<TeamBloc>().add(LoadTeamsByUserId(_userId));
                    return const Center(child: CircularProgressIndicator());
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

                    if (leaderGroups.isEmpty && memberGroups.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 60,
                              color: colors.subtitleColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No groups yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      children: [
                        if (leaderGroups.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                            child: Text(
                              'Leader of Teams',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...leaderGroups.map(
                            (g) => TeamWidget(
                              team: g,
                              LeaderId: _userId,
                              isLeader: true,
                              onRefresh: () {
                                context.read<TeamBloc>().add(
                                  LoadTeamsByUserId(getIt.get<User>().id),
                                );
                                getIt<TeamTaskBloc>().add(
                                  LoadTeamTasksByUserId(getIt.get<User>().id),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (memberGroups.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                            child: Text(
                              'Member of Teams',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...memberGroups.map(
                            (g) => TeamWidget(
                              team: g,
                              onRefresh: () {
                                context.read<TeamBloc>().add(
                                  LoadTeamsByUserId(getIt.get<User>().id),
                                );
                                getIt<TeamTaskBloc>().add(
                                  LoadTeamTasksByUserId(getIt.get<User>().id),
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
          ),
        ],
      ),
    );
  }
}
