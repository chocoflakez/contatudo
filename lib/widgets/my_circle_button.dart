import 'package:flutter/material.dart';
import 'package:contatudo/app_config.dart';

Widget myCircleButton(
    BuildContext context, String label, IconData icon, Widget targetScreen) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentColor, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            child: Icon(icon, size: 30, color: AppColors.accentColor),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.accentColor,
        ),
      ),
    ],
  );
}
