import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/screens/setting/account_settings_screen.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/task_setting_item.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _showCompletedTasks = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCompletedTasks = prefs.getBool('show_completed_tasks') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveShowCompletedTasks(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_completed_tasks', value);
  }

  Future<void> _saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<bool> _showNotificationDisableDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Disable Notifications?'),
                content: const Text(
                  'Disabling notifications may lead to a poor app experience.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Agree'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);
    const double spacing = 20;

    TextStyle styleTitle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: colors.textColor,
    );

    return Container(
      decoration: BoxDecoration(color: colors.bgColor),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Setting',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Task Settings", style: styleTitle),
                      const SizedBox(height: 10),

                      TaskSettingItem(
                        icon: Icons.remove_red_eye,
                        title: "Show Completed Tasks",
                        subtitle: "Display completed tasks in your task list",
                        hasSwitch: true,
                        isSwitchOn: _showCompletedTasks,
                        iconBgColor:
                            isDark ? Colors.green.shade900 : Colors.green,
                        backgroundColor: colors.itemBgColor,
                        onSwitchChanged: (value) {
                          setState(() {
                            _showCompletedTasks = value;
                            _saveShowCompletedTasks(value);
                          });
                        },
                        onTap: () {
                          setState(() {
                            _showCompletedTasks = !_showCompletedTasks;
                            _saveShowCompletedTasks(_showCompletedTasks);
                          });
                        },
                      ),
                      TaskSettingItem(
                        icon: Icons.notifications,
                        title: "Notifications",
                        subtitle: "Enable or disable notifications",
                        hasSwitch: true,
                        isSwitchOn: _notificationsEnabled,
                        iconBgColor:
                            isDark ? Colors.orange.shade900 : Colors.orange,
                        backgroundColor: colors.itemBgColor,
                        onSwitchChanged: (value) async {
                          if (!value) {
                            final agreed =
                                await _showNotificationDisableDialog();
                            if (agreed) {
                              setState(() {
                                _notificationsEnabled = value;
                                _saveNotificationsEnabled(value);
                              });
                            }
                          } else {
                            setState(() {
                              _notificationsEnabled = value;
                              _saveNotificationsEnabled(value);
                            });
                          }
                        },
                        onTap: () async {
                          final newValue = !_notificationsEnabled;
                          if (!newValue) {
                            final agreed =
                                await _showNotificationDisableDialog();
                            if (agreed) {
                              setState(() {
                                _notificationsEnabled = newValue;
                                _saveNotificationsEnabled(newValue);
                              });
                            }
                          } else {
                            setState(() {
                              _notificationsEnabled = newValue;
                              _saveNotificationsEnabled(newValue);
                            });
                          }
                        },
                      ),
                      TaskSettingItem(
                        icon: Icons.lock,
                        title: "Account",
                        subtitle: "Information about your account",
                        iconBgColor: isDark ? Colors.red.shade900 : Colors.red,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: spacing),

                      Text("Display", style: styleTitle),
                      const SizedBox(height: 10),

                      TaskSettingItem(
                        icon: Icons.nightlight_round,
                        title: "Dark Mode",
                        subtitle: "Enable dark theme for the app",
                        hasSwitch: true,
                        isSwitchOn: isDark,
                        iconBgColor:
                            isDark ? Colors.blue.shade900 : Colors.blue,
                        backgroundColor: colors.itemBgColor,
                        onSwitchChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        onTap: () {
                          themeProvider.toggleTheme();
                        },
                      ),

                      TaskSettingItem(
                        icon: Icons.view_agenda,
                        title: "Default View",
                        subtitle: "Choose your default task view",
                        iconBgColor:
                            isDark ? Colors.purple.shade900 : Colors.purple,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),
                      TaskSettingItem(
                        icon: Icons.language,
                        title: "Language",
                        subtitle: "Change the app language",
                        iconBgColor:
                            isDark ? Colors.cyan.shade900 : Colors.cyan,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),

                      const SizedBox(height: spacing),

                      Text("About", style: styleTitle),
                      const SizedBox(height: 10),
                      TaskSettingItem(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        subtitle: "Get help with using the app",
                        iconBgColor:
                            isDark ? Colors.blueGrey.shade900 : Colors.blueGrey,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),
                      TaskSettingItem(
                        icon: Icons.info_outline,
                        title: "About TaskMaster",
                        subtitle: "Version 1.0.0",
                        iconBgColor:
                            isDark ? Colors.teal.shade900 : Colors.teal,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
