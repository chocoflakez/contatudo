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

      if (response == null || response.isEmpty) {
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Clínica'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nome da Clínica'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Localização'),
                ),
                TextField(
                  controller: defaultPayValueController,
                  decoration:
                      const InputDecoration(labelText: 'Taxa por Defeito (%)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
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
                              'Erro: Nenhuma resposta recebida ao criar clínica.')),
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
              },
              child: const Text('Adicionar'),
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
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                final clinic = clinics[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 16.0), // Espaçamento entre os cartões
                  child: ClinicCard(
                    clinic: clinic,
                    onDetailsPressed: () {
                      // Adicione a lógica para ver detalhes
                    },
                    onEditPressed: () {
                      // Adicione a lógica para editar a clínica
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddClinicDialog,
        backgroundColor: AppColors.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
