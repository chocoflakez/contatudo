import 'package:contatudo/app_config.dart';
import 'package:flutter/material.dart';

class MyUnavailableFunctionality extends StatelessWidget {
  const MyUnavailableFunctionality({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.construction,
          size: 100,
          color: AppColors.accentColor,
        ),
        SizedBox(height: 16),
        Text(
          'Esta funcionalidade está em construção!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Volte em breve para mais atualizações',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
