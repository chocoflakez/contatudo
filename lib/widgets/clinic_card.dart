import 'package:flutter/material.dart';
import 'package:contatudo/app_config.dart';
import 'package:contatudo/models/clinic.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onEditPressed;

  const ClinicCard({
    Key? key,
    required this.clinic,
    this.onDetailsPressed,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardColor, // Fundo branco
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.accentColor.withOpacity(0.1),
                  child: Icon(Icons.local_hospital_rounded,
                      color: AppColors.accentColor),
                ),
                const SizedBox(width: 8),
                Text(
                  clinic.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Localização: ${clinic.location}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Percentagem (por defeito): ${clinic.defaultPayValue.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onEditPressed,
                  child: Text('Editar',
                      style: TextStyle(color: AppColors.accentColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}