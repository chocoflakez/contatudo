import 'package:contatudo/app_config.dart';
import 'package:contatudo/auth_service.dart';
import 'package:contatudo/screens/dashboard_screen.dart';
import 'package:contatudo/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Declarando o _formKey
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isPasswordVisible = false;
  int currentStep = 0;

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final fullName = nameController.text.trim();
    final phoneNumber = phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, preencha todos os campos obrigatórios."),
        ),
      );
      return;
    }

    try {
      final success = await AuthService.instance.register(
        email: email,
        password: password,
        additionalData: {
          'name': fullName,
          'phone': phoneNumber,
        },
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conta criada com sucesso!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao registrar o usuário.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar conta: $error")),
      );
    }
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
          if (controller == confirmPasswordController &&
              passwordController.text != confirmPasswordController.text) {
            return 'As senhas não correspondem';
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

  Widget buildFirstStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
          buildTextField(
            controller: confirmPasswordController,
            label: 'Confirmar Password',
            isRequired: true,
            icon: Icons.lock,
            obscureText: !isPasswordVisible,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  currentStep = 1;
                });
              }
            },
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            label: const Text(
              'Próximo',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(140, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSecondStep() {
    return Column(
      children: [
        buildTextField(
          controller: nameController,
          label: 'Nome Completo',
          isRequired: true,
          icon: Icons.person,
        ),
        buildTextField(
          controller: phoneController,
          label: 'Número de Telefone',
          isRequired: false,
          icon: Icons.phone,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  currentStep = 0;
                });
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.accentColor),
              label: const Text(
                'Voltar',
                style: TextStyle(color: AppColors.accentColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(140, 50),
              ),
            ),
            ElevatedButton.icon(
              onPressed: signUp,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Registrar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(140, 50),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              currentStep == 0 ? buildFirstStep() : buildSecondStep(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Já tem uma conta?",
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Faça login",
                      style: TextStyle(color: AppColors.accentColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
