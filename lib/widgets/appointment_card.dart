import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/add_appointment_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onAppointmentUpdated;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onAppointmentUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
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
              // CircleAvatar(
              //   radius: 24,
              //   backgroundColor: AppColors.accentColor.withOpacity(0.1),
              //   child: Icon(Icons.event_note, color: AppColors.accentColor),
              // ),
              // const SizedBox(width: 16),
              Expanded(
                flex: 2,
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
                      softWrap: false,
                    ),
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
              const SizedBox(width: 16),
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
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon:
                    const Icon(Icons.more_vert, color: AppColors.secondaryText),
                color: AppColors.cardColor, // Fundo do menu alinhado com o tema
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Cantos arredondados
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
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
                        onAppointmentUpdated?.call();
                      }
                    });
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
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
                          content: const Text(
                            'Tem certeza que deseja remover esta consulta?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryText,
                            ),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accentColor,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 4,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              icon: const Icon(Icons.delete,
                                  color: AppColors.accentColor),
                              label: const Text(
                                'Remover',
                                style: TextStyle(color: AppColors.accentColor),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      await deleteAppointment(appointment.id);
                      onAppointmentUpdated?.call(); // Atualiza a lista
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit,
                            color: AppColors.accentColor, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete,
                            color: AppColors.accentColor, size: 20),
                        SizedBox(width: 8),
                        Text('Remover'),
                      ],
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

  void showAppointmentDetailsDialog(
      BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: AppColors.accentColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final supabase = Supabase.instance.client;
    await supabase.from('appointment').delete().eq('id', appointmentId);
  }

  Widget buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
