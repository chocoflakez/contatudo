import 'package:flutter/material.dart';
import 'package:contatudo/app_config.dart';

class PerformanceIndicatorsCard extends StatelessWidget {
  final double faturamentoAtual;
  final double faturamentoAnterior;
  final int consultasAtual;
  final int consultasAnterior;

  const PerformanceIndicatorsCard({
    Key? key,
    required this.faturamentoAtual,
    required this.faturamentoAnterior,
    required this.consultasAtual,
    required this.consultasAnterior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faturamentoVariacao = faturamentoAnterior != 0
        ? ((faturamentoAtual - faturamentoAnterior) / faturamentoAnterior) * 100
        : 100;
    final consultasVariacao = consultasAnterior != 0
        ? consultasAtual - consultasAnterior
        : consultasAtual;

    final faturamentoIcon =
        faturamentoVariacao >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    final consultasIcon =
        consultasVariacao >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

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
              child: const Icon(Icons.insights, color: AppColors.accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Indicadores de Performance",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Tooltip(
                        message:
                            "Comparação entre o mês atual e o mês anterior.",
                        child: Icon(Icons.info_outline,
                            size: 18, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(faturamentoIcon,
                          color: faturamentoVariacao >= 0
                              ? Colors.green
                              : Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        "Faturação: ${faturamentoVariacao.toStringAsFixed(2)} %",
                        style: TextStyle(
                          fontSize: 14,
                          color: faturamentoVariacao >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(consultasIcon,
                          color: consultasVariacao >= 0
                              ? Colors.green
                              : Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        "Consultas: ${consultasVariacao >= 0 ? '+ ' : ''}$consultasVariacao",
                        style: TextStyle(
                          fontSize: 14,
                          color: consultasVariacao >= 0
                              ? Colors.green
                              : Colors.red,
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
