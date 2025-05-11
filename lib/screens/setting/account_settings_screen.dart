import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/bloc/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth_event.dart';
import 'package:to_do_list_app/screens/setting/edit_profile_screen.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // Data for display
  String _name = 'Duc Nghia';
  String _email = 'caoducnghia2004@gmail.com';
  String _phone = '+84 867 173 946';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.primaryColor,
          title: const Text('Account Settings'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(225, 245, 254, 0.9),
                Color.fromRGBO(255, 255, 255, 0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50, bottom: 20),
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : 'DN',
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Colors.blue.shade400,
                              ),
                              title: Text(
                                'Name',
                                style: TextStyle(
                                  color: colors.textColor.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                _name,
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Divider(),

                            ListTile(
                              leading: Icon(
                                Icons.email,
                                color: Colors.blue.shade400,
                              ),
                              title: Text(
                                'Email',
                                style: TextStyle(
                                  color: colors.textColor.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                _email,
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Divider(),

                            ListTile(
                              leading: Icon(
                                Icons.phone,
                                color: Colors.blue.shade400,
                              ),
                              title: Text(
                                'Phone',
                                style: TextStyle(
                                  color: colors.textColor.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                _phone,
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
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
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400.withOpacity(0.9),
                                    Colors.blue.shade600.withOpacity(0.9),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade300.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditProfileScreen(
                                            name: _name,
                                            email: _email,
                                            phone: _phone,
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Update',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade200.withOpacity(0.9),
                                    Colors.grey.shade300.withOpacity(0.9),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(LogoutEvent());
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.black87,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
