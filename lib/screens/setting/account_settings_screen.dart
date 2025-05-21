import 'package:flutter/material.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.itemBgColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: colors.textColor, size: 24),
          ),
          title: Text(
            'Account Setting',
            style: TextStyle(
              color: colors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: colors.bgColor,
        // Viết tiếp phần này
        body: Container(child: ListTile()),
      ),
    );
  }
}
