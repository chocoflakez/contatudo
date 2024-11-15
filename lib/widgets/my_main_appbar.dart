import 'package:contatudo/app_config.dart';
import 'package:contatudo/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MyMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyMainAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.appBarColor,
      centerTitle: true,
      actions: [
        IconButton(
          icon:
              Icon(Icons.account_circle_outlined, color: AppColors.primaryText),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
