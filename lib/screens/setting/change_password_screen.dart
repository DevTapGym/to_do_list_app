import 'package:flutter/material.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  void _handleChangePassword() {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass != confirmPass) {
      _showMessage('New password and confirm password do not match');
      return;
    }

    if (oldPass == newPass) {
      _showMessage('New password must be different from old password');
      return;
    }

    // TODO: call backend to change password
    _showMessage('Password changed successfully', success: true);

    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
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
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: colors.textColor, size: 24),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            autovalidateMode:
                _autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
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
                    children: [
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Old Password',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter old password'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter new password';
                          if (value == _oldPasswordController.text)
                            return 'New password must differ from old password';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Mật khẩu phải trên 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please confirm your new password';
                          if (value != _newPasswordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
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
                    onPressed: () {
                      setState(() => _autoValidate = true);
                      if (_formKey.currentState!.validate()) {
                        _handleChangePassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
