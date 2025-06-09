import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/bloc/Team/team_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_event.dart';
import 'package:to_do_list_app/bloc/auth/auth_state.dart';
import 'package:to_do_list_app/bloc/task/task_bloc.dart';
import 'package:to_do_list_app/bloc/team/teamTask_bloc.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/category.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/screens/auth/login_screen.dart';
import 'package:to_do_list_app/screens/auth/register_screen.dart';
import 'package:to_do_list_app/screens/setting/setting_screen.dart';
import 'package:to_do_list_app/screens/stats/stats_screen.dart';
import 'package:to_do_list_app/screens/task/add_task_screen.dart';
import 'package:to_do_list_app/screens/task/task_screen.dart';
import 'package:to_do_list_app/screens/team/QR_JoinGroup.dart';
import 'package:to_do_list_app/screens/team/group_create.dart';
import 'package:to_do_list_app/screens/team/group_screen.dart';
import 'package:to_do_list_app/services/auth_service.dart';
import 'package:to_do_list_app/services/category_service.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/notification_service.dart';
import 'package:to_do_list_app/services/task_service.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/screens/auth/otp_verification_screen.dart';
import 'package:to_do_list_app/screens/auth/forgot_passowrd_screen.dart';
import 'package:to_do_list_app/widgets/to_do_card_Team.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final AuthService authService = AuthService();
  await configureDependencies();
  await getIt.allReady();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  await EasyLocalization.ensureInitialized();

  // Lấy ngôn ngữ đã lưu (tùy chọn)
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('language_code') ?? 'en';

  // Reset cờ thông báo mỗi lần chạy app
  await prefs.setBool('has_shown_notifications', false);

  if (getIt.isRegistered<TeamTaskBloc>()) getIt.unregister<TeamTaskBloc>();
  getIt.registerFactory<TeamTaskBloc>(() => TeamTaskBloc(getIt<TeamService>()));

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('vi')],
      path: 'assets/translations', // Thư mục chứa file JSON
      fallbackLocale: const Locale('en'), // Ngôn ngữ mặc định
      startLocale: Locale(savedLanguage), // Khôi phục ngôn ngữ đã lưu
      child: MultiProvider(
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
          BlocProvider(create: (_) => getIt<TeamBloc>()),
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
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'To do list app',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(), // Đặt SplashScreen làm màn hình khởi động
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterScreen(),
            '/forgot-password': (context) => ForgotPasswordScreen(),
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

// SplashScreen dùng để kiểm tra token
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkToken();
    });
  }

  Future<void> _checkToken() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');
    print('Token: $token');

    if (!mounted) {
      return;
    }

    context.read<AuthBloc>().add(VerifyTokenEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (!mounted || _hasNavigated) return;
        _hasNavigated = true;
        if (state is AuthAuthenticated && state.authResponse != null) {
          await Future.microtask(() {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          });
        } else if (state is AuthUnauthenticated || state is AuthError) {
          await Future.microtask(() {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          });
          if (state is AuthError) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                print('AuthError: ${state.message}');
              }
            });
          }
        }
      },

      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  List<Task> taskList = [];
  List<Category> categoriesList = [];
  // service
  final TaskService taskService = TaskService();
  final CategoryService categoryService = CategoryService();
  //Drawer
  late TeamBloc _teamBloc;
  late TeamTaskBloc _teamTaskBloc;
  int user_id = -99;
  final teamService = getIt.get<TeamService>();

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
        if (user_id == -99) {
          final user = authState.authResponse!.user;
          if (getIt.isRegistered<User>()) getIt.unregister<User>();
          getIt.registerSingleton<User>(user);
          user_id = user.id;
        }
        _teamBloc = context.read<TeamBloc>();
        _teamBloc.add(LoadTeamsByUserId(user_id));
        _teamTaskBloc = getIt<TeamTaskBloc>();
        _teamTaskBloc.add(LoadTeamTasksByUserId(user_id));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_load_data'.tr(args: ['$e']))),
        );
        setState(() {
          categoriesList = [];
          taskList = [];
        });
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('user_not_authenticated'.tr())));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = TaskScreen(
          onTaskAdded: _addTask,
          tasks: taskList,
          categories: categoriesList,
          scaffoldKey: _scaffoldKey,
        );
        break;
      case 1:
        body = GroupsScreen();
        break;
      case 2:
        body = StatsScreen();
        break;
      case 3:
        body = SettingScreen();
        break;
      default:
        body = TaskScreen(
          onTaskAdded: _addTask,
          tasks: taskList,
          categories: categoriesList,
          scaffoldKey: _scaffoldKey,
        );
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: body,
        drawer:
            _selectedIndex == 0
                ? CategoryDrawer(
                  onCategoryUpdated: (updatedCategories) async {
                    // Gọi lại _loadData để cập nhật cả category và task
                    await _loadData();
                  },
                )
                : _selectedIndex == 1
                ? GroupDrawer(userId: user_id)
                : null,
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box),
              label: 'tasks'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'group'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'stats'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'setting'.tr(),
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
                  onPressed: () {
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
                                title: Text('create_new_group'.tr()),
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
                                title: Text('scan_qr_to_join_group'.tr()),
                                onTap: () async {
                                  final TeamMember? result =
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QR_JoinGroup(),
                                        ),
                                      );
                                  if (result != null) {
                                    await teamService.AddTeamMemberWithQR(
                                      result,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'join_group_success'.tr(),
                                        ),
                                      ),
                                    );
                                    _teamBloc.add(LoadTeamsByUserId(user_id));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('join_group_failed'.tr()),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
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

class CategoryDrawer extends StatefulWidget {
  final Function(List<Category>) onCategoryUpdated;

  const CategoryDrawer({super.key, required this.onCategoryUpdated});

  @override
  State<CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  final CategoryService categoryService = CategoryService();
  List<Category> categories = [];

  // Danh sách tên danh mục mặc định
  static const List<String> defaultCategoryNames = [
    'Personal',
    'Work',
    'Health',
    'Study',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final fetched = await categoryService.getCategories(
          authState.authResponse!.user.id,
        );
        setState(() {
          categories = fetched;
        });
        widget.onCategoryUpdated(categories); // Notify parent
      } catch (e) {
        setState(() {
          categories = [];
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_load_data'.tr(args: ['$e']))),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('user_not_authenticated'.tr())));
      setState(() {
        categories = [];
      });
    }
  }

  void _addCategory(String name) async {
    if (name.isEmpty || defaultCategoryNames.contains(name)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('invalid_category_name'.tr())));
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final newCategory = await categoryService.createCategory(
          name: name,
          userId: authState.authResponse!.user.id,
        );
        setState(() {
          categories.add(newCategory);
        });
        widget.onCategoryUpdated(categories); // Notify parent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('category_added_successfully'.tr())),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_add_category'.tr(args: ['$e']))),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('user_not_authenticated'.tr())));
    }
  }

  void _updateCategory(int id, String newName) async {
    if (newName.isEmpty || defaultCategoryNames.contains(newName)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('invalid_category_name'.tr())));
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final updatedCategory = await categoryService.updateCategory(
          id: id,
          name: newName,
          userId: authState.authResponse!.user.id,
        );
        setState(() {
          final index = categories.indexWhere((c) => c.id == id);
          if (index != -1) {
            categories[index] = updatedCategory;
          }
        });
        widget.onCategoryUpdated(categories); // Notify parent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('category_updated_successfully'.tr())),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_update_category'.tr(args: ['$e']))),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('user_not_authenticated'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            Colors.deepPurpleAccent,
                            Colors.deepPurple.shade700,
                          ]
                          : [
                            Colors.deepPurpleAccent.shade700,
                            Colors.deepPurple,
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'manage_categories'.tr(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách danh mục
            Expanded(
              child:
                  categories.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 60,
                              color: colors.subtitleColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'no_categories_yet'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isDefault = defaultCategoryNames.contains(
                            category.name,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: isDark ? colors.itemBgColor : Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color:
                                        isDefault
                                            ? Colors.blueAccent
                                            : Colors.deepPurpleAccent.shade700,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textColor,
                                  ),
                                ),
                                trailing:
                                    isDefault
                                        ? null
                                        : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit_outlined,
                                                color: colors.subtitleColor,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    String updatedName =
                                                        category.name;
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          colors.itemBgColor,
                                                      title: Text(
                                                        'edit_category'.tr(),
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              colors.textColor,
                                                        ),
                                                      ),
                                                      content: TextField(
                                                        controller:
                                                            TextEditingController(
                                                              text:
                                                                  category.name,
                                                            ),
                                                        onChanged:
                                                            (value) =>
                                                                updatedName =
                                                                    value,
                                                        decoration: InputDecoration(
                                                          labelText:
                                                              'category_name'
                                                                  .tr(),
                                                          labelStyle: TextStyle(
                                                            color:
                                                                colors
                                                                    .subtitleColor,
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              isDark
                                                                  ? Colors
                                                                      .grey
                                                                      .shade800
                                                                  : Colors
                                                                      .grey
                                                                      .shade100,
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Colors
                                                                              .deepPurpleAccent,
                                                                      width: 2,
                                                                    ),
                                                              ),
                                                        ),
                                                        style: TextStyle(
                                                          color:
                                                              colors.textColor,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: Text(
                                                            'cancel'.tr(),
                                                            style: TextStyle(
                                                              color:
                                                                  colors
                                                                      .subtitleColor,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            _updateCategory(
                                                              category.id,
                                                              updatedName,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .deepPurpleAccent,
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'save'.tr(),
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            // Nút thêm danh mục
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 24),
                label: Text(
                  'add_category'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark
                          ? Colors.deepPurpleAccent
                          : Colors.deepPurpleAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  if (categories.length >= 7) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: colors.itemBgColor,
                            title: Text(
                              'limit_reached'.tr(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.textColor,
                              ),
                            ),
                            content: Text(
                              'category_limit'.tr(),
                              style: TextStyle(color: colors.subtitleColor),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'ok'.tr(),
                                  style: TextStyle(
                                    color: colors.subtitleColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String newCategory = '';
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: colors.itemBgColor,
                          title: Text(
                            'add_new_category'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.textColor,
                            ),
                          ),
                          content: TextField(
                            onChanged: (value) => newCategory = value,
                            decoration: InputDecoration(
                              labelText: 'category_name'.tr(),
                              labelStyle: TextStyle(
                                color: colors.subtitleColor,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.deepPurpleAccent,
                                  width: 2,
                                ),
                              ),
                              errorText:
                                  defaultCategoryNames.contains(newCategory)
                                      ? 'reserved_category_name'.tr()
                                      : null,
                            ),
                            style: TextStyle(color: colors.textColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'cancel'.tr(),
                                style: TextStyle(
                                  color: colors.subtitleColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (!defaultCategoryNames.contains(
                                  newCategory,
                                )) {
                                  _addCategory(newCategory);
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'add'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
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

class GroupDrawer extends StatelessWidget {
  final int userId;
  const GroupDrawer({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = AppThemeConfig.getColors(context);
    final isDark = themeProvider.isDarkMode;
    TeamTaskBloc teamTaskBloc = getIt<TeamTaskBloc>();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            Colors.deepPurpleAccent,
                            Colors.deepPurple.shade700,
                          ]
                          : [
                            Colors.deepPurpleAccent.shade700,
                            Colors.deepPurple,
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'manage_tasks'.tr(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách task
            Expanded(
              child: BlocBuilder<TeamTaskBloc, TeamTaskState>(
                bloc: teamTaskBloc,
                builder: (context, state) {
                  if (state is TeamTaskInitial) {
                    teamTaskBloc.add(LoadTeamTasksByUserId(userId));
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TeamTaskLoaded) {
                    return state.tasks.isEmpty
                        ? Center(
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
                                'no_tasks'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colors.subtitleColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          itemCount: state.tasks.length,
                          itemBuilder: (context, index) {
                            final task = state.tasks[index];
                            return TodoCardTeam(
                              task: task,
                              isLeader: false,
                              canEdit: true,
                              isWide: false,
                              onChanged: () {
                                teamTaskBloc.add(LoadTeamTasksByUserId(userId));
                              },
                            );
                          },
                        );
                  } else if (state is TeamTaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Center(
                      child: Text(
                        'failed_to_load_tasks'.tr(),
                        style: TextStyle(color: colors.subtitleColor),
                      ),
                    );
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
