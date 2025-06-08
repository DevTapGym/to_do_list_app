import 'package:easy_localization/easy_localization.dart';
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
                title: Text('disableNotificationsTitle'.tr()),
                content: Text('disableNotificationsContent'.tr()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('cancel'.tr()),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('agree'.tr()),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    print('Changing language to: ${locale.languageCode}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await context.setLocale(locale);
    print('Current locale: ${context.locale}');
  }

  Future<void> _showLanguageDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('selectLanguage'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('english'.tr()),
                  onTap: () {
                    _changeLanguage(context, const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('vietnamese'.tr()),
                  onTap: () {
                    _changeLanguage(context, const Locale('vi'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
            ],
          ),
    );
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
                'settings'.tr(),
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
                      Text('taskSettings'.tr(), style: styleTitle),
                      const SizedBox(height: 10),
                      TaskSettingItem(
                        icon: Icons.remove_red_eye,
                        title: 'showCompletedTasks'.tr(),
                        subtitle: 'showCompletedTasksSubtitle'.tr(),
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
                        title: 'notifications'.tr(),
                        subtitle: 'notificationsSubtitle'.tr(),
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
                        title: 'account'.tr(),
                        subtitle: 'accountSubtitle'.tr(),
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
                      Text('display'.tr(), style: styleTitle),
                      const SizedBox(height: 10),
                      TaskSettingItem(
                        icon: Icons.nightlight_round,
                        title: 'darkMode'.tr(),
                        subtitle: 'darkModeSubtitle'.tr(),
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
                        title: 'defaultView'.tr(),
                        subtitle: 'defaultViewSubtitle'.tr(),
                        iconBgColor:
                            isDark ? Colors.purple.shade900 : Colors.purple,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),
                      TaskSettingItem(
                        icon: Icons.language,
                        title: 'language'.tr(),
                        subtitle: 'languageSubtitle'.tr(),
                        iconBgColor:
                            isDark ? Colors.cyan.shade900 : Colors.cyan,
                        backgroundColor: colors.itemBgColor,
                        onTap: _showLanguageDialog,
                      ),
                      const SizedBox(height: spacing),
                      Text('about'.tr(), style: styleTitle),
                      const SizedBox(height: 10),
                      TaskSettingItem(
                        icon: Icons.help_outline,
                        title: 'helpSupport'.tr(),
                        subtitle: 'helpSupportSubtitle'.tr(),
                        iconBgColor:
                            isDark ? Colors.blueGrey.shade900 : Colors.blueGrey,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),
                      TaskSettingItem(
                        icon: Icons.info_outline,
                        title: 'aboutTaskMaster'.tr(),
                        subtitle: 'aboutTaskMasterSubtitle'.tr(),
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
