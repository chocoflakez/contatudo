import 'package:flutter/material.dart';
import 'package:contatudo/auth_service.dart';
import 'package:contatudo/app_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetCode;

  const ResetPasswordScreen(
      {required this.email, required this.resetCode, super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "Por favor, preencha todos os campos.";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = "As senhas não correspondem.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success =
        await AuthService.instance.resetPassword(widget.resetCode, newPassword);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Senha alterada com sucesso!"),
      ));
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage = "Erro ao alterar a senha.";
      });
    }

    setState(() {
      isLoading = false;
    });
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
        title: const Text('Alterar senha'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Digite a nova senha.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            buildTextField(
              controller: newPasswordController,
              label: 'Nova Senha',
              isRequired: true,
              icon: Icons.lock,
              obscureText: true,
            ),
            buildTextField(
              controller: confirmPasswordController,
              label: 'Confirmar Nova Senha',
              isRequired: true,
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : resetPassword,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Alterar senha'),
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
