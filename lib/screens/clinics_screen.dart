import 'package:contatudo/app_config.dart';
import 'package:contatudo/models/clinic.dart';
import 'package:contatudo/widgets/clinic_card.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  late Future<List<Clinic>> clinics;

  @override
  void initState() {
    super.initState();
    clinics = fetchClinics();
  }

  Future<List<Clinic>> fetchClinics() async {
    print('ClinicsScreen::fetchClinics INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Usuário não autenticado.');
      return [];
    }

    try {
      final response =
          await supabase.from('clinic').select().eq('user_id', userId);

      if (response.isEmpty) {
        print('Resposta vazia.');
        return [];
      }

      print('ClinicsScreen::fetchClinics END');
      return (response as List).map((clinicData) {
        return Clinic.fromMap(clinicData as Map<String, dynamic>);
      }).toList();
    } catch (error, stackTrace) {
      print('Erro: $error');
      print('ClinicsScreen::fetchClinics - StackTrace: $stackTrace');
      throw Exception('Erro ao buscar clínicas: $error');
    }
  }

  void showAddClinicDialog() {
    print('ClinicsScreen::showAddClinicDialog INI');
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController defaultPayValueController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Adicionar Nova Clínica',
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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField(
                  controller: nameController,
                  label: 'Nome da Clínica',
                  isRequired: true,
                  icon: Icons.local_hospital,
                ),
                buildTextField(
                  controller: locationController,
                  label: 'Localização',
                  isRequired: false,
                  icon: Icons.location_on,
                ),
                buildTextField(
                  controller: defaultPayValueController,
                  label: 'Percentagem por Defeito (%)',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  icon: Icons.percent,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentColor,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: AppColors.accentColor, size: 20),
                  const SizedBox(width: 4),
                  const Text(
                    'Adicionar',
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ],
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final location = locationController.text.trim();
                  final defaultPayValue =
                      double.tryParse(defaultPayValueController.text.trim()) ??
                          0.0;

                  if (name.isEmpty || defaultPayValue == 0.0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Erro: Nome e Percentagem por Defeito são obrigatórios.'),
                      ),
                    );
                    return;
                  }

                  final supabase = Supabase.instance.client;
                  final userId = supabase.auth.currentUser?.id;

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Erro: Usuário não autenticado.')),
                    );
                    return;
                  }

                  try {
                    final response = await supabase.from('clinic').insert({
                      'user_id': userId,
                      'name': name,
                      'location': location,
                      'default_pay_value': defaultPayValue,
                    }).select();

                    if (response.isEmpty) {
                      print(
                          'ClinicsScreen::showAddClinicDialog - Nenhuma resposta recebida ao criar clínica.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Erro: Nenhuma resposta recebida ao criar clínica.'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Clínica criada com sucesso!')),
                      );
                      Navigator.pop(context);
                      setState(() {
                        clinics = fetchClinics();
                      });
                    }
                  } catch (error) {
                    print('Error: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao criar clínica: $error')),
                    );
                  }
                  print('ClinicsScreen::showAddClinicDialog END');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showEditClinicDialog(Clinic clinic) {
    print('ClinicsScreen::showEditClinicDialog INI');
    final TextEditingController nameController =
        TextEditingController(text: clinic.name);
    final TextEditingController locationController =
        TextEditingController(text: clinic.location);
    final TextEditingController defaultPayValueController =
        TextEditingController(text: clinic.defaultPayValue.toString());

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Editar Clínica',
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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField(
                  controller: nameController,
                  label: 'Nome da Clínica',
                  isRequired: true,
                  icon: Icons.local_hospital,
                ),
                buildTextField(
                  controller: locationController,
                  label: 'Localização',
                  isRequired: false, // Localização continua opcional
                  icon: Icons.location_on,
                ),
                buildTextField(
                  controller: defaultPayValueController,
                  label: 'Percentagem por Defeito (%)',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  icon: Icons.percent,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentColor,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.save,
                      color: AppColors.accentColor, size: 20),
                  const SizedBox(width: 4),
                  const Text(
                    'Salvar',
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ],
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final name = nameController.text;
                  final location = locationController.text;
                  final defaultPayValue =
                      double.tryParse(defaultPayValueController.text) ?? 0.0;

                  final supabase = Supabase.instance.client;
                  final userId = supabase.auth.currentUser?.id;

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Erro: Usuário não autenticado.')),
                    );
                    return;
                  }

                  try {
                    final response = await supabase
                        .from('clinic')
                        .update({
                          'name': name,
                          'location': location,
                          'default_pay_value': defaultPayValue,
                        })
                        .eq('id', clinic.id)
                        .select();

                    if (response.isEmpty) {
                      print(
                          'ClinicsScreen::showEditClinicDialog - Nenhuma resposta recebida ao atualizar a clínica.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Erro: Nenhuma resposta recebida ao atualizar a clínica.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Clínica atualizada com sucesso!')),
                      );
                      Navigator.pop(context);
                      setState(() {
                        clinics = fetchClinics();
                      });
                    }
                  } catch (error) {
                    print('Error: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Erro ao atualizar clínica: $error')),
                    );
                  }

                  print('ClinicsScreen::showEditClinicDialog END');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyMainAppBar(title: 'Clínicas'),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Clinic>>(
        future: clinics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar clínicas.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma clínica encontrada.'));
          } else {
            final clinics = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: clinics.length + 1,
              itemBuilder: (context, index) {
                if (index == clinics.length) {
                  return const SizedBox(height: 50);
                }

                final clinic = clinics[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 16.0), // Espaçamento entre os cartões
                  child: ClinicCard(
                    clinic: clinic,
                    onEditPressed: () {
                      showEditClinicDialog(clinic);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAddClinicDialog();
        },
        backgroundColor: AppColors.accentColor,
        icon: const Icon(Icons.add, color: AppColors.cardColor),
        label: const Text(
          'Clínica nova',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Ajusta a forma do botão
        ),
        elevation: 6, // Adiciona uma sombra mais pronunciada
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    IconData? icon, // Adicionado para incluir um ícone opcional
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Por favor, preencha este campo';
          }
          if (keyboardType == TextInputType.number && value != null) {
            final num? number = num.tryParse(value);
            if (number == null) {
              return 'Digite um valor numérico válido';
            }
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
            borderRadius: BorderRadius.circular(12.0), // Borda arredondada
            borderSide: BorderSide.none, // Remove a borda visível
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
}
