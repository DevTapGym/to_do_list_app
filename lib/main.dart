import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/bloc/auth/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_state.dart';
import 'package:to_do_list_app/bloc/task/task_bloc.dart';
import 'package:to_do_list_app/models/category.dart';
import 'package:to_do_list_app/models/group.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/screens/auth/login_screen.dart';
import 'package:to_do_list_app/screens/auth/register_screen.dart';
import 'package:to_do_list_app/screens/group/group_screen.dart';
import 'package:to_do_list_app/screens/setting/setting_screen.dart';
import 'package:to_do_list_app/screens/stats/stats_screen.dart';
import 'package:to_do_list_app/screens/task/add_task_screen.dart';
import 'package:to_do_list_app/screens/task/task_screen.dart';
import 'package:to_do_list_app/services/auth_service.dart';
import 'package:to_do_list_app/services/category_service.dart';
import 'package:to_do_list_app/services/task_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/screens/auth/otp_verification_screen.dart';
import 'package:to_do_list_app/screens/auth/forgot_passowrd_screen.dart';

void main() {
  final AuthService authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => AuthBloc(authService: authService)),
        BlocProvider(
          create:
              (context) => TaskBloc(
                taskService: TaskService(),
                categoryService: CategoryService(),
              ),
        ),
      ],
      child: MyApp(),
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
          initialRoute: '/login',

          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterScreen(),
            '/forgot-password': (context) => ForgotPasswordScreen(),
            //'/reset-password': (context) => ResetPasswordScreen(),
            '/home': (context) => const HomeScreen(),
          },

          onGenerateRoute: (settings) {
            if (settings.name == '/otp-verification') {
              final args = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder:
                    (context) =>
                        OtpVerificationScreen(email: args["email"] ?? ""),
              );
            }
            return null;
          },
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
  List<Task> taskList = [];
  List<Category> categoriesList = [];
  // fake data
  final List<Group> groups = [];
  // service
  final TaskService taskService = TaskService();
  final CategoryService categoryService = CategoryService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.authResponse != null) {
      try {
        // Load categories
        final categories = await categoryService.getCategories(
          authState.authResponse!.user.id,
        );
        setState(() {
          categoriesList = categories;
        });

        // Load tasks
        final tasks = await taskService.getTasks(
          userId: authState.authResponse!.user.id,
          dueDate: DateTime.now(),
        );
        setState(() {
          taskList = tasks;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
        setState(() {
          categoriesList = [];
          taskList = [];
        });
      }
    } else {
      // Xử lý trường hợp không có auth
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
    }
  }

  void _addTask(Task task) {
    _loadData();
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
          onTaskAdded: _addTask,
          tasks: taskList,
          categories: categoriesList,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddTaskScreen(
                              categories: categoriesList,
                              onTaskAdded: _addTask,
                            ),
                      ),
                    );
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
