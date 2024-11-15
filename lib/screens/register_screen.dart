import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/dashboard_screen.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
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
      if (user != null) {
        final userId = user.id;

        print('User ID (auth.uid): ${supabase.auth.currentUser?.id}');
        print('User ID being inserted: $userId');
        print(
            'User email: ${user.email}, name: $fullName, phone: $phoneNumber');

        // Tenta inserir as informações do perfil do usuário na tabela `user`
        final insertResponse = await supabase.from('user').insert({
          'id': userId,
          'name': fullName,
          'phone': phoneNumber,
          'email': email,
        }).select();

        // Verifica se houve erro na inserção com base na presença de dados ou mensagem de erro
        if (insertResponse == null || insertResponse.isEmpty) {
          print('Error: Erro na inserção de dados.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao criar conta: Erro na inserção de dados."),
            ),
          );
        } else {
          print('Account created successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Conta criada com sucesso!")),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
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
      appBar: MyMainAppBar(title: 'Registar'),
      backgroundColor: AppColors.background,
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
