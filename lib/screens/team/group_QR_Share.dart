import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class QRPage extends StatelessWidget {
  final Team team;
  QRPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      backgroundColor: colors.primaryColor,
      appBar: AppBar(title: Text("Team ${team.name}", style: TextStyle(color: colors.textColor))),
      body: Center(
        
        child: QrImageView(
          backgroundColor: Colors.white,
          data: team.id.toString(),
          version: QrVersions.auto,
          size: 220.0,
        ),
      ),
    );
  }
}
