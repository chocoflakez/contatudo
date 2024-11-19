import 'package:contatudo/app_config.dart';
import 'package:contatudo/models/appointment.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clinic.dart';

class AddAppointmentScreen extends StatefulWidget {
  final bool isEditing;
  final Appointment? existingAppointment;

  AddAppointmentScreen({this.isEditing = false, this.existingAppointment});

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController appointmentDateController =
      TextEditingController();
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

  void loadAppointmentData(Appointment appointment) {
    print('AddAppointmentScreen::loadAppointmentData INI');
    patientNameController.text = appointment.patientName;
    appointmentDateController.text =
        DateFormat('dd-MM-yyyy').format(appointment.appointmentDate);
    descriptionController.text = appointment.description;
    priceController.text = appointment.price.toString();
    userPercentController.text = (appointment.userPercentage ?? 100).toString();
    extraCostController.text = (appointment.extraCost ?? 0.0).toString();
    hasExtraCost = (appointment.extraCost ?? 0.0) > 0;

    // Verifica se a clínica existe na lista antes de atribuí-la
    try {
      selectedClinic = clinics.firstWhere(
        (clinic) => clinic.id == appointment.clinicId,
      );
    } catch (e) {
      selectedClinic = null; // Define como null se não for encontrada
    }
    print('AddAppointmentScreen::loadAppointmentData END');
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

      // Chama loadAppointmentData somente após carregar as clínicas
      if (widget.isEditing && widget.existingAppointment != null) {
        loadAppointmentData(widget.existingAppointment!);
      }
    } catch (error) {
      print('Erro ao buscar clínicas: $error');
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    print('AddAppointmentScreen::updateAppointment INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null || selectedClinic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro: Usuário ou clínica não selecionada.')),
      );
      return;
    }

    try {
      await supabase.from('appointment').update({
        'clinic_id': selectedClinic!.id,
        'patient_name': patientNameController.text,
        'appointment_date': DateFormat('dd-MM-yyyy')
            .parse(appointmentDateController.text)
            .toIso8601String(),
        'description': descriptionController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'user_percentage': int.tryParse(userPercentController.text) ?? 100,
        'has_extra_cost': hasExtraCost,
        'extra_cost': hasExtraCost
            ? (double.tryParse(extraCostController.text) ?? 0.0)
            : 0.0,
      }).eq('id', appointment.id);

      print('Consulta atualizada com sucesso!');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta atualizada com sucesso!')),
      );

      if (mounted) {
        Navigator.pop(context,
            true); // Certifica que o widget ainda está montado antes de tentar fechar
      }

      print('AddAppointmentScreen::updateAppointment END');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar consulta: $error')),
      );
      print('Erro ao atualizar consulta: $error');
    }
  }

  Future<void> insertAppointment() async {
    print('AddAppointmentScreen::insertAppointment INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null || selectedClinic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro: Usuário ou clínica não selecionada.')),
      );
      return;
    }

    try {
      await supabase.from('appointment').insert({
        'user_id': userId,
        'clinic_id': selectedClinic!.id,
        'patient_name': patientNameController.text,
        'appointment_date': DateFormat('dd-MM-yyyy')
            .parse(appointmentDateController.text)
            .toIso8601String(),
        'description': descriptionController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'user_percentage': int.tryParse(userPercentController.text) ?? 100,
        'has_extra_cost': hasExtraCost,
        'extra_cost': hasExtraCost
            ? (double.tryParse(extraCostController.text) ?? 0.0)
            : 0.0,
      });

      print('Consulta adicionada com sucesso!');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta adicionada com sucesso!')),
      );
      Navigator.pop(
          context, true); // Retorna true indicando que houve uma atualização
      print('AddAppointmentScreen::insertAppointment END');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar consulta: $error')),
      );
      print('Erro ao adicionar consulta: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyMainAppBar(
          title: widget.isEditing ? 'Editar Consulta' : 'Adicionar Consulta'),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primeira linha: Clínica e Data
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accentColor),
                      ),
                      child: DropdownButton<Clinic>(
                        value: selectedClinic,
                        hint: const Text('Clínica'),
                        isExpanded: true,
                        underline: const SizedBox(),
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildDateField(
                      context,
                      controller: appointmentDateController,
                      label: 'Data',
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: patientNameController,
                label: 'Nome do Paciente',
                isRequired: true,
              ),
              // Segunda linha: Preço e Percentagem do Usuário
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      controller: priceController,
                      label: 'Preço (€)',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildTextField(
                      controller: userPercentController,
                      label: 'Percentagem (%)',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: descriptionController,
                label: 'Descrição',
              ),
              CheckboxListTile(
                title: const Text('Tem custo extra?'),
                value: hasExtraCost,
                onChanged: (bool? value) {
                  setState(() {
                    hasExtraCost = value ?? false;
                  });
                },
              ),
              if (hasExtraCost)
                buildTextField(
                  controller: extraCostController,
                  label: 'Custo Extra (€)',
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isEditing &&
                          widget.existingAppointment != null) {
                        updateAppointment(widget.existingAppointment!);
                      } else {
                        insertAppointment();
                      }
                    }
                  },
                  icon: Icon(
                    widget.isEditing ? Icons.update : Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    widget.isEditing
                        ? 'Atualizar Consulta'
                        : 'Adicionar Consulta',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(200,
                        56), // Ajuste de tamanho mínimo para garantir uma altura maior
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget buildDateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    IconData icon = Icons.calendar_today, // Ícone de calendário por padrão
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Por favor, selecione uma data';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.secondaryText),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: AppColors.secondaryText),
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
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            locale: const Locale('pt', 'PT'),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.accentColor,
                    onPrimary: Colors.white,
                    onSurface: AppColors.primaryText,
                  ),
                  dialogBackgroundColor: AppColors.background,
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            setState(() {
              controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
            });
          }
        },
      ),
    );
  }
}
