import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/dashboard_screen.dart';
import 'package:contatudo/screens/register_screen.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  Future<void> signIn() async {
    print('LoginScreen::signIn INI');
    final email = emailController.text;
    final password = passwordController.text;
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login realizado com sucesso!"),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }

      print('LoginScreen::signIn END');
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erro ao fazer login: $error"),
      ));
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text;
    final supabase = Supabase.instance.client;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Por favor, insira seu e-mail para recuperação."),
      ));
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "E-mail de recuperação enviado. Verifique sua caixa de entrada."),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erro ao enviar e-mail de recuperação: $error"),
      ));
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    IconData? icon,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Por favor, preencha este campo';
          }
          if (keyboardType == TextInputType.number && value != null) {
            final num? number = num.tryParse(value);
            if (number == null) {
              return 'Digite um valor numérico válido';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.secondaryText),
          filled: true,
          fillColor: Colors.white,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.secondaryText) : null,
          suffixIcon: toggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.secondaryText,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                const BorderSide(color: AppColors.accentColor, width: 2),
          ),
        ),
        style: const TextStyle(color: AppColors.primaryText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Conta Tudo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/logo1.png', height: 100),
            const SizedBox(height: 20),
            buildTextField(
              controller: emailController,
              label: 'Email',
              isRequired: true,
              icon: Icons.email,
            ),
            buildTextField(
              controller: passwordController,
              label: 'Password',
              isRequired: true,
              icon: Icons.lock,
              obscureText: !isPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                signIn();
              },
              icon: const Icon(
                Icons.login,
                color: Colors.white,
              ),
              label: const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(200, 56),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 6,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: resetPassword,
              child: const Text(
                "Esqueceu a senha?",
                style: TextStyle(color: AppColors.accentColor),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Não tem uma conta?",
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Registe-se aqui",
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
