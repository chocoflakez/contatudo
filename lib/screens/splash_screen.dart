import 'package:contatudo/app_config.dart';
import 'package:contatudo/auth_service.dart';
import 'package:contatudo/screens/dashboard_screen.dart';
import 'package:contatudo/screens/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    redirect();
    super.initState();
  }

  Future<void> redirect() async {
    print('SplashScreen::redirect INI');
    await Future.delayed(Duration(seconds: 0));

    // Use AuthService to check the session
    final session = AuthService.instance.currentSession();

    if (session != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    print('SplashScreen::redirect END');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.accentColor,
        ),
      ),
    );
  }
}
