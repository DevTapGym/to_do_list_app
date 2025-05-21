import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Xác minh OTP'),
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
                  Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.purpleAccent,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Nhập mã OTP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chúng tôi đã gửi mã xác minh đến\n example@gmail.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Trường nhập OTP
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Mã OTP',
                      hintText: '123456',
                      counterText: '',
                      prefixIcon: Icon(Icons.pin, color: Colors.grey),
                    ),
                    style: TextStyle(fontSize: 18, letterSpacing: 8),
                  ),
                  const SizedBox(height: 10),

                  // Hiển thị thời gian còn lại hoặc nút gửi lại
                  Text(
                    'Gửi lại mã sau 60 giây',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Nút xác minh
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reset-password');
                    },
                    child: Text('Xác minh', style: TextStyle(fontSize: 16)),
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
