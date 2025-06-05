import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class QRPage extends StatefulWidget {
  final Team team;
  const QRPage({super.key, required this.team});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) return true;

    if (await Permission.photos.request().isGranted) return true;

    if (await Permission.manageExternalStorage.request().isGranted) return true;

    // Nếu bị từ chối
    if (await Permission.storage.isPermanentlyDenied ||
        await Permission.photos.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Storage permission is permanently denied. Please enable it in app settings.',
          ),
        ),
      );
      openAppSettings();
    }

    return false;
  }

  Future<void> _saveQrCodeToGallery() async {
    if (_isSaving) {
      return;
    }
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
        return;
      }

      if (_qrKey.currentContext == null || !_qrKey.currentContext!.mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code widget is not ready yet.')),
          );
          setState(() {
            _isSaving = false;
          });
        }
        return;
      }

      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate QR image data.')),
          );
        }
        return;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name:
            "team_qr_${widget.team.id}_${DateTime.now().millisecondsSinceEpoch}",
        isReturnImagePathOfIOS: true,
      );

      if (mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'QR Code saved to Gallery! ${result['filePath'] != null ? "Path: ${result['filePath']}" : ""}',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save QR code: ${result['errorMessage'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save QR code: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      backgroundColor: colors.primaryColor,
      appBar: AppBar(
        title: Text(
          "Team ${widget.team.name}",
          style: TextStyle(color: colors.textColor),
        ),
        backgroundColor: colors.primaryColor,
        iconTheme: IconThemeData(color: colors.textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt, color: colors.textColor),
            onPressed: _isSaving ? null : _saveQrCodeToGallery,
            tooltip: "Save QR Code to Gallery",
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _qrKey,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: QrImageView(
              data: "TODOLIST-${widget.team.id}",
              version: QrVersions.auto,
              size: 220.0,
            ),
          ),
        ),
      ),
    );
  }
}
