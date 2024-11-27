import 'package:contatudo/app_config.dart';
import 'package:contatudo/auth_service.dart';
import 'package:contatudo/screens/dashboard_screen.dart';
import 'package:contatudo/screens/register_screen.dart';
import 'package:contatudo/screens/recover_password_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

  Future<void> signIn() async {
    print('LoginScreen::signIn INI');
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Por favor, preencha todos os campos.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = await AuthService.instance.login(email, password);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login realizado com sucesso!"),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      setState(() {
        errorMessage = "Erro ao fazer login. Verifique suas credenciais.";
      });
    }

    setState(() {
      isLoading = false;
    });

    print('LoginScreen::signIn END');
  }

  Widget buildErrorMessage() {
    if (errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
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
            buildErrorMessage(),
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
              onPressed: isLoading ? null : signIn,
              icon: const Icon(
                Icons.login,
                color: Colors.white,
              ),
              label: isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
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
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecoverPasswordScreen(),
                        ),
                      );
                    },
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
