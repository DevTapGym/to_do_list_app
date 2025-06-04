import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/bloc/auth/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_event.dart';
import 'package:to_do_list_app/bloc/auth/auth_state.dart';
import 'package:to_do_list_app/services/profile_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String? avatar; // Thêm avatar để hiển thị ảnh hiện tại

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    this.avatar,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _avatarImagePath;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  String? _fullImagePath; // Lưu đường dẫn đầy đủ để upload

  // Base URL để hiển thị ảnh từ server
  static const String _baseImageUrl = 'http://localhost:8080/storage/avatar/';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _avatarImagePath = widget.avatar; // Khởi tạo với avatar hiện tại
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final fileName = image.path.split('/').last;
      print('Picked image name: $fileName');
      print('Full image path: ${image.path}');
      setState(() {
        _avatarImagePath = fileName; // Lưu tên file
        _fullImagePath = image.path; // Lưu đường dẫn đầy đủ
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.authResponse != null) {
      final userId = authState.authResponse!.user.id;
      try {
        String? avatarUrl =
            _avatarImagePath?.startsWith(_baseImageUrl) == true
                ? _avatarImagePath
                : null; // Ban đầu đặt avatarUrl từ avatar hiện tại nếu là URL

        // Nếu có ảnh mới, upload trước
        if (_fullImagePath != null &&
            !_fullImagePath!.startsWith(_baseImageUrl)) {
          final userService = ProfileService();
          final fileName = await userService.uploadFile({
            'filePath': _fullImagePath!,
            'folder': 'avatars',
          });
          avatarUrl =
              '$_baseImageUrl$fileName'; // Tạo avatarUrl từ fileName trả về
        }

        // Gọi updateProfile với avatarUrl đã được cập nhật
        final userService = ProfileService();
        await userService.updateProfile({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'avatarImagePath': avatarUrl,
          'userId': userId,
        });

        // Cập nhật AuthBloc
        context.read<AuthBloc>().add(
          UpdateProfileEvent(
            name: _nameController.text,
            phone: _phoneController.text,
            avatar: avatarUrl,
          ),
        );

        // Trả về dữ liệu cho màn hình trước
        Navigator.pop(context, {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'avatar': avatarUrl,
        });

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thông tin đã được cập nhật.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      backgroundColor: colors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: colors.textColor, size: 24),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: colors.bgColor),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80, bottom: 20),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.itemBgColor,
                          boxShadow: [
                            BoxShadow(
                              color: colors.itemBgColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipOval(
                              child:
                                  _avatarImagePath != null
                                      ? _avatarImagePath!.startsWith('http')
                                          ? Image.network(
                                            _avatarImagePath!,
                                            width: 130,
                                            height: 130,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                                      child: SizedBox(
                                                        width: 130,
                                                        height: 130,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color:
                                                              colors
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                          )
                                          : Image.file(
                                            File(_fullImagePath ?? ''),
                                            width: 130,
                                            height: 130,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                                      child: SizedBox(
                                                        width: 130,
                                                        height: 130,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color:
                                                              colors
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                          )
                                      : Container(
                                        width: 130,
                                        height: 130,
                                        alignment: Alignment.center,
                                        child: Text(
                                          widget.name.isNotEmpty
                                              ? widget.name[0].toUpperCase()
                                              : 'DN',
                                          style: TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold,
                                            color: colors.primaryColor,
                                          ),
                                        ),
                                      ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primaryColor,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.itemBgColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.itemBgColor.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: colors.subtitleColor.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textColor,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
