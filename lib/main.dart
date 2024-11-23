import 'package:contatudo/screens/email_input_screen.dart';
import 'package:contatudo/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vtsigxyfiruvmoyjsvqt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0c2lneHlmaXJ1dm1veWpzdnF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA3NjAzMTQsImV4cCI6MjA0NjMzNjMxNH0.FH1-C_zDlpptvLm-G3czCjBV695xM5bv9S7GweeJXoY',
  );

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
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
      home: _handleDynamicLink(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _handleDynamicLink() {
    final uri = Uri.base;

    // Verifica se a URL contém o parâmetro `code` para reset de senha
    if (uri.queryParameters.containsKey('code')) {
      final code = uri.queryParameters['code'];

      print('Code: $code');

      // Solicita o email antes de redirecionar para a tela de reset
      return EmailInputScreen(
        code: code,
      );
    }

    // Caso contrário, continua com o fluxo normal
    return const SplashScreen();
  }
}
