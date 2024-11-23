import 'package:contatudo/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? code; // Receives the code from the URL

  const ResetPasswordScreen({Key? key, required this.code}) : super(key: key);

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
    final String? token = widget.code;

    if (token == null) {
      _setError("Token inválido ou ausente. Tente novamente.");
      return;
    }

    final String newPassword = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _setError("Por favor, preencha todos os campos.");
      return;
    }

    if (newPassword != confirmPassword) {
      _setError("As senhas não correspondem.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Authenticate the user with the recovery token
      final response = await Supabase.instance.client.auth.verifyOTP(
        token: token,
        type: OtpType.recovery,
      );

      if (response.user == null) {
        _setError("Erro ao autenticar com o token. Tente novamente.");
        return;
      }

      // Update the password after successful authentication
      final updateResponse = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateResponse.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha redefinida com sucesso!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _setError("Erro ao redefinir senha. Tente novamente.");
      }
    } catch (error) {
      _setError("Erro ao redefinir senha: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setError(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
      _isLoading = false;
    });
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
