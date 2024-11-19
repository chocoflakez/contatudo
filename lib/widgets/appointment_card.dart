import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/add_appoinment_screen.dart';
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback?
      onAppointmentUpdated; // Callback para notificar atualizações

  const AppointmentCard(
      {Key? key, required this.appointment, this.onAppointmentUpdated})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // Garante que o fundo do cartão seja branco
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          showAppointmentDetailsDialog(context, appointment);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Primeira secção: ícone circular
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.accentColor.withOpacity(0.1),
                child: Icon(Icons.event_note, color: AppColors.accentColor),
              ),
              const SizedBox(width: 16), // Espaçamento entre as secções

              // Segunda secção: informação detalhada
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentColor,
                        ),
                        softWrap: false),
                    Text(
                      '${appointment.clinicName ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      '${DateFormat('dd-MM-yyyy').format(appointment.appointmentDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Espaçamento entre as secções

              // Terceira secção: valor destacado
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${appointment.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    '${appointment.getLiquidValue().toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8), // Espaçamento entre a secção e a seta

              // Quarta secção: ícone de seta
              Icon(Icons.arrow_forward_ios, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  void showAppointmentDetailsDialog(
      BuildContext context, Appointment appointment) {
    print('AppointmentCard::showAppointmentDetailsDialog INI');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detalhes da Consulta',
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
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailRow('Nome do Paciente', appointment.patientName),
                const SizedBox(height: 5),
                buildDetailRow('Clínica', appointment.clinicName ?? 'N/A'),
                const SizedBox(height: 5),
                buildDetailRow(
                  'Data',
                  DateFormat('dd-MM-yyyy').format(appointment.appointmentDate),
                ),
                const SizedBox(height: 5),
                buildDetailRow(
                    'Valor', '${appointment.price.toStringAsFixed(2)} €'),
                const SizedBox(height: 5),
                buildDetailRow(
                  'Percentagem',
                  '${appointment.userPercentage}%',
                ),
                const SizedBox(height: 5),
                buildDetailRow(
                  'Custo Extra',
                  '${appointment.extraCost!.toStringAsFixed(2)}€',
                ),
                const SizedBox(height: 5),
                buildDetailRow(
                  'Descrição',
                  appointment.description.isNotEmpty
                      ? appointment.description
                      : 'N/A',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit,
                      color: AppColors.accentColor, size: 20),
                  const SizedBox(width: 4),
                  const Text(
                    'Editar',
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAppointmentScreen(
                      isEditing: true,
                      existingAppointment: appointment,
                    ),
                  ),
                ).then((result) {
                  if (result == true) {
                    onAppointmentUpdated
                        ?.call(); // Chama o callback quando há uma atualização
                  }
                });
              },
            ),
          ],
        );
      },
    );
    print('AppointmentCard::showAppointmentDetailsDialog END');
  }

  Widget buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText, // Texto secundário
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black, // Cor do valor
          ),
        ),
      ],
    );
  }
}
