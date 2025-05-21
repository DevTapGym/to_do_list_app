import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Quên mật khẩu'),
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
                  // Icon và tiêu đề
                  Icon(Icons.lock_reset, size: 80, color: Colors.purpleAccent),
                  const SizedBox(height: 30),
                  Text(
                    'Đặt lại mật khẩu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nhập email của bạn để nhận mã OTP',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Trường nhập email
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@mail.com',
                      prefixIcon: Icon(Icons.email, color: Colors.grey),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Nút gửi OTP
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/otp-verification');
                    },
                    child: Text('Gửi mã OTP', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),

                  // Liên kết quay lại đăng nhập
                  TextButton(
                    onPressed: () {
                      // Quay lại màn hình đăng nhập
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Quay lại đăng nhập',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 16,
                      ),
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
