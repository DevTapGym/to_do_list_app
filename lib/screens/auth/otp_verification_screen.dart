import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/bloc/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth_event.dart';
import 'package:to_do_list_app/bloc/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  OtpVerificationScreen({required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Xác minh OTP'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthCheckCode) {
            Navigator.pushNamed(context, "/login");
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
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
                          'Chúng tôi đã gửi mã xác minh đến\n ${widget.email}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
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
                            hintText: '123456',
                            counterText: '',
                            prefixIcon: Icon(Icons.pin, color: Colors.grey),
                          ),
                          style: TextStyle(fontSize: 18, letterSpacing: 8),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mã OTP';
                            }
                            if (value.length != 6) {
                              return 'Mã OTP phải có 6 chữ số';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Hiển thị thời gian còn lại hoặc nút gửi lại
                        Text(
                          'Gửi lại mã sau 60 giây',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Nút xác minh
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              BlocProvider.of<AuthBloc>(context).add(
                                CheckCodeEvent(
                                  email: widget.email,
                                  code: _otpController.text,
                                ),
                              );
                            }
                          },
                          child: Text(
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
          );
        },
      ),
    );
  }
}
