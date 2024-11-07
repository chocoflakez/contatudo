import 'package:contatudo/main.dart';
import 'package:contatudo/screens/auth_screen.dart';
import 'package:contatudo/screens/dashboard_screen.dart';
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
    await Future.delayed(Duration(seconds: 2));

    final session = supabase.auth.currentSession;

    if (session != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthScreen()));
    }

    print('SplashScreen::redirect END');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
