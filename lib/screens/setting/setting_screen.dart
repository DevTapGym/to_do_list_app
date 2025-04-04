import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/task_setting_item.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MySetting();
  }
}

class MySetting extends StatefulWidget {
  const MySetting({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StateMySetting();
  }
}

class _StateMySetting extends State<MySetting> {
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
              margin: EdgeInsets.symmetric(vertical: 10),
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
                        isSwitchOn: isDark,
                        iconBgColor:
                            isDark ? Colors.green.shade900 : Colors.green,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),
                      TaskSettingItem(
                        icon: Icons.notifications,
                        title: "Notifications",
                        subtitle: "Manage notification settings",
                        iconBgColor:
                            isDark ? Colors.orange.shade900 : Colors.orange,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
                      ),
                      TaskSettingItem(
                        icon: Icons.lock,
                        title: "Account",
                        subtitle: "Information about your account",
                        iconBgColor: isDark ? Colors.red.shade900 : Colors.red,
                        backgroundColor: colors.itemBgColor,
                        onTap: () {},
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
                          themeProvider
                              .toggleTheme(); // Cập nhật trạng thái theme
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
