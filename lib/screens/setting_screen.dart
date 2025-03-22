import 'package:flutter/material.dart';
import '../widgets/TaskSettingItem.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color backgroundColor = isDark ? Colors.black : Colors.white;
    Color itemBgColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    const double spacing = 20;

    TextStyle styleTitle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
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
              iconBgColor: isDark ? Colors.green.shade900 : Colors.green,
              backgroundColor: itemBgColor,
              onTap: () {},
            ),
            TaskSettingItem(
              icon: Icons.notifications,
              title: "Notifications",
              subtitle: "Manage notification settings",
              iconBgColor: isDark ? Colors.orange.shade900 : Colors.orange,
              backgroundColor: itemBgColor,
              onTap: () {},
            ),
            TaskSettingItem(
              icon: Icons.lock,
              title: "Privacy & Security",
              subtitle: "Adjust your privacy preferences",
              iconBgColor: isDark ? Colors.red.shade900 : Colors.red,
              backgroundColor: itemBgColor,
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
              iconBgColor: isDark ? Colors.blue.shade900 : Colors.blue,
              backgroundColor: itemBgColor,
              onSwitchChanged: (value) {
                themeProvider.toggleTheme(); // Cập nhật trạng thái theme
              },
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),

            TaskSettingItem(
              icon: Icons.view_agenda,
              title: "Default View",
              subtitle: "Choose your default task view",
              iconBgColor: isDark ? Colors.purple.shade900 : Colors.purple,
              backgroundColor: itemBgColor,
              onTap: () {},
            ),
            TaskSettingItem(
              icon: Icons.language,
              title: "Language",
              subtitle: "Change the app language",
              iconBgColor: isDark ? Colors.cyan.shade900 : Colors.cyan,
              backgroundColor: itemBgColor,
              onTap: () {},
            ),

            const SizedBox(height: spacing),

            Text("About", style: styleTitle),
            const SizedBox(height: 10),
            TaskSettingItem(
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "Get help with using the app",
              iconBgColor: isDark ? Colors.blueGrey.shade900 : Colors.blueGrey,
              backgroundColor: itemBgColor,
              onTap: () {},
            ),
            TaskSettingItem(
              icon: Icons.info_outline,
              title: "About TaskMaster",
              subtitle: "Version 1.0.0",
              iconBgColor: isDark ? Colors.teal.shade900 : Colors.teal,
              backgroundColor: itemBgColor,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
