import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> signUp() async {
    print('RegisterScreen::signUp INI');
    final email = emailController.text;
    final password = passwordController.text;
    final fullName = nameController.text;
    final phoneNumber = phoneController.text;

    final supabase = Supabase.instance.client;

    try {
      // Tenta registrar o usuário com email e senha
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Verifica se o usuário foi criado com sucesso
      final User? user = response.user;
      final Session? session = response.session;
      if (user != null) {
        final userId = user.id;

        // Tenta inserir as informações do perfil do usuário na tabela `user`
        final insertResponse = await supabase.from('user').insert({
          'id': userId, // Garante que o campo de ID está correto
          'name': fullName,
          'phone': phoneNumber,
        });

        // Verifica se houve erro na inserção usando hasError
        if (insertResponse) {
          print('Error: ${insertResponse}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Erro ao criar conta: ${insertResponse.error?.message}"),
            ),
          );
        } else {
          print('Account created successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Conta criada com sucesso!")),
          );
          Navigator.pop(context); // Retorna ao AuthScreen
        }
      } else {
        print('Erro ao registrar o usuário.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao registrar o usuário.")),
        );
      }

      print('RegisterScreen::signUp END');
    } catch (error) {
      // Captura qualquer erro no processo de signup e exibe a mensagem
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar conta: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}
