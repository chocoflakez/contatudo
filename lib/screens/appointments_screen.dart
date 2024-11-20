import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/add_appointment_screen.dart';
import 'package:contatudo/widgets/appointment_card.dart';
import 'package:contatudo/widgets/my_main_appbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:contatudo/models/appointment.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Appointment>> appointments;
  DateTime? startDate;
  DateTime? endDate;
  int appointmentsFoundCount = 0;

  @override
  void initState() {
    super.initState();
    startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    endDate = DateTime.now();
    appointments = fetchAppointments();
  }

  Future<List<Appointment>> fetchAppointments() async {
    print('AppointmentsScreen::fetchAppointments INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      return [];
    }

    try {
      // Inicializa a query com um tipo que aceite o encadeamento com .order()
      var query = supabase
          .from('appointment')
          .select('*, clinic(name)')
          .eq('user_id', userId);

      // Aplica os filtros condicionais
      if (startDate != null) {
        query = query.gte('appointment_date', startDate!.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('appointment_date', endDate!.toIso8601String());
      }

      // Aplica a ordenação diretamente no encadeamento
      final response = await query
          .order('appointment_date', ascending: false)
          .order('created_at', ascending: false);

      // Formata as datas para o formato "dd-MM-yyyy"
      final formattedStartDate = startDate != null
          ? DateFormat('dd-MM-yyyy').format(startDate!)
          : 'N/A';
      final formattedEndDate =
          endDate != null ? DateFormat('dd-MM-yyyy').format(endDate!) : 'N/A';

      print('startDate: $formattedStartDate, endDate: $formattedEndDate');

      setState(() {
        appointmentsFoundCount = response.length;
      });

      if (response.isEmpty) {
        print('AppointmentsScreen::fetchAppointments END');
        return [];
      }

      print('AppointmentsScreen::fetchAppointments END');

      return (response as List).map((appointmentData) {
        return Appointment.fromMap(appointmentData as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      throw Exception('Erro ao buscar consultas: $error');
    }
  }

  void refreshAppointments() {
    print('AppointmentsScreen::refreshAppointments INI');
    setState(() {
      appointments = fetchAppointments();
    });
    print('AppointmentsScreen::refreshAppointments END');
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'PT'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentColor, // Cor da barra superior
              onPrimary: Colors.white, // Cor do texto na barra superior
              onSurface: AppColors.primaryText, // Cor do texto nos dias
            ),
            dialogTheme: const DialogThemeData(
                backgroundColor: AppColors.background), // Fundo do calendário
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyMainAppBar(title: 'Consultas'),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Row(
                      children: [
                        const Text('De: ', style: TextStyle(fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.accentColor),
                          ),
                          child: Text(
                            startDate != null
                                ? DateFormat('dd-MM-yyyy').format(startDate!)
                                : 'Selecionar data',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: startDate != null
                                  ? Colors.black
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Row(
                      children: [
                        const Text('Até: ', style: TextStyle(fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.accentColor),
                          ),
                          child: Text(
                            endDate != null
                                ? DateFormat('dd-MM-yyyy').format(endDate!)
                                : 'Selecionar data',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: endDate != null
                                  ? Colors.black
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.accentColor),
                  onPressed: () {
                    setState(() {
                      appointments = fetchAppointments();
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.secondaryText),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Consultas encontradas: $appointmentsFoundCount',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: appointments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Erro ao carregar consultas: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma consulta encontrada.'));
                } else {
                  final appointments = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    itemCount: appointments.length + 1,
                    itemBuilder: (context, index) {
                      if (index == appointments.length) {
                        return const SizedBox(height: 70);
                      }

                      final appointment = appointments[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 5.0), // Espaçamento entre cartões
                        child: AppointmentCard(
                          appointment: appointment,
                          onAppointmentUpdated:
                              refreshAppointments, //Callback para atualizar a lista
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          appointments.then((resolvedAppointments) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAppointmentScreen(
                  lastAppointment: resolvedAppointments.isNotEmpty
                      ? resolvedAppointments.first
                      : null,
                ),
              ),
            ).then((result) {
              print(
                  'Retorno de AddAppointmentScreen: $result'); // Log para verificar o retorno
              if (result == true) {
                print('Chamando refreshAppointments()');
                refreshAppointments();
              }
            });
          });
        },

        backgroundColor: AppColors.accentColor,
        icon: const Icon(Icons.add, color: AppColors.cardColor),
        label: const Text(
          'Adicionar Consulta',
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
}
