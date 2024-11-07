import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> signOut() async {
    print('ProfileScreen::signOut INI');

    await Supabase.instance.client.auth.signOut();
    Navigator.popUntil(
        context, (route) => route.isFirst); // Retorna à AuthScreen

    print('ProfileScreen::signOut END');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name: $fullName", style: TextStyle(fontSize: 18)),
            Text("Phone Number: $phoneNumber", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signOut,
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
