import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
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
  String? qrResultText;
  bool isProcessing = false;
  final int userId = getIt.get<User>().id;

  final MobileScannerController scannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _handleScannedCode(String? code) {
    if (isProcessing) return;

    if (code != null && code.startsWith("TODOLIST-")) {
      code = code.replaceAll("TODOLIST-", "");
      int teamId = int.tryParse(code) ?? 0;

      if (teamId == 0) {
        if (mounted) {
          setState(() {
            qrResultText = 'invalid_qr_not_team_id'.tr();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('scanned_qr_not_valid_team_id'.tr())),
          );
        }

        return;
      }

      if (mounted) {
        setState(() {
          isProcessing = true;
          qrResultText = 'team_id_found_joining'.tr(args: ['$teamId']);
        });

        TeamMember member = TeamMember(
          id: null,
          role: Role.MEMBER,
          userId: userId,
          teamId: teamId,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, member);
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          qrResultText = 'no_qr_code_found'.tr();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('no_qr_code_found'.tr())));
      }
    }
  }

  Future<void> _pickAndScanImage() async {
    if (isProcessing) return;

    try {
      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (imageFile != null) {
        if (mounted) {
          setState(() {
            qrResultText = 'analyzing_image'.tr();
          });
        }
        final BarcodeCapture? capture = await scannerController.analyzeImage(
          imageFile.path,
        );

        if (capture != null && capture.barcodes.isNotEmpty) {
          final String? code = capture.barcodes.first.rawValue;
          _handleScannedCode(code);
        } else {
          _handleScannedCode(null);
        }
      } else {
        if (mounted) {
          setState(() {
            qrResultText = 'image_selection_cancelled'.tr();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          qrResultText = 'error_picking_scanning_image'.tr();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_picking_scanning_image'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'join_team_via_qr'.tr(),
          style: TextStyle(color: colors.textColor),
        ),
        backgroundColor: colors.primaryColor,
        iconTheme: IconThemeData(color: colors.textColor),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: scannerController,
              onDetect: (BarcodeCapture capture) {
                if (isProcessing) return;
                if (capture.barcodes.isNotEmpty) {
                  final String? code = capture.barcodes.first.rawValue;
                  _handleScannedCode(code);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: ElevatedButton.icon(
              icon: Icon(Icons.image_search, color: colors.textColor),
              onPressed: _pickAndScanImage,
              label: Text(
                'scan_qr_from_gallery'.tr(),
                style: TextStyle(color: colors.textColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.itemBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  qrResultText ?? 'point_camera_at_qr'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textColor.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
