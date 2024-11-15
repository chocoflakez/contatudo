import 'package:contatudo/app_config.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clinic.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController appointmentDateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController userPercentController = TextEditingController();
  final TextEditingController extraCostController = TextEditingController();
  bool hasExtraCost = false;
  Clinic? selectedClinic;
  List<Clinic> clinics = [];

  @override
  void initState() {
    super.initState();
    fetchClinics();
  }

  Future<void> fetchClinics() async {
    print('AddAppointmentScreen::fetchClinics INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Usuário não autenticado.');
      return;
    }

    try {
      final response =
          await supabase.from('clinic').select().eq('user_id', userId);

      setState(() {
        clinics = (response as List)
            .map((clinicData) =>
                Clinic.fromMap(clinicData as Map<String, dynamic>))
            .toList();
      });
      print('AddAppointmentScreen::fetchClinics END');
    } catch (error) {
      print('Erro ao buscar clínicas: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AddAppointmentScreen::build INI');
    return Scaffold(
      appBar: MyMainAppBar(title: 'Adicionar Consulta'),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<Clinic>(
              value: selectedClinic,
              hint: Text('Selecione uma clínica'),
              onChanged: (Clinic? newClinic) {
                setState(() {
                  selectedClinic = newClinic;
                  if (newClinic != null) {
                    userPercentController.text =
                        newClinic.defaultPayValue.toString();
                  }
                });
              },
              items: clinics.map((clinic) {
                return DropdownMenuItem<Clinic>(
                  value: clinic,
                  child: Text(clinic.name),
                );
              }).toList(),
            ),
            TextField(
              controller: patientNameController,
              decoration: InputDecoration(labelText: 'Nome do Paciente'),
            ),
            TextFormField(
              controller: appointmentDateController,
              decoration: InputDecoration(labelText: 'Data da Consulta'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('pt', 'PT'),
                );

                if (pickedDate != null) {
                  setState(() {
                    appointmentDateController.text =
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                  });
                }
              },
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Preço (€)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: userPercentController,
              decoration:
                  InputDecoration(labelText: 'Percentuagem Usuário (%)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            CheckboxListTile(
              title: Text('Tem custo extra?'),
              value: hasExtraCost,
              onChanged: (bool? value) {
                setState(() {
                  hasExtraCost = value ?? false;
                });
              },
            ),
            if (hasExtraCost)
              TextField(
                controller: extraCostController,
                decoration: InputDecoration(labelText: 'Custo Extra (€)'),
                keyboardType: TextInputType.number,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('AddAppointmentScreen::addAppointment INI');
                final patientName = patientNameController.text;
                final appointmentDate = DateFormat('dd-MM-yyyy')
                    .parse(appointmentDateController.text);
                final description = descriptionController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;
                final userPercentage =
                    int.tryParse(userPercentController.text) ?? 100;
                final extraCost = hasExtraCost
                    ? (double.tryParse(extraCostController.text) ?? 0.0)
                    : 0.0;
                final supabase = Supabase.instance.client;
                final userId = supabase.auth.currentUser?.id;

                if (userId == null || selectedClinic == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Erro: Usuário ou clínica não selecionada.')),
                  );
                  return;
                }

                try {
                  final response = await supabase.from('appointment').insert({
                    'user_id': userId,
                    'clinic_id': selectedClinic!.id,
                    'patient_name': patientName,
                    'appointment_date': appointmentDate.toIso8601String(),
                    'description': description,
                    'price': price,
                    'user_percentage': userPercentage,
                    'has_extra_cost': hasExtraCost,
                    'extra_cost': extraCost,
                  }).select();

                  if (response.isEmpty) {
                    print(
                        'AddAppointmentScreen::addAppointment - Nenhuma resposta recebida.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao criar consulta.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Consulta criada com sucesso!')),
                    );
                    Navigator.pop(context);
                  }
                } catch (error) {
                  print('Erro ao criar consulta: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar consulta: $error')),
                  );
                }
                print('AddAppointmentScreen::addAppointment END');
              },
              child: Text('Adicionar Consulta'),
            ),
          ],
        ),
      ),
    );
    print('AddAppointmentScreen::build END');
  }
}
