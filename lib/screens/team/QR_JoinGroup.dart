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

  
  final MobileScannerController scannerController = MobileScannerController(
    
  );
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    scannerController.dispose(); 
    super.dispose();
  }

  void _handleScannedCode(String? code) {
    if (isProcessing) return; 

    if (code != null&&code.startsWith("TODOLIST-")) {
      code=code.replaceAll("TODOLIST-", "");
      int teamId = int.tryParse(code) ?? 0;

      if (teamId == 0) {
        if (mounted) {
          setState(() {
            qrResultText = 'Invalid QR: Not a Team ID';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scanned QR code is not a valid Team ID.')),
          );
        }
        
        return;
      }

      if (mounted) {
        setState(() {
          isProcessing = true; 
          qrResultText = 'Team ID Found: $teamId. Joining...';
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
          qrResultText = 'No QR code found';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code found.')),
        );
      }
    }
  }

  Future<void> _pickAndScanImage() async {
    if (isProcessing) return; 

    try {
      final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        if (mounted) {
          setState(() {
            qrResultText = 'Analyzing image...';
          });
        }
        final BarcodeCapture? capture = await scannerController.analyzeImage(imageFile.path);
        
        if (capture != null && capture.barcodes.isNotEmpty) {
          final String? code = capture.barcodes.first.rawValue;
          _handleScannedCode(code);
        } else {
          _handleScannedCode(null); 
        }
      } else {
        if (mounted) {
          setState(() {
            qrResultText = 'Image selection cancelled.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          qrResultText = 'Error picking/scanning image.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Team via QR', style: TextStyle(color: colors.textColor)),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.image_search, color: colors.textColor),
              onPressed: _pickAndScanImage,
              label: Text('Scan QR from Gallery', style: TextStyle(color: colors.textColor)),
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
                  qrResultText ?? 'Point camera at QR code or select from gallery',
                  style: TextStyle(fontSize: 16, color: colors.textColor.withOpacity(0.8)),
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