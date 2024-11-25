import 'package:flutter/material.dart';
import 'package:contatudo/auth_service.dart';
import 'package:contatudo/app_config.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> submitEmail() async {
    print('RecoverPasswordScreen::submitEmail INI');
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        errorMessage = "Por favor, insira seu e-mail para recuperação.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = await AuthService.instance.sendResetPassword(email);

    if (success) {
      print('RecoverPasswordScreen::submitEmail success!');
    } else {
      setState(() {
        errorMessage = "Erro ao enviar o e-mail de recuperação.";
      });
    }

    setState(() {
      isLoading = false;
    });
    print('RecoverPasswordScreen::submitEmail END');
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    IconData? icon,
    bool obscureText = false,
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
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.secondaryText),
          filled: true,
          fillColor: Colors.white,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.secondaryText) : null,
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
      appBar: AppBar(
        title: const Text('Recuperar senha'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Digite o seu email para recuperar a senha.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            buildTextField(
              controller: emailController,
              label: 'Email',
              isRequired: true,
              icon: Icons.email,
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : submitEmail,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Enviar e-mail'),
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
          ],
        ),
      ),
    );
  }
}
