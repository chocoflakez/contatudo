import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/login_screen.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:contatudo/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Flag to indicate if the data is being loaded from the database
  bool isLoading = true;
  String userName = "";
  String userEmail = "";
  String userId = "";
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    print('ProfileScreen::fetchUserProfile INI');

    setState(() {
      isLoading = true;
    });

    try {
      // Certifique-se de que os detalhes do usuário são carregados no AuthService
      await AuthService.instance
          .loadUserDetails(AuthService.instance.currentUser()?.id ?? "");

      setState(() {
        userName = AuthService.instance.userName ?? "Usuário";
        userEmail = AuthService.instance.userEmail ?? "Sem email";
        userId = AuthService.instance.currentUser()?.id ?? "";
        phoneNumber = AuthService.instance.userPhone ?? "Sem telefone";
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do utilizador: $e');
    }

    setState(() {
      isLoading = false;
    });

    print('ProfileScreen::fetchUserProfile END');
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

  Future<void> confirmDeleteAccount() async {
    print('ProfileScreen::confirmDeleteAccount INI');

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmação de Exclusão',
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
          content: const Text(
              'Tem certeza de que deseja excluir sua conta? Todos os seus dados serão perdidos e não poderão ser recuperados.'),
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
              icon: const Icon(Icons.delete_forever,
                  color: AppColors.accentColor),
              label: const Text('Excluir Conta',
                  style: TextStyle(color: AppColors.accentColor)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      final success = await AuthService.instance.deleteUser();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conta excluída com sucesso.")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao excluir a conta.")),
        );
      }
    }

    print('ProfileScreen::confirmDeleteAccount END');
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
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Full Name: $userName",
                          style: TextStyle(fontSize: 18)),
                      Text("Phone Number: $phoneNumber ",
                          style: TextStyle(fontSize: 18)),
                      Text("Email: $userEmail", style: TextStyle(fontSize: 18)),
                      Text("User ID: $userId", style: TextStyle(fontSize: 18)),
                    ],
                  ),
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: confirmDeleteAccount,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('Excluir Conta',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
