import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';

class AppThemeConfig {
  static AppColors getColors(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    return isDark ? DarkColors() : LightColors();
  }
}

abstract class AppColors {
  Color get bgColor;
  Color get textColor;
  Color get itemBgColor;
  Color get subtitleColor;
  Color get primaryColor;
}

class LightColors implements AppColors {
  @override
  Color get bgColor => Colors.grey.shade300;

  @override
  Color get textColor => Colors.black;

  @override
  Color get itemBgColor => Colors.white;

  @override
  Color get subtitleColor => Colors.grey[700]!;

  @override
  Color get primaryColor => Colors.deepPurpleAccent.shade700;
}

class DarkColors implements AppColors {
  @override
  Color get bgColor => Colors.black;

  @override
  Color get textColor => Colors.white;

  @override
  Color get itemBgColor => Colors.grey.shade900;

  @override
  Color get subtitleColor => Colors.grey[400]!;

  @override
  Color get primaryColor => Colors.deepPurpleAccent;
}
