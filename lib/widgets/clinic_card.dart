import 'package:flutter/material.dart';
import 'package:contatudo/app_config.dart';
import 'package:contatudo/models/clinic.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const ClinicCard({
    Key? key,
    required this.clinic,
    this.onEditPressed,
    this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16), // Margens ajustadas
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.accentColor.withOpacity(0.1),
                  child: Icon(Icons.local_hospital_rounded,
                      color: AppColors.accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    clinic.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.secondaryText),
                  color: AppColors.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit' && onEditPressed != null) {
                      onEditPressed!();
                    } else if (value == 'delete' && onDeletePressed != null) {
                      onDeletePressed!();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit,
                              color: AppColors.accentColor, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
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
            const SizedBox(height: 12),
            Text(
              'Localização: ${clinic.location.isNotEmpty ? clinic.location : "Sem Localização"}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Percentagem (por defeito): ${clinic.defaultPayValue.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
