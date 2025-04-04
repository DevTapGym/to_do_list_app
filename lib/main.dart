import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/bloc/auth_bloc.dart';
import 'package:to_do_list_app/screens/auth/auth_screen.dart';
import 'package:to_do_list_app/screens/celendar_screen.dart';
import 'package:to_do_list_app/screens/setting_screen.dart';
import 'package:to_do_list_app/screens/stats_screen.dart';
import 'package:to_do_list_app/screens/task_screen.dart';
import 'package:to_do_list_app/services/api_service.dart';

void main() {
  final ApiService apiService = ApiService();
  runApp(
    BlocProvider(
      create: (context) => AuthBloc(apiService: apiService),
      child: AuthScreen(),
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
  // fake data
  final List<Group> groups = List.generate(3, (groupIndex) {
    return Group(
      name: 'Group ${groupIndex + 1}',
      id: 'G${groupIndex + 1}',
      items: List.generate(3, (taskIndex) {
        return Task(
          title: 'Task ${taskIndex + 1} of Group ${groupIndex + 1}',
          description: 'Description for Task ${taskIndex + 1}',
          taskDate: DateTime.now().add(Duration(days: taskIndex)),
          category: 'Work',
          priority: 'High',
          completed: false,
          notificationTime: TimeOfDay(hour: 8, minute: 30),
          repeatDays: [1, 3, 5],
        );
      }),
    );
  });

  final List<CategoryChip> categories = [
    CategoryChip(label: 'Personal', color: Colors.red, isSelected: false),
    CategoryChip(label: 'Work', color: Colors.purple, isSelected: false),
    CategoryChip(label: 'Health', color: Colors.green, isSelected: false),
    CategoryChip(label: 'Study', color: Colors.blue, isSelected: false),
    CategoryChip(label: 'Finance', color: Colors.orange, isSelected: false),
    CategoryChip(label: 'Shopping', color: Colors.pink, isSelected: false),
  ];

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
    final List<Widget> pages = <Widget>[
      Center(
        child: TaskScreen(
          taskList: tasks,
          categories: categories,
          onTaskAdded: _addTask,
        ),
      ),
      Center(child: GroupsScreen(groups: groups)),
      Center(child: StatsScreen()),
      Center(child: SettingScreen()),
    ];

    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);

    return SafeArea(
      child: Scaffold(
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
                  onPressed: () {},
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
