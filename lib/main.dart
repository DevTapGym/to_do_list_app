import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/Repositories/UserRepository.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/screens/team/group_detail.dart';
import 'package:to_do_list_app/screens/team/group_screen.dart';
import 'package:to_do_list_app/screens/setting/setting_screen.dart';
import 'package:to_do_list_app/screens/stats/stats_screen.dart';
import 'package:to_do_list_app/screens/task/add_task_screen.dart';
import 'package:to_do_list_app/screens/task/task_screen.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';
import 'package:to_do_list_app/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/bloc/auth_bloc.dart';
import 'package:to_do_list_app/screens/auth/auth_screen.dart';
import 'package:to_do_list_app/screens/team/group_create.dart';
import 'package:to_do_list_app/screens/team/QR_JoinGroup.dart';
import 'package:to_do_list_app/bloc/Team/team_bloc.dart';
import 'package:to_do_list_app/Repositories/Team/teamRepository.dart';
import 'package:to_do_list_app/Repositories/Team/teamMemberRepository.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/services/injections.dart';

void main() async {
  await configureDependencies();
  await getIt.allReady();
  final ApiService apiService = getIt.get<ApiService>();
  final TeamBloc teamBloc = getIt.get<TeamBloc>();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(apiService: apiService),
          ),
          BlocProvider<TeamBloc>(create: (_) => teamBloc),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'To do list app',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Task> tasks = [];
  int user_id = getIt.get<User>().id;
  late TeamBloc _teamBloc;
  final teamService = getIt.get<TeamService>();
  final List<CategoryChip> categories = [
    CategoryChip(label: 'Personal', color: Colors.red, isSelected: false),
    CategoryChip(label: 'Work', color: Colors.purple, isSelected: false),
    CategoryChip(label: 'Health', color: Colors.green, isSelected: false),
    CategoryChip(label: 'Study', color: Colors.blue, isSelected: false),
    CategoryChip(label: 'Finance', color: Colors.orange, isSelected: false),
    CategoryChip(label: 'Shopping', color: Colors.pink, isSelected: false),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _teamBloc = context.read<TeamBloc>();
    _teamBloc.add(LoadTeamsByUserId(user_id));
    final List<Widget> pages = <Widget>[
      Center(
        child: TaskScreen(
          taskList: tasks,
          categories: categories,
          onTaskAdded: _addTask,
        ),
      ),
      GroupsScreen(),
      Center(child: StatsScreen()),
      Center(child: SettingScreen()),
    ];

    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);

    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child:
              _selectedIndex == 1
                  ? BlocBuilder<TeamBloc, TeamState>(
                    bloc: _teamBloc,
                    builder: (context, state) {
                      if (state is TeamLoaded) {
                        return ListView(
                          children: [
                            const DrawerHeader(
                              child: Text(
                                'Your groups',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            ...state.teams.map(
                              (team) => ListTile(
                                title: Text(team.name),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => GroupDetail(
                                            team: team,
                                            LeaderId: -1,
                                          ),
                                    ),
                                  );

                                  if (result == 'refresh') {
                                    context.read<TeamBloc>().add(
                                      LoadTeamsByUserId(user_id),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                  : const Center(child: Text('No groups available')),
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Group'),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
          backgroundColor: colors.itemBgColor,
          currentIndex: _selectedIndex,
          selectedItemColor:
              isDark
                  ? Colors.deepPurpleAccent
                  : Colors.deepPurpleAccent.shade700,
          unselectedItemColor: colors.textColor,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
        floatingActionButton:
            _selectedIndex == 0
                ? FloatingActionButton(
                  onPressed: () async {
                    final newTask = await Navigator.push<Task>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddTaskScreen(
                              onTaskAdded: _addTask,
                              categories: categories,
                            ),
                      ),
                    );

                    if (newTask != null) {
                      _addTask(newTask);
                    }
                  },
                  backgroundColor:
                      isDark
                          ? Colors.deepPurpleAccent
                          : Colors.deepPurpleAccent.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                )
                : _selectedIndex == 1
                ? FloatingActionButton(
                  onPressed: () {
                    if (_selectedIndex == 1) {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder:
                            (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.group_add),
                                  title: const Text('Tạo nhóm mới'),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupCreate(),
                                      ),
                                    );
                                    if (result is Team) {
                                      await teamService.createTeamWithMembers(
                                        result,
                                        user_id,
                                      
                                      );
                                      _teamBloc.add(LoadTeamsByUserId(user_id));
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.qr_code_scanner),
                                  title: const Text('Quét mã QR để vào nhóm'),
                                  onTap: () async {
                                    final TeamMember? result =
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => QR_JoinGroup(),
                                          ),
                                        );
                                    if (result != null &&
                                        result is TeamMember) {
                                      await teamService.AddTeamMemberWithQR(
                                        result,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Tham gia nhóm thành công',
                                          ),
                                        ),
                                      );
                                      _teamBloc.add(LoadTeamsByUserId(user_id));
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Khong thể tham gia nhóm',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  backgroundColor:
                      isDark
                          ? Colors.deepPurpleAccent
                          : Colors.deepPurpleAccent.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.group_add,
                    color: Colors.white,
                    size: 32,
                  ),
                )
                : null,
      ),
    );
  }
}
