import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Đặt lại mật khẩu'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_reset, size: 80, color: Colors.purpleAccent),
                  const SizedBox(height: 30),
                  Text(
                    'Tạo mật khẩu mới',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đặt mật khẩu mới cho tài khoản\nexample@gmail.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Trường nhập mật khẩu mới
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Trường xác nhận mật khẩu
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Nút đặt lại mật khẩu
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Đặt lại mật khẩu',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
