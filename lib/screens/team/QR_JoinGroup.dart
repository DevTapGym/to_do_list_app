import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class QR_JoinGroup extends StatefulWidget {
  const QR_JoinGroup({super.key});
  

  @override
  State<QR_JoinGroup> createState() => _QR_JoinGroupState();
}

class _QR_JoinGroupState extends State<QR_JoinGroup> {
  String? qrResult;
  bool isScanned = false;
  final int userId=getIt.get<User>().id;

  
  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text('QR Scanner', style: TextStyle(color: colors.textColor)),
        backgroundColor: colors.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                if (isScanned) return;
                final String? code = capture.barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    
                    int teamId = int.tryParse(code) ?? 0;
                    if (teamId == 0) {
                      Navigator.pop(context, null);
                    }
                    isScanned = true;
                    TeamMember member = TeamMember(
                      id: null,
                      role: Role.MEMBER,
                      userId: userId,
                      teamId: teamId,
                    );
                    Navigator.pop(context, member);
                  });
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                qrResult ?? 'Scan a QR code',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
