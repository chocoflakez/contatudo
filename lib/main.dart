import 'package:contatudo/screens/splash_screen.dart';
import 'package:contatudo/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vtsigxyfiruvmoyjsvqt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0c2lneHlmaXJ1dm1veWpzdnF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA3NjAzMTQsImV4cCI6MjA0NjMzNjMxNH0.FH1-C_zDlpptvLm-G3czCjBV695xM5bv9S7GweeJXoY',
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == 'resetpassword') {
        final resetCode = uri.queryParameters['code'];
        if (resetCode != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: '', // You might need to pass the email here
                resetCode: resetCode,
              ),
            ),
          );
        }
      }
    }, onError: (Object err) {
      // Handle error
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conta tudo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: const [
        Locale('pt', 'PT'), // Adiciona suporte para Português de Portugal
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home:
          const SplashScreen(), // Carrega SplashScreen enquanto aguarda o código
      debugShowCheckedModeBanner: false,
    );
  }
}
