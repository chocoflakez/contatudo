import 'package:contatudo/screens/add_appoinment_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Appointment>> appointments;

  @override
  void initState() {
    super.initState();
    appointments = fetchAppointments();
  }

  Future<List<Appointment>> fetchAppointments() async {
    print('AppointmentsScreen::fetchAppointments INI');
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Usuário não autenticado.');
      return [];
    }

    try {
      final response = await supabase
          .from('appointment')
          .select('*, clinic(name)')
          .eq('user_id', userId); // Filtra as consultas pelo ID do usuário

      if (response == null || response.isEmpty) {
        print('Resposta vazia.');
        return [];
      }

      print('AppointmentsScreen::fetchAppointments END');
      return (response as List).map((appointmentData) {
        return Appointment.fromMap(appointmentData as Map<String, dynamic>);
      }).toList();
    } catch (error, stackTrace) {
      print('Erro: $error');
      print('AppointmentsScreen::fetchAppointments - StackTrace: $stackTrace');
      throw Exception('Erro ao buscar consultas: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultas'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar consultas: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma consulta encontrada.'));
          } else {
            final appointments = snapshot.data!;
            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final formattedDate = DateFormat('dd/MM/yyyy')
                    .format(appointment.appointmentDate);
                return ListTile(
                  title: Text(appointment.patientName),
                  subtitle: Text(
                    'Clínica: ${appointment.clinicName ?? 'N/A'}\n'
                    'Data: $formattedDate\n'
                    'Valor: ${appointment.price.toStringAsFixed(2)}€',
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppointmentScreen()),
          ).then((_) {
            // Atualiza a lista de consultas quando volta para esta tela
            setState(() {
              appointments = fetchAppointments();
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
