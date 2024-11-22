import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:contatudo/app_config.dart';

double calcularValorLiquido(
    double price, double extraCost, int userPercentage) {
  return (price - extraCost) * (userPercentage / 100);
}

Widget lastAppointmentCard(Map<String, dynamic> consulta) {
  final patientName = consulta['patient_name'] ?? 'N/A';
  final clinicName = consulta['clinic']['name'] ?? 'N/A';
  final appointmentDate =
      DateTime.parse(consulta['appointment_date']).toLocal();
  final price = (consulta['price'] as num).toDouble();
  final extraCost = (consulta['extra_cost'] as num?)?.toDouble() ?? 0.0;
  final userPercentage = consulta['user_percentage'] as int? ?? 100;
  final valorLiquido = calcularValorLiquido(price, extraCost, userPercentage);

  return Material(
    color: Colors.white,
    elevation: 2,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accentColor.withOpacity(0.1),
            child: const Icon(Icons.event_note, color: AppColors.accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Última consulta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentColor,
                  ),
                  softWrap: false,
                ),
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  clinicName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  DateFormat('dd-MM-yyyy').format(appointmentDate),
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
                '${price.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                '${valorLiquido.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
