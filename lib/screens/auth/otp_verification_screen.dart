import 'dart:async';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  Timer? _timer;
  int _secondsRemaining = 90;
  bool _isResendAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendCode();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 90;
      _isResendAvailable = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {
          _isResendAvailable = true;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _sendCode() async {
    final success = await _authService.sendCode(widget.email);
    if (!success) {
      _showMessage("Gửi mã thất bại. Vui lòng thử lại sau.");
    }
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      _showMessage("Vui lòng nhập mã OTP hợp lệ.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _authService.checkCode(widget.email, code);
    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showMessage("Mã xác thực không đúng.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Xác minh OTP'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 80,
                  color: Colors.purpleAccent,
                ),
                const SizedBox(height: 30),
                const Text(
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
                  'Chúng tôi đã gửi mã xác minh đến\n$email',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Mã OTP',
                    counterText: '',
                    prefixIcon: Icon(Icons.pin, color: Colors.grey),
                  ),
                  style: const TextStyle(fontSize: 18, letterSpacing: 8),
                ),
                const SizedBox(height: 10),
                Text(
                  _isResendAvailable
                      ? 'Bạn có thể gửi lại mã.'
                      : 'Gửi lại mã sau $_secondsRemaining giây',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (_isResendAvailable)
                  TextButton(
                    onPressed: () {
                      _sendCode();
                      _startCountdown();
                    },
                    child: const Text("Gửi lại mã"),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Xác minh',
                            style: TextStyle(fontSize: 16),
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
