import 'package:contatudo/app_config.dart';
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // Garante que o fundo do cartão seja branco
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => showAppointmentDetailsDialog(context, appointment),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Clínica: ${appointment.clinicName ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(appointment.appointmentDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      'Valor: ${appointment.price.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  void showAppointmentDetailsDialog(
      BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalhes da Consulta'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome do Paciente: ${appointment.patientName}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clínica: ${appointment.clinicName ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(appointment.appointmentDate)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Descrição: ${appointment.description ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Valor: ${appointment.price.toStringAsFixed(2)}€',
                  style: const TextStyle(fontSize: 14),
                ),
                if (appointment.extraCost != null && appointment.extraCost! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Custo Extra: ${appointment.extraCost!.toStringAsFixed(2)}€',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                if (appointment.userPercentage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Percentagem do Usuário: ${appointment.userPercentage}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
