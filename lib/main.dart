import 'package:contatudo/screens/splash_screen.dart';
import 'package:contatudo/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

// Declare a GlobalKey for the Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    _handleInitialLink();
  }

  void _initDeepLinkListener() async {
    print('MyApp::_initDeepLinkListener INI');
    _appLinks = AppLinks();
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      print('MyApp::_initDeepLinkListener uri: $uri');
      if (uri != null && uri.host == 'resetpassword') {
        final resetCode = uri.queryParameters['code'];
        print('MyApp::_initDeepLinkListener resetCode: $resetCode');
        if (resetCode != null) {
          _navigateToResetPasswordScreen(resetCode);
        }
      }
    }, onError: (Object err) {
      print('MyApp::_initDeepLinkListener Error: $err');
    });
    print('MyApp::_initDeepLinkListener END');
  }

  Future<void> _handleInitialLink() async {
    print('MyApp::_handleInitialLink INI');
    try {
      _appLinks = AppLinks();
      final Uri? uri = await _appLinks.getInitialLink();
      print('MyApp::_handleInitialLink uri: $uri');
      if (uri != null && uri.host == 'resetpassword') {
        final resetCode = uri.queryParameters['code'];
        print('MyApp::_handleInitialLink resetCode: $resetCode');
        if (resetCode != null) {
          _navigateToResetPasswordScreen(resetCode);
        }
      }
    } catch (e) {
      print('MyApp::_handleInitialLink Error: $e');
    }
    print('MyApp::_handleInitialLink END');
  }

  void _navigateToResetPasswordScreen(String resetCode) {
    print('MyApp::_navigateToResetPasswordScreen INI');
    Future.delayed(Duration.zero, () {
      if (mounted) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: '', // Passe o e-mail se disponível
              resetCode: resetCode,
            ),
          ),
        );
      } else {
        print(
            "O widget já não está mais montado. Navegação não pode ser realizada.");
      }
    });
    print('MyApp::_navigateToResetPasswordScreen END');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Conta tudo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: const [
        Locale('pt', 'PT'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
