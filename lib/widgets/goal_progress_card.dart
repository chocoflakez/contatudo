import 'package:contatudo/app_config.dart';
import 'package:flutter/material.dart';
import 'custom_linear_progress_bar.dart';

class GoalProgressCard extends StatelessWidget {
  final bool hasGoal;
  final double goalCurrentValue;
  final double goalTargetValue;
  final Function showEditGoalDialog;
  final Function deleteGoal;
  final Function showCreateGoalDialog;

  const GoalProgressCard({
    Key? key,
    required this.hasGoal,
    required this.goalCurrentValue,
    required this.goalTargetValue,
    required this.showEditGoalDialog,
    required this.deleteGoal,
    required this.showCreateGoalDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = goalTargetValue > 0
        ? (goalCurrentValue / goalTargetValue).clamp(0.0, 1.0)
        : 0.0;
    final remainingValue = goalTargetValue - goalCurrentValue;

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accentColor.withOpacity(0.1),
              child: const Icon(Icons.assistant_photo_rounded,
                  color: AppColors.accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Progresso do Objetivo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentColor,
                        ),
                      ),
                      if (hasGoal)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: AppColors.secondaryText),
                          color: AppColors.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              showEditGoalDialog();
                            } else if (value == 'delete') {
                              deleteGoal();
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      size: 20, color: AppColors.accentColor),
                                  SizedBox(width: 8),
                                  Text('Editar Objetivo'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 20, color: AppColors.accentColor),
                                  SizedBox(width: 8),
                                  Text('Apagar Objetivo'),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (hasGoal)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Faturação: ${goalCurrentValue.toStringAsFixed(2)} / ${goalTargetValue.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomLinearProgressBar(
                          progress: progress,
                          progressColor: AppColors.accentColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          remainingValue > 0
                              ? "Faltam ${remainingValue.toStringAsFixed(2)} € para atingir o objetivo"
                              : "Objetivo atingido! 🎉",
                          style: TextStyle(
                            fontSize: 14,
                            color: remainingValue > 0
                                ? AppColors.secondaryText
                                : Colors.green,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ainda não definiu um objetivo",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => showCreateGoalDialog(),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  color: AppColors.accentColor, size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Criar Objetivo',
                                style: TextStyle(color: AppColors.accentColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
