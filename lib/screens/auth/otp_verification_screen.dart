import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_list_app/services/auth_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
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
    await _authService.sendCode(widget.email);
  }

  Future<void> _verifyCode() async {
    final code = _otpControllers.map((controller) => controller.text).join();
    if (code.length != 6 || int.tryParse(code) == null) {
      _showMessage("Vui lòng nhập mã OTP hợp lệ (6 chữ số).");
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

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return Scaffold(
      backgroundColor: colors.bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textColor),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Xác minh OTP',
          style: TextStyle(
            color: colors.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.verified_user, size: 80, color: colors.primaryColor),
                const SizedBox(height: 30),
                Text(
                  'Nhập mã OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Chúng tôi đã gửi mã xác minh đến\n${widget.email}',
                  style: TextStyle(fontSize: 16, color: colors.subtitleColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 24,
                          color: colors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: colors.itemBgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  _focusNodes[index].hasFocus
                                      ? colors.primaryColor
                                      : colors.subtitleColor,
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colors.primaryColor,
                              width: 3,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colors.subtitleColor,
                              width: 1,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(index, value),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Text(
                  _isResendAvailable
                      ? 'Bạn có thể gửi lại mã'
                      : 'Gửi lại mã sau $_secondsRemaining giây',
                  style: TextStyle(color: colors.subtitleColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                if (_isResendAvailable)
                  TextButton(
                    onPressed: () {
                      _sendCode();
                      _startCountdown();
                    },
                    child: Text(
                      "Gửi lại mã",
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.primaryColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
