import 'dart:async';

import 'package:flutter/material.dart';
import 'package:to_do_list_app/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final success = await _authService.sendCode(email);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(email: email),
          ),
        );
      } else {
        _showMessage("Gửi mã thất bại. Vui lòng kiểm tra lại email.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Quên mật khẩu'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: Colors.purpleAccent,
                    ),
                    const SizedBox(height: 30),
                    const Text(
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

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',

                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                      ),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email của bạn';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Vui lòng nhập email hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Send OTP button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _requestOtp,
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : const Text(
                                'Gửi mã OTP',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Màn hình 2: Nhập OTP
class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  Timer? _timer;
  int _secondsRemaining = 90;
  bool _isResendAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
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

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email),
        ),
      );
    } else {
      _showMessage("Mã xác thực không đúng.");
    }
  }

  Future<void> _sendCode() async {
    final success = await _authService.sendCode(widget.email);
    if (!success) {
      _showMessage("Gửi mã thất bại. Vui lòng thử lại sau.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
              child: Form(
                key: _formKey,
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
                      'Chúng tôi đã gửi mã xác minh đến\n${widget.email}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Trường nhập OTP
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Mã OTP',
                        prefixIcon: Icon(Icons.pin, color: Colors.grey),
                      ),
                      style: TextStyle(fontSize: 18, letterSpacing: 8),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mã OTP';
                        }
                        if (value.length < 6) {
                          return 'Mã OTP phải có 6 chữ số';
                        }
                        return null;
                      },
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
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
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
        ),
      ),
    );
  }
}

// Màn hình 3: Đặt lại mật khẩu
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Mô phỏng đặt lại mật khẩu
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Hiển thị thông báo thành công và quay lại màn hình đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Quay về màn hình đăng nhập
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: Colors.purpleAccent,
                    ),
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
                      'Đặt mật khẩu mới cho tài khoản\n${widget.email}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Trường nhập mật khẩu mới
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu mới';
                        }
                        if (value.length < 8) {
                          return 'Mật khẩu phải có ít nhất 8 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Trường xác nhận mật khẩu
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Nút đặt lại mật khẩu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : Text(
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
      ),
    );
  }
}
