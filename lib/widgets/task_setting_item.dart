import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class TaskSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool hasSwitch;
  final bool isSwitchOn;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback onTap;
  final Color iconBgColor;
  final Color backgroundColor;

  const TaskSettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hasSwitch = false,
    this.isSwitchOn = false,
    this.onSwitchChanged,
    this.iconBgColor = Colors.blue,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                ],
              ),
            ),
            hasSwitch
                ? Switch(value: isSwitchOn, onChanged: onSwitchChanged)
                : const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
          ],
        ),
      ),
    );
  }
}
