import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/login_screen.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:contatudo/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "";
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    print('ProfileScreen::fetchUserProfile INI');
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final response =
            await supabase.from('user').select().eq('id', userId).maybeSingle();

        if (response != null) {
          setState(() {
            fullName = response['name'] ?? "Nome não disponível";
            phoneNumber = response['phone'] ?? "Telefone não disponível";
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Perfil não encontrado")));
        }
      }

      print('ProfileScreen::fetchUserProfile END');
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar perfil: $error")));
    }
  }

  Future<void> confirmSignOut() async {
    print('ProfileScreen::confirmSignOut INI');

    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmação',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.accentColor,
            ),
          ),
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: const Text('Tem certeza de que deseja sair?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.accentColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 4,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.logout, color: AppColors.accentColor),
              label: const Text('Logout',
                  style: TextStyle(color: AppColors.accentColor)),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      final success = await AuthService.instance.signOut();
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao fazer logout.")),
        );
      }
    }

    print('ProfileScreen::confirmSignOut END');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyMainAppBar(title: 'Perfil'),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name: $fullName", style: TextStyle(fontSize: 18)),
            Text("Phone Number: $phoneNumber", style: TextStyle(fontSize: 18)),
            Text("Email: ${Supabase.instance.client.auth.currentUser?.email}",
                style: TextStyle(fontSize: 18)),
            Text("User ID: ${Supabase.instance.client.auth.currentUser?.id}",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: confirmSignOut,
              icon: const Icon(Icons.logout, color: Colors.white),
              label:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(150, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
