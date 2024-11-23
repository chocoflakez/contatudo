import 'package:contatudo/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? code; // Recebe o código da URL
  final String email; // Recebe o email do usuário

  const ResetPasswordScreen({Key? key, required this.code, required this.email})
      : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String? token = widget.code; // Token do URL
    final String email = widget.email; // Email do usuário passado

    if (token == null || email.isEmpty) {
      setState(() {
        _errorMessage = "Token ou email inválido. Tente novamente.";
        _isLoading = false;
      });
      return;
    }

    final String newPassword = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Por favor, preencha todos os campos.";
        _isLoading = false;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "As senhas não correspondem.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Verificar o OTP com o email
      final response = await Supabase.instance.client.auth.verifyOTP(
        token: token,
        type: OtpType.recovery,
        email: email,
      );

      if (response.user != null) {
        // Atualizar a senha
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha redefinida com sucesso!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        setState(() {
          _errorMessage =
              "Erro ao redefinir senha. Verifique as informações e tente novamente.";
        });
      }
    } catch (error) {
      final errorMessage = error.toString();
      if (errorMessage.contains('otp_expired')) {
        setState(() {
          _errorMessage =
              "O link de redefinição expirou. Solicite um novo link.";
        });
      } else {
        setState(() {
          _errorMessage = "Erro ao redefinir senha: $error";
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redefinir Senha"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nova senha",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar senha",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Redefinir Senha"),
            ),
          ],
        ),
      ),
    );
  }
}
