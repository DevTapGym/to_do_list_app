import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_event.dart';
import 'package:to_do_list_app/bloc/auth/auth_state.dart';
import 'package:to_do_list_app/screens/setting/change_password_screen.dart';
import 'package:to_do_list_app/screens/setting/edit_profile_screen.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.bgColor,
        appBar: AppBar(
          backgroundColor: colors.bgColor,
          title: Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: colors.bgColor),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.authResponse != null) {
                final user = state.authResponse!.user;
                final initials =
                    user.name.isNotEmpty
                        ? user.name
                            .trim()
                            .split(' ')
                            .map((e) => e[0])
                            .take(2)
                            .join()
                            .toUpperCase()
                        : 'NA';

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      //Avatar
                      Padding(
                        padding: const EdgeInsets.only(top: 50, bottom: 20),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: colors.itemBgColor,
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: colors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      //User Info
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
                            ListTile(
                              leading: Icon(
                                Icons.person,
                                color: colors.primaryColor,
                              ),
                              title: Text(
                                'Name',
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                user.name,
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
                                color: colors.primaryColor,
                              ),
                              title: Text(
                                'Email',
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                user.email,
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
                                color: colors.primaryColor,
                              ),
                              title: Text(
                                'Phone',
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                user.phone,
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
                      //Update and Logout Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: colors.primaryColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.itemBgColor.withOpacity(0.3),
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
                                            name: user.name,
                                            email: user.email,
                                            phone: user.phone,
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
                                color: colors.primaryColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.itemBgColor.withOpacity(0.3),
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
                                          (context) => ChangePasswordScreen(),
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
                                      'Change Password',
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
                );
              } else if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return const Center(child: Text('No user data available.'));
              }
            },
          ),
        ),
      ),
    );
  }
}
